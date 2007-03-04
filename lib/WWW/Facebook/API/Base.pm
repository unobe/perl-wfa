#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Base;

use warnings;
use strict;
use Carp;

use WWW::Mechanize;
use Time::HiRes qw(time);
use URI::Escape;
use XML::Simple qw(xml_in);
use Digest::MD5 qw(md5_hex);

use version; our $VERSION = qv('0.0.5');

use Moose;
use WWW::Facebook::API::Errors;

has 'mech' => (is => 'rw', isa => 'WWW::Mechanize', required => 1,
    default => sub {
            WWW::Mechanize->new(
                agent => "Perl-WWW-Facebook-API-REST-Client/$VERSION"
            )
    },
);
has 'server_uri' => (
    is => 'rw', isa => 'Str', required => 1,
    default => 'http://api.facebook.com/restserver.php',
);
has 'secret' => (is => 'ro', isa => 'Str', required => 1,
    default => sub {
        print q{Shhhh...please enter a secret: };
        chomp(my $secret = <STDIN>);
        return $secret;
    },
);
has 'api_key' => (is => 'ro', isa => 'Str', required => 1,
    default => sub {
        print q{Please enter an API key: };
        chomp(my $key = <STDIN>);
        return $key;
    },
);
has 'api_version' => (is => 'ro', isa => 'Str', required => 1,
    default => sub { "1.0" },
);
has 'next' => (is => 'ro', isa => 'Int', required => 1,
    default => sub { 0 }
);
has 'popup' => (is => 'ro', isa => 'Int', required => 1,
    default => sub { 0 }
);
has 'skipcookie' => (is => 'ro', isa => 'Int', required => 1,
    default => sub { 0 }
);
has 'session_secret' => ( is => 'rw', isa => 'Str', default => q{} );
has 'session_key'   => ( is => 'rw', isa => 'Str', default => q{} );
has 'desktop' => ( is => 'ro', isa => 'Bool', required => 1, default => 0 );
has 'errors' => (
    is => 'ro',
    isa => 'WWW::Facebook::API::Errors',
    required => 1,
    default => sub { WWW::Facebook::API::Errors->new },
);

sub call {
    my ( $self, %args ) = @_;
    my ( $method, $params, $secret ) = (
        $args{'method'},
        ( $args{'params'} ? $args{'params'} : {} ),
        ( $args{'secret'} ? $args{'secret'} : $self->session_secret ),
    );
    $self->errors->last_call_success( 1 );
    $self->errors->last_error( undef );

    my $xml = xml_in(
        $self->_post_request( $method, $params, $secret ), 
        ForceArray  => 1,
        KeepRoot    => 1,
    );
    if ($self->errors->debug) {
        $self->errors->log_debug( $params, $xml );
    }
    if ( $xml->{'result'}->[0]->{'fb_error'} ) {
        $self->errors->log_error( $xml );
    }
    return $xml;
}

sub _post_request {
    my ($self, $method, $params, $secret) = @_;
    $params->{'api_key'} = $self->api_key;
    if ( $method !~ m/\.auth/mx ) {
        $params->{'session_key'} = $self->session_key;
        $params->{'api_version'} = $self->api_version;
    }
    $params->{'method'} = $method;
    $params->{'call_id'} = time if $self->desktop;
    for (qw/popup next skipcookie/) {
        $params->{$_} = '' if $self->$_;
    }

    my @post_params = _create_post_params_from( $params );

    push @post_params, 'sig='._api_generate_sig( @post_params, $secret );

    $self->mech->get( $self->server_uri.q{?} . join q{&}, @post_params );
    my $xml = $self->mech->content;

    if ( $xml !~ m/<\?xml/mx ) {
        confess "XML not returned from REST call:\n$xml";
    }

    return $xml;
}

sub _create_post_params_from {
    my ($params, @post_params) = @_;

    for ( sort keys %{$params} ) {
        if ( ref $params->{$_} eq 'ARRAY' ) {
            $params->{$_} = join q{,}, @{ $params->{$_} }
        }
        push @post_params, join '=', $_, uri_escape( $params->{$_} );
    }

    return @post_params;
}

sub _api_generate_sig {
    my $sig = join q{}, map { uri_unescape($_) } @_;
    return md5_hex( $sig );
}

1; # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Base - Base class for Client


=head1 VERSION

This document describes WWW::Facebook::API::Base version 0.0.5


=head1 SYNOPSIS

    use WWW::Facebook::API::Base;


=head1 DESCRIPTION

Base methods and data for WWW::Facebook::API and friends.


=head1 SUBROUTINES/METHODS 

=over

=item call

The method which other submodules within WWW::Facebook::API use
to call the Facebook REST interface. It takes in a hash signifying the method
to be called (e.g., 'auth.getSession'), the parameters to pass through, and
(optionally) the secret to use.

=item mech

The L<WWW::Mechanize> agent used to communicate with the REST server.
Shouldn't be needed for anything. The agent_alias is set to
"Perl-WWW-Facebook-API-REST-Client/$VERSION".

=item server_uri

The server uri to access the Facebook REST server. See the Facebook API
documentation.

=item secret

For a desktop application, this is the secret that is used for calling
create_token and get_session. See the Facebook API documentation under
Authentication. If no secret is passed in to the C<new> method, it will prompt
for one to be entered from STDIN

=item api_key

The developer's API key. See the Facebook API documentation. If no api_key is
passed in to the C<new> method, it will prompt for one to be entered from
STDIN.

=item session_secret

The session secret for the client's user. See the Facebook API documentation.

=item session_key

The session key for the client's user. See the Facebook API documentation.

=item desktop

A boolean signifying if the client is being used for a desktop application.
See the Facebook API documentation.

=item errors

See L<WWW::Facebook::API::Errors>. Basically, a grouping of the
data that handles errors and debug information.

=back

=head1 INTERNAL METHODS AND FUNCTIONS

=over

=item _post_request

Used by C<call> to post the request to the REST server and return the
response.

=item _create_post_params_from

Creates string from the given hash ref by sorting the hash by key and
concatenating the uri_escape'd key value pair to to the string.

=item _api_generate_sig

Generates and returns an md5_hex signature of the parameters for the method
call.

=back


=head1 DIAGNOSTICS

=over

=item C< XML not returned from REST call >

This means that there's most likely an error in the server you are using to
communicate to the Facebook REST server. Double-check that C<server_uri> is
set to the right location.

=back

See L<WWW::Facebook::API::Errors>.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Base requires no configuration files or
environment variables.


=head1 DEPENDENCIES

L<Moose>
L<WWW::Mechanize>
L<XML::Simple>
L<Digest::MD5>
L<Time::HiRes>
L<URI::Escape>


=head1 INCOMPATIBILITIES

None.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api-rest-client@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2006, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
