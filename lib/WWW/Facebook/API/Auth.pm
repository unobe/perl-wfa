#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Auth;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.3');

sub create_token {
    my $self = shift;
    my $token;
    my ( $format, $parse ) = ( $self->base->format, $self->base->parse );

    $self->base->format('JSON');
    $self->base->parse(0);

    $token = $self->base->call( 'auth.createToken', @_ );
    $token =~ s/\W//xmsg;

    $self->base->format($format);
    $self->base->parse($parse);

    return $token;
}

sub get_session {
    my $self = shift;

    my $token = shift;
    croak q{Token needed for call to get_session} if not defined $token;
    if ( $self->base->desktop ) {
        ( my $uri_https = $self->base->server_uri )
            =~ s{http://}{https://}xms;
        $self->base->server_uri($uri_https);
    }

    my ( $format, $parse ) = ( $self->base->format, $self->base->parse );

    $self->base->format('JSON');
    $self->base->parse(0);

    my $response =
        $self->base->call( 'auth.getSession', auth_token => $token );

    $self->base->format($format);
    $self->base->parse($parse);

    my %field = qw(
        session_key     session_key
        expires         session_expires
        uid             session_uid
    );

    if ( $self->base->desktop ) {
        $field{'secret'} = 'secret';
        ( my $uri_http = $self->base->server_uri ) =~ s{https://}{http://}xms;
        $self->base->server_uri($uri_http);
    }

    while ( my ( $key, $val ) = each %field ) {
        $response =~ /$key"\W+([\w-]+)/xms;
        carp "Setting $key to $1" if $self->base->debug;
        $self->base->$val($1);    ## no critic
    }

    return;
}

sub login {
    my ( $self, %args ) = @_;

    croak q{Cannot use login method with web app} unless $self->base->desktop;

    my $token = $self->create_token;
    my $url = $self->base->get_login_url( auth_token => $token );
    my $browser =
          $args{'browser'}
        ? $args{'browser'}
        : $^O =~ m/darwin/xms ? 'open'     ## no critic
        : $^O =~ m/MSWin/xms  ? 'start'    ## no critic
        :                       q{};

    croak "Don't know how to open browser for system '$^O'" if not $browser;

    # Open browser have user login to Facebook app
    system qq($browser "$url");

    # Give the user time to log in
    $args{'sleep'} ||= 15;
    sleep $args{'sleep'};

    return $token;
}

sub logout {
    my $self = shift;
    $self->base->ua->post( 'http://www.facebook.com/logout.php',
        { confirm => 1 } );
    return;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Auth - Facebook Authentication

=head1 VERSION

This document describes WWW::Facebook::API::Auth version 0.4.3

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing auth with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS

=over

=item create_token()

auth.createToken of the Facebook API. Will always return the token string,
regardles of the C<parse> setting in L<WWW::Facebook::API>:

    $token = $client->auth->create_token;

=item get_session( $token )

auth.getSession of the Facebook API. If you have the desktop attribute set to
true and C<$token> isn't passed in, the return value from
C<< $client->auth->create_token >> will be used. If the desktop attribute is set
to false the C<$token> must be the auth_token returned from Facebook to your
web app for that user:

    if ( $q->param('auth_token')  ) {
        $client->auth->get_session( $q->param('auth_token') );
    }

C<get_session> automatically sets C<session_uid>, C<session_key>, and
C<session_expires> for C<$client>. It returns nothing.

=item login( sleep => $sleep , browser => $browser_cmd )

Only for desktop apps. It first calls C<create_token> to get a valid token. It
then opens the user's default browser and have them sign in to the Facebook
application. If C<browser> is passed in, the module will use that string as
the command to execute, e.g.:

    system qq($browser_cmd "$login_url");

After the browser is called, it will pause for C<$sleep> seconds (or 15
seconds if C<$sleep> is not defined), to give the user time to log in. The
method returns the session token created by C<create_token>.

=item logout()

Sends a POST to http://www.facebook.com/logout.php, with the parameter
"confirm" set to 1 (Cf.
http://developers.facebook.com/documentation.php?v=1.0&doc=auth )

=back

=head1 DIAGNOSTICS

=over

=item C< Token needed for call to get_session >

You are running a desktop app and you did not pass a token into get_session.
You can create a token by calling create_token() or (better) login().

You are running a web app and the user hasn't logged in to Facebook for your
web app. When the user does so, an auth_token will be returned (as a
parameter) to your callback url. Use that auth_token for the session.

=item C< Don't know how to open browser for the system %s >

The module doesn't know the command to use to open a browser on the given
system. If you passed in C<browser> to login(), it can use that string as the
command to execute to open the login url.

=item C< Cannot use login method with web app >

The login() method is not able to be used to sign in when using a web app. See
the Facebook TOS A.9.iv.

=back

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Auth requires no configuration files or environment
variables.

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
