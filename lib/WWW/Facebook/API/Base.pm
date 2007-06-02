#######################################################################
# $Date$ # $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Base;

use warnings;
use strict;
use Carp;

use WWW::Mechanize;
use Time::HiRes qw(time);
use Digest::MD5;

use version; our $VERSION = qv('0.2.3');

use WWW::Facebook::API::Errors;

our @attributes = qw(
    api_key         secret              format
    api_version     desktop             server_uri
    skipcookie      popup               next
    session_key     session_expires     session_uid
    callback        mech                errors
    parse_response  parse_params
);

sub api_key {
    my $self = shift;
    $self->{'api_key'} = shift if @_;
    if ( not $self->{'api_key'} ) {
        print q{Please enter the API key: };
        chomp( $self->{'api_key'} = <STDIN> );
    }
    return $self->{'api_key'};
}

sub secret {
    my $self = shift;
    $self->{'secret'} = shift if @_;
    if ( not $self->{'secret'} ) {
        print q{Please enter the secret: };
        chomp( $self->{'secret'} = <STDIN> );
    }
    return $self->{'secret'};
}

sub format      { shift->_check_default( 'XML', 'format',      @_ ); }
sub api_version { shift->_check_default( '1.0', 'api_version', @_ ); }
sub desktop     { shift->_check_default( 0,     'desktop',     @_ ); }

sub skipcookie { shift->_check_default( 0,  'skipcookie', @_ ); }
sub popup      { shift->_check_default( 0,  'popup',      @_ ); }
sub next       { shift->_check_default( '', 'next',       @_ ); }

sub server_uri {
    shift->_check_default( 'http://api.facebook.com/restserver.php',
        'server_uri', @_, );
}

sub session_key     { shift->_check_default( '', 'session_key',     @_ ); }
sub session_expires { shift->_check_default( '', 'session_expires', @_ ); }
sub session_uid     { shift->_check_default( '', 'session_uid',     @_ ); }
sub callback        { shift->_check_default( '', 'callback',        @_ ); }
sub parse_response  { shift->_check_default( 1,  'parse_response',  @_ ); }

sub parse_params {
    my $self = shift;
    if ( $self->format eq 'JSON' ) {
        $self->_check_default( { utf8 => 1 }, 'parse_params_JSON', @_ );
    }
    else {
        $self->_check_default( { KeepRoot => 1, ForceArray => 1 },
            'parse_params_XML', @_ );
    }
}

sub mech {
    shift->_check_default(
        WWW::Mechanize->new( agent => "Perl-WWW-Facebook-API/$VERSION" ),
        'mech', @_, );
}

sub errors {
    my $self = shift;
    $self->_check_default( WWW::Facebook::API::Errors->new( base => $self ),
        'errors', @_, );
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    my $is_attribute = join '|', @attributes;
    delete $self->{$_} for grep !/^($is_attribute)$/, keys %$self;

    for ( sort grep !/^parse_params$/, @attributes ) {
        $self->$_;
    }
    if ( $self->{'parse_params'} ) {
        $self->parse_params( delete $self->{'parse_params'} );
    }

    return $self;
}

sub call {
    my ( $self, $method, %args, $params, $secret, $response ) = @_;
    $self->errors->last_call_success(1);
    $self->errors->last_error(undef);

    $params = delete $args{'params'} || {};
    $params->{$_} = $args{$_} for keys %args;

    $secret = $args{'secret'} || $self->secret;
    $params->{'method'} ||= $method;
    $self->_update_params($params);
    my $sig = _create_sig_for( $params, $secret );
    $response = $self->_post_request( $params, $secret );

    if ( $params->{'callback'} ) {
        $response =~ s/^$params->{'callback'}.+(?=\<\?xml)(.+).\);$/$1/;
    }
    $response = $self->unescape_string($response) unless $self->desktop;

    if ( $self->errors->debug ) {
        $params->{'sig'}    = $sig;
        $params->{'secret'} = $secret;
        carp $self->errors->log_string( $params, $response );
    }
    if ( $response =~ m!<error_code>(\d+)|^{"error_code"\D(\d+)!mx ) {
        $params->{'sig'}    = $sig;
        $params->{'secret'} = $secret;
        $self->errors->last_call_success(0);
        $self->errors->last_error($1);

        if ( $self->errors->throw_errors ) {
            confess "Error during REST $method call:\n",
                $self->errors->log_string( $params, $response );
        }
    }

    return $response unless $self->parse_response;

    return $self->_parse( $params->{'format'}, $response );
}

sub generate_sig {
    my $self = shift;
    my %args = shift;
    return _create_sig_for( $args{'params'}, $args{'secret'} );
}

sub verify_sig {
    my $self = shift;
    my %args = shift;
    return $args{'sig'} eq
        $self->generate_sig( $args{'params'}, $self->secret );
}

sub session {
    my $self = shift;
    my %args = shift;
    $self->{"session_$_"} = $args{$_} for keys %args;
    return;
}

sub unescape_string {
    my $self   = shift;
    my $string = shift;
    $string =~ s/(?<!\\)(\\.)/qq("$1")/gee;
    return $string;
}

sub _parse {
    my ( $self, $format, $response, $xml ) = @_;

    if ( $format eq 'JSON' ) {
        eval 'use JSON::XS';
        croak "Unable to load JSON module for parsing\n" if $@;
        my $json   = JSON::XS->new;
        my %params = %{ $self->parse_params };
        $json = $json->$_
            for grep { $params{$_} } keys %{ $self->parse_params };
        return $json->decode($response);
    }
    eval 'use XML::Simple qw(xml_in)';
    croak "Unable to load XML module for parsing\n" if $@;

    $xml = xml_in( $response, %{ $self->parse_params }, );

    if ( $self->simple ) {
        my ($response_node) = keys %$xml;
        $xml = $xml->{$response_node}[0];

        # remove meta-data
        for ( keys %$xml ) {
            delete $xml->{$_} if /^x(ml|si)|list/;
        }

        # keys is screwy: will give uninit warnings otherwise
        if ( keys %$xml ) {
            return $xml->{ [ keys %$xml ]->[0] } if keys %$xml == 1;
        }
        elsif ( exists $xml->{$_}->[0]->{content} ) {
            return $xml->{content};
        }
    }
    return $xml;
}

sub _update_params {
    my ( $self, $params ) = @_;
    if ( $params->{'method'} !~ m/^auth/mx ) {
        $params->{'session_key'} = $self->session_key;
        $params->{'callback'} ||= $self->callback if $self->callback;
    }
    $params->{'call_id'} = time if $self->desktop;
    $params->{'method'} = "facebook.$params->{'method'}";
    $params->{'api_key'} ||= $self->api_key;
    $params->{'format'}  ||= $self->format;
    $params->{'v'}       ||= $self->api_version;

    for (qw/popup next skipcookie/) {
        if ( $self->$_ ) { $params->{$_} = q{} }
    }
    return;
}

sub _post_request {
    my ( $self, $params, $secret, $sig, $post_params ) = @_;

    _reformat_params($params);
    $sig = _create_sig_for( $params, $secret );
    $post_params = [ map { $_, $params->{$_} } sort keys %$params ];
    push @$post_params, 'sig', $sig;

    $self->mech->post( $self->server_uri, $post_params );

    return $self->mech->content;
}

sub _reformat_params {
    my $params = shift;

    # reformat arrays and add each param to digest
    for ( keys %$params ) {
        next unless ref $params->{$_} eq 'ARRAY';
        $params->{$_} = join q{,}, @{ $params->{$_} };
    }
}

sub _create_sig_for {
    my ( $params, $secret ) = @_;

    my $md5 = Digest::MD5->new;
    $md5->add( map {"$_=$params->{$_}"} sort keys %$params );
    $md5->add($secret);

    return $md5->hexdigest;
}

sub _check_default {
    my $self      = shift;
    my $default   = shift;
    my $attribute = shift;
    return $self->{$attribute} = shift if @_;
    return $self->{$attribute} if defined $self->{$attribute};
    return $self->{$attribute} = $default;
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Base - Base class for Client


=head1 VERSION

This document describes WWW::Facebook::API::Base version 0.2.3


=head1 SYNOPSIS

    use WWW::Facebook::API;


=head1 DESCRIPTION

Base methods and data for WWW::Facebook::API and friends.


=head1 SUBROUTINES/METHODS 

=over

=item new

Returns a new instance of this class.

=item format

The default format to use if none is supplied with an API method call.
Currently available options are XML and JSON. Defaults to XML.

=item parse_response

Defaults to 1. If set to true, if the format is set to XML, L<XML::Simple> is
used to parse the response from the server. Likewise, if the format is set to
JSON, <JSON::XS> is used JSON to return a Perlish data structure.

=item parse_params

Defaults to C<{ ForceArray => 1, KeepRoot=> 1 }> if the format is XML and
C<parse_response()> returns true for the current method call to the Facebook
server. These defaults are then added to the parameter list for calling
C<xml_in()> of L<XML::Simple>.

For JSON, the default is different: C<{ utf8 => 1 }>. Since L<JSON::XS> doesn't
allow you to pass in parameters to its function C<from_json()>, these keys in
the received hash are used as method calls to construct the L<JSON::XS>
object. So the default call made is:
    JSON::XS->new->utf8->decode( $response )

Passing in C<{ utf8 => 1, allow_nonref = 1 }> will result in this call:
    JSON::XS->new->utf8->allow_nonref->decode( $response )

The parameters for each parse are actually stored in different variables, so
L<JSON::XS> will never be called with the wrong arguments, and neither will
L<XML::Simple>.

=item call

The method which other submodules within WWW::Facebook::API use
to call the Facebook REST interface. It takes in a hash signifying the method
to be called (e.g., 'auth.getSession'), and key/value pairs for the parameters
to use.

=item generate_sig

Generates a sig when given a parameters hash reference and a secret key.
    $client->generate_sig( params => $params_hashref, secret => $secret );

=item verify_sig

Checks the signature for a given set of parameters against an expected
signature value:
    $client->verify_sig( params => $params_hashref, sig => expected_sig );

=item session

Sets the C<user>, C<session_key>, and C<session_expires> all at once.
    $client->session(
        uid     => $uid,
        key     => $session_key,
        expires => $session_expires,
    );

=item unescape_string

Returns its parameter with all the escape sequences unescaped. If you're using
a web app, this is done automatically to the response.
    $client->unescape_string( $response );

=item mech

The L<WWW::Mechanize> agent used to communicate with the REST server.
Shouldn't be needed for anything. The agent_alias is set to
"Perl-WWW-Facebook-API-REST-Client/$VERSION".

=item server_uri

The server uri to access the Facebook REST server. Default is
C<'http://api.facebook.com/restserver.php'>. See the Facebook API
documentation.

=item secret

For a desktop application, this is the secret that is used for calling
C<auth->create_token> and C<auth->get_session>. See the Facebook API
documentation under Authentication. If no secret is passed in to the C<new>
method, it will prompt for one to be entered from STDIN.

=item api_key

The developer's API key. See the Facebook API documentation. If no api_key is
passed in to the C<new> method, it will prompt for one to be entered from
STDIN.

=item session_key

The session key for the client's user. See the Facebook API documentation.

=item session_expires

The session expire timestamp for the client's user. See the Facebook API
documentation.

=item session_uid

The session's uid for the client's user. See the Facebook API documentation.

=item desktop

A boolean signifying if the client is being used for a desktop application.
See the Facebook API documentation.

=item errors

See L<WWW::Facebook::API::Errors>. Basically, a grouping of the
data that handles errors and debug information.

=item api_version

Which version to use (default is "1.0", which is the only one supported
currently. Corresponds to the argument C<v> that is passed in to methods as a
parameter.

=item callback

The callback URL for your application. See the Facebook API documentation.

=item next

See the Facebook API documentation.

=item popup

See the Facebook API documentation.

=item skipcookie

See the Facebook API documentation.

=back

=head1 INTERNAL METHODS AND FUNCTIONS

=over

=item _reformat_params

Reformat parameters according to Facebook API spec.

=item _update_params

Updates values for parameters that are passed in.

=item _post_request

Used by C<call> to post the request to the REST server and return the
response.

=item _create_sig_for

Creates signature (md5) for the post parameters, and returns a reference to
the post parameters with the sig as the last element in the list.

=item _parse

Calls either JSON::XS or XML::Simple to parse the response received from the
Facebook server. Returns the response via C<call>.

=back


=head1 DIAGNOSTICS

=over

=item C< Unable to load %s module for parsing >

L<JSON::XS> or L<XML::Simple> is cannot be loaded. Make sure it is installed
if you are setting parse_response to 1.

=item C< Error during REST call: %s >

This means that there's most likely an error in the server you are using to
communicate to the Facebook REST server. Look at the traceback to determine
why an error was thrown. Double-check that C<server_uri> is set to the right
location.

=back

See L<WWW::Facebook::API::Errors>.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Base requires no configuration files or
environment variables.


=head1 DEPENDENCIES

See L<WWW::Facebook::API>


=head1 INCOMPATIBILITIES

None.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
