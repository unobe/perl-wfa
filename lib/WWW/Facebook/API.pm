#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.3.0');

use WWW::Mechanize;
use Time::HiRes qw(time);
use Digest::MD5 qw(md5_hex);
use CGI::Util qw(escape);

our @namespaces = qw(
    Auth            Canvas          Events
    FBML            Feed            FQL
    Friends         Groups          Notifications
    Photos          Profile         Update
    Users
);

my $create_subclass_code = sub {
    local $_ = shift;
    my $subclass = shift;
    eval qq(
        use WWW::Facebook::API::$_;
        sub $subclass {
            return shift->{'_$subclass'}
                ||= WWW::Facebook::API::$_->new( base => shift )
        }
    );
    croak "Cannot create subclass $subclass: $@\n" if $@;
};

for (@namespaces) {
    my $subclass = "\L$_";
    $create_subclass_code->( $_, $subclass );
}

our %attributes = (
    parse  => 1,
    format => 'JSON',
    debug => 0,
    throw_errors => 1,
    api_key      => '',
    api_version  => '1.0',
    desktop      => '',
    apps_uri     => 'http://apps.facebook.com/',
    server_uri   => 'http://api.facebook.com/restserver.php',
    (   map { $_ => '' }
            qw(
            secret      last_call_success   last_error
            skipcookie  popup               next
            session_key session_expires     session_uid
            callback    app_path            mech
            )
    ),
);

my $create_attribute_code = sub {
    my $attribute = shift;
    my $default   = shift;
    eval qq(
        sub $attribute {
            my \$self = shift;
            return \$self->{$attribute} = shift if \@_;
            return \$self->{$attribute} if defined \$self->{$attribute};
            return \$self->{$attribute} = '$default';
        }
    );
    croak "Cannot create attribute $attribute: $@\n" if $@;
};

for ( keys %attributes ) {
    $create_attribute_code->( $_, $attributes{$_} );
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    $self->{'mech'}
        ||= WWW::Mechanize->new( agent => "Perl-WWW-Facebook-API/$VERSION" );
    my $is_attribute = join '|', keys %attributes;
    delete $self->{$_} for grep !/^($is_attribute)$/, keys %$self;

    $self->$_($self) for map {"\L$_"} @namespaces;
    $self->$_ for keys %attributes;

    return $self;
}

sub log_string {
    my ( $self, $params, $response ) = @_;
    my $string = "\nparams = \n";

    $string .= "\t$_:$params->{$_}\n" for sort keys %{$params};
    $string .= "response =\n$response\n";

    return $string;
}

sub call {
    my ( $self, $method, %args, $params, $secret, $response ) = @_;
    $self->last_call_success(1);
    $self->last_error(undef);

    $params = delete $args{'params'} || {};
    $params->{$_} = $args{$_} for keys %args;

    $secret = $args{'secret'} || $self->secret;
    $params->{'method'} ||= $method;
    $self->_check_values_of($params);
    my $sig =
        $self->generate_sig( params => $params, secret => $self->secret );
    $response = $self->_post_request( $params, $secret );

    $params->{'sig'}    = $sig;
    $params->{'secret'} = $secret;
    if ( $self->debug ) {
        carp $self->log_string( $params, $response );
    }
    if ( $response =~ m!<error_code>(\d+)|{"error_code"\D(\d+)!mx ) {
        $self->last_call_success(0);
        $self->last_error($1);

        if ( $self->throw_errors ) {
            confess "Error during REST $method call:",
                $self->log_string( $params, $response );
        }
    }

    if ( $params->{'callback'} ) {
        $response =~ s/^$params->{'callback'} [^\(]* \((.+) \);$/$1/xms;
    }
    $response = $self->unescape_string($response) unless $self->desktop;

    undef $params;

    return $response unless $self->parse;

    return $self->_parse($response);
}

sub generate_sig {
    my $self   = shift;
    my (%args) = @_;
    my %params = %{ $args{'params'} };

    return md5_hex( (map {"$_=$params{$_}"} sort keys %params), $args{'secret'} );
}

sub verify_sig {
    my $self = shift;
    my (%args) = @_;
    return $args{'sig'} eq $self->generate_sig(
        params => $args{'params'},
        secret => $self->secret
    );
}

sub session {
    my $self = shift;
    my %args = @_;
    $self->{"session_$_"} = $args{$_} for keys %args;
    return;
}

sub unescape_string {
    my $self   = shift;
    my $string = shift;
    $string =~ s/(?<!\\)(\\.)/qq("$1")/gee;
    return $string;
}

sub get_facebook_url {
    my $self = shift;
    my $site = shift || "www";

    return "http://$site.facebook.com";
}

sub get_add_url {
    my $self = shift;

    return $self->get_facebook_url . '/add.php' . $self->_add_url_params( @_ );
}

sub get_login_url {
    my $self = shift;

    return $self->get_facebook_url . '/login.php' . $self->_add_url_params( @_ );
}

sub _add_url_params {
    my $self = shift;
    my $params = '?api_key='.$self->api_key . '&v=1.0';
    my %params = @_;
    for ( sort keys %params ) {
        next if not defined $params{$_};
        $params{$_} = escape($params{$_}) if $_ eq 'next';
        $params .= "&$_=$params{$_}";
    }
    return $params;

}

sub get_app_url {
    my $self = shift;

    return $self->apps_uri . $self->app_path . "/";
}

sub _parse {
    my ( $self, $response ) = @_;

    eval 'use JSON::Any';
    croak "Unable to load JSON module for parsing:$@\n" if $@;
    return JSON::Any->new->decode($response);
}

sub _check_values_of {
    my ( $self, $params ) = @_;

    if ( $self->desktop ) {
        $params->{'call_id'} = time if $self->desktop;
    }

    if ( $params->{'method'} !~ m/^auth/mx ) {
        $params->{'session_key'} = $self->session_key;
        if ( $self->callback ) {
            $params->{'callback'} ||= $self->callback;
        }
    }

    $params->{'method'} = "facebook.$params->{'method'}";
    $params->{'v'} ||= $self->api_version;

    for (qw/api_key format popup next skipcookie/) {
        $params->{$_} ||= $self->$_ if $self->$_;
    }
    return;
}

sub _post_request {
    my ( $self, $params, $secret, $sig, $post_params ) = @_;

    $self->_format_params($params);
    $sig = $self->generate_sig( params => $params, secret => $self->secret );
    $post_params = [ map { $_, $params->{$_} } sort keys %$params ];
    push @$post_params, 'sig', $sig;

    $self->mech->post( $self->server_uri, $post_params );

    return $self->mech->content;
}

sub _format_params {
    my $self   = shift;
    my $params = shift;

    # reformat arrays and add each param to digest
    for ( keys %$params ) {
        next unless ref $params->{$_} eq 'ARRAY';
        $params->{$_} = join q{,}, @{ $params->{$_} };
    }
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API - Facebook API implementation


=head1 VERSION

This document describes WWW::Facebook::API version 0.3.0


=head1 SYNOPSIS

    use WWW::Facebook::API;

    my $client = WWW::Facebook::API->new(
        desktop        => 1,
        throw_errors   => 1,
    );
    
    # Session initialization
    my $token = $client->auth->create_token;
    
    # prompts for login credentials from STDIN
    $client->login->login($token);
    $client->auth->get_session( auth_token => $token );
    
    # Dump XML data returned
    use Data::Dumper;
    my @friends = @{ $client->friends->get->{'uid'} };
    print Dumper $client->friends->are_friends(
        uids1 => [ @friends[ 0, 1, 2, 3 ] ],
        uids2 => [ @friends[ 4, 5, 6, 7 ] ],
    );
    
    my $unread_pokes = $client->notifications->get->{'pokes'}{'unread'};
    print "You have $unread_pokes unread poke(s).";
    
    my @users =
        @{ $client->users->get_info( uids => \@friends, fields => ['quotes'])->{'user'} };
    print "Number of friends:" . @users . "\n";
    
    # Get number of quotes by derefrencing, and then removing the null items (hash
    # refs)
    my @quotes = grep !ref, map { $_->{'quotes'} } @users;
    print "Number of quotes: " . @quotes . "\n";
    print "Random quote: " . $quotes[ int rand @quotes ] . "\n";
    
    $client->auth->logout;
 

=head1 DESCRIPTION
    
A Perl implementation of the Facebook API, working off of the canonical Java
and PHP implementations. By default it uses L<JSON::Any> to parse the response
returned by Facebook's server. There is an option to return the raw response
in either XML or JSON (See the C<parse> method below). 

=head1 SUBROUTINES/METHODS 

=over

=item new

Returns a new instance of this class. You are able to pass in any of the
attribute method names in L<WWW::Facebook::API> to set its value:
    my $client = WWW::Facebook::API->new(
        parse           => 1,
        format          => 'JSON',
        secret          => 'application_secret_key',
        api_key         => 'application_key',
        session_key     => 'session_key',
        session_expires => 'session_expires',
        session_uid     => 'session_uid',
        desktop         => 1,
        api_version     => '1.0',
        callback        => 'callback_url',
        next            => 'next',
        popup           => 'popup',
        skipcookie      => 'skip_cookie',
    );
    $copy = $client->new;

=back

=head1 NAMESPACE METHODS

All method names from the Facebook API are lower_cased instead of CamelCase.

=over

=item auth

    my $token = $client->auth->create_token;
    $client->auth->get_session( $token );

You only really need to call $client->auth->get_session.
See L<WWW::Facebook::API::Auth>. If you have the desktop attribute set to
true and C<$token> isn't passed in, the return value from
$client->auth->create_token will be used. If the desktop attribute is set to
false and C<$token> isn't passed in, the return value from $client->secret
will be used:
    $client->auth->get_session;

=item canvas

See L<WWW::Facebook::API::Canvas>.

=item events

events namespace of the API (See L<WWW::Facebook::API::Events>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->events->get( uid => 234233, eids => [23,2343,54545] );
    $response = $client->events->get_members( eid => 233 );

=item fbml

fbml namespace of the API (See L<WWW::Facebook::API::FBML>):
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->fbml->set_ref_handle;
    $response = $client->fbml->refresh_img_src;
    $response = $client->fbml->refresh_ref_url;

=item fql

fql namespace of the API (See L<WWW::Facebook::API::FQL>):
    $response = $client->fql->query( query => 'FQL query' );


=item feed

feed namespace of the API (See L<WWW::Facebook::API::Feed>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response 
        = $client->feed->publish_story_to_user(
            title   => 'title',
            body    => 'body',
            priority => 5,
            ...
    );
    $response 
        = $client->feed->publish_action_of_user(
            title   => 'title',
            body    => 'body',
            priority => 7,
            ...
    );

=item friends

friends namespace of the API (See L<WWW::Facebook::API::Friends>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->friends->get;
    $response = $client->friends->get_app_users;
    $response
        = $client->friends->are_friends( uids => [1,5,7,8], uids2 => [2,3,4]);

=item groups

groups namespace of the API (See L<WWW::Facebook::API::Groups>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->groups->get_members( gid => 32 );
    $response    = $client->groups->get( uid => 234324, gids => [2423,334] );

=item notifications

notifications namespace of the API (See L<WWW::Facebook::API::Notifications>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->notifications->get;
    $response = $client->notifications->send(
        to_ids => [1],
        markup => 'markup',
        no_email => 1,
    );
    $response = $client->notifications->send_request(
        to_ids => [1],
        type => 'event',
        content => 'markup',
        image   => 'string',
        invite  => 0,
    );

=item photos

photos namespace of the API (See L<WWW::Facebook::API::Photos>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response
        = $client->photos->add_tag(
            pid => 2,
            tag_uid => 3,
            tag_text => "me",
            x => 5,
            y => 6
        );
    $response = $client->photos->create_album(
            name => 'fun in the sun',
            location => 'California',
            description => "Summer '07",
    );
    $response = $client->photos->get( aid => 2, pids => [4,7,8] );
    $response = $client->photos->get_albums( uid => 1, pids => [3,5] );
    $response = $client->photos->get_tags( pids => [4,5] );
    $response = $client->photos->upload(
        aid => 5,
        caption => 'beach',
        data => 'raw data',
    );

=item profile

profile namespace of the API (See L<WWW::Facebook::API::Profile>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->profile->get_fbml( uid => 3 );
    $response = $client->profile->set_fbml( uid => 5, markup => 'markup' );

=item update

update namespace of the API (See L<WWW::Facebook::API::Update>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->update->decode_ids( ids => [5,4,3] );

=item users

users namespace of the API (See L<WWW::Facebook::API::Users>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    $response = $client->users->get_info(
        uids => [12,453,67],
        fields => ['quotes','activities','books']
    );

=back

=head1 ATTRIBUTE METHODS

These are methods to get/set the object's attributes.

=over

=item api_key

The developer's API key. See the Facebook API documentation.

=item api_version

Which version to use (default is "1.0", which is the only one supported
currently. Corresponds to the argument C<v> that is passed in to methods as a
parameter.

=item apps_uri

The apps uri for Facebook apps. The default is http://apps.facebook.com/.

=item app_path

If using the Facebook canvas, the path to your application. For example if your
application is at http://apps.facebook.com/example/ this should be C<"example">.

=item callback

The callback URL for your application. See the Facebook API documentation.
Just a convenient place holder for the value.

=item debug

A boolean set to either true or false, determining if debugging messages
should be carped to STDERR for REST calls.

=item desktop

A boolean signifying if the client is being used for a desktop application.
See the Facebook API documentation.

=item format('JSON'|'XML')

The default format to use if none is supplied with an API method call.
Currently available options are XML and JSON. Defaults to JSON.

=item last_call_success

A boolean. True if the last call was a success, false otherwise.

=item last_error

A string holding the error message of the last failed call to the REST server.

=item mech

The L<WWW::Mechanize> agent used to communicate with the REST server.
The agent_alias is set initially set to "Perl-WWW-Facebook-API/0.3.0".

=item next

See the Facebook API documentation. Just a convenient place holder for the
value.

=item parse(1|0)

Defaults to 1. If set to true, the response returned by each method call will
be a Perl structure (see each method for the structure it will return). If it
is set to 0, the response string from the server will be returned. (The
response string is unescaped if the 'desktop' attribute is false).

=item popup

See the Facebook API documentation. Just a convenient place holder for the
value.

=item secret

For a desktop application, this is the secret that is used for calling
C<auth->create_token> and C<auth->get_session>. See the Facebook API
documentation under Authentication.

=item server_uri

The server uri to access the Facebook REST server. Default is
C<'http://api.facebook.com/restserver.php'>. See the Facebook API
documentation.

=item session_expires

The session expire timestamp for the client's user. See the Facebook API
documentation.

=item session_key

The session key for the client's user. See the Facebook API documentation.

=item session_uid

The session's uid for the client's user. See the Facebook API documentation.

=item skipcookie

See the Facebook API documentation. Just a convenient place holder for the
value.

=item throw_errors

A boolean set to either true of false, signifying whether or not log_error
should carp when an error is returned from the REST server.

=back

=head1 PUBLIC METHODS

=over

=item call( $method, %args )

The method which other submodules within L<WWW::Facebook::API> use
to call the Facebook REST interface. It takes in a string signifying the method
to be called (e.g., 'auth.getSession'), and key/value pairs for the parameters
to use:
    $client->call( 'auth.getSession', auth_token => 'b3324235e' );

=item generate_sig( params => $params_hashref, secret => $secret )

Generates a sig when given a parameters hash reference and a secret key.

=item get_facebook_url

Returns the URL to Facebook. You can specifiy a specific network as a parameter.

=item get_add_url( %params)

Returns the URL to add your application with the parameters (that are defined)
included. If the C<next> parameter is passed in, it's escaped. Used for
platform applications. 

=item get_login_url( %params )

Returns the URL to login to your application with the parameters (that are
defined) included. If the C<next> parameter is passed in, it's escaped.

=item get_app_url

Returns the URL to your application, if using the Facebook canvas.

=item log_string($params_hashref, $response)

Pass in the params and the response from a call, and it will make a formatted
string out of it showing the parameters used, and the response received.

=item session( uid => $uid, key => $session_key, expires => $session_expires )

Sets the C<user>, C<session_key>, and C<session_expires> all at once.

=item unescape_string($escaped_string)

Returns its parameter with all the escape sequences unescaped. If you're using
a web app, this is done automatically to the response.

=item verify_sig( params => $params_hashref, sig => expected_sig )

Checks the signature for a given set of parameters against an expected value.

=back

=head1 PRIVATE METHODS

=over

=item _add_url_params( %params )

Called by both C<get_login_url> and C<get_add_url> to process any of their
parameters. Prepends the api_key and the version number as parameters and
returns the parameter string.

=item _check_values_of($params_hashref)

Makes sure all the values of the C<$params_hashref> that need to be set are
set. Uses the defaults for those values that are needed and not supplied.

=item _format_params($params_hashref)

Format parameters according to Facebook API spec.

=item _post_request( $params_hashref, $secret )

Used by C<call> to post the request to the REST server and return the
response.

=item _parse($string)

Parses the response from a call to the Facebook server to make it a Perl data
structure, and returns the result.

=back


=head1 DIAGNOSTICS

=over

=item C< Unable to load %s module for parsing >

L<JSON::Any> was not able to load one of the JSON modules it uses to parse
JSON. Please make sure you have one (of the several) JSON modules it can use
installed.

=item C< Error during REST call: %s >

This means that there's most likely an error in the server you are using to
communicate to the Facebook REST server. Look at the traceback to determine
why an error was thrown. Double-check that C<server_uri> is set to the right
location.

=back

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API requires no configuration files or
environment variables.


=head1 DEPENDENCIES

L<version>
L<Crypt::SSLeay>
L<Digest::MD5>
L<JSON::Any>
L<Time::HiRes>
L<WWW::Mechanize>


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
