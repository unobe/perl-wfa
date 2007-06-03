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

use version; our $VERSION = qv('0.3.0');

sub base { return shift->{'base'}; }

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    delete $self->{$_} for grep !/base/, keys %$self;
    $self->$_ for keys %$self;

    return $self;
}

sub create_token {
    my $self = shift;
    my $token;
    my $orig_format = $self->base->format;
    my $orig_parse  = $self->base->parse; 

    $self->base->format('JSON');
    $self->base->parse(0);

    $token = $self->base->call( 'auth.createToken', @_ );
    $token =~ s/\W//g;

    $self->base->format($orig_format);
    $self->base->parse($orig_parse);

    return $token;
}

sub get_session {
    my $self = shift;

    my $token = shift;
    if ( $self->base->desktop ) {
        $token ||= $self->base->create_token;
        $self->base->server_uri( _make_secure( $self->base->server_uri ) );
    }
    else {
        $token ||= $self->base->secret;
    }

    my $orig_format = $self->base->format;
    my $orig_parse  = $self->base->parse; 

    $self->base->format('JSON');
    $self->base->parse(0);

    my $response = $self->base->call( 'auth.getSession', auth_token => $token );

    $self->base->format($orig_format);
    $self->base->parse($orig_parse);

    my %field = qw(
        session_key     session_key
        expires         session_expires
        uid             session_uid
    );

    if ( $self->base->desktop ) {
        $field{'secret'} = 'secret';
        $self->base->server_uri( _make_unsecure( $self->base->server_uri ) );
    }

    while ( my ( $key, $val ) = each %field ) {
        $response =~ /$key"\W+([\w-]+)/;
        carp "Setting $key to $1" if $self->base->debug;
        $self->base->$val($1);
    }

    return;
}


sub login {
    my ( $self, %args ) = @_;
    my $token = $self->base->secret;

    my $url = $self->base->get_login_url;

    if ( $self->base->desktop ) {
        $token = $self->create_token;
        $url   = $self->base->get_login_url( auth_token => $token );
    }

    my $agent = $self->base->mech->agent_alias('Mac Mozilla');
    $self->base->mech->get( $url );

    confess 'No form to submit!' unless $self->base->mech->forms;

    $self->base->mech->submit_form(
        form_number => 1,
        fields      => {
            email => $args{'email'},
            pass  => $args{'pass'},
        },
        button => 'login',
    );

    carp $self->base->mech->content if $self->base->debug;

    if ( not $self->base->desktop ) {
        $token = ( $self->base->mech->uri =~ /auth_token=(.+)$/ )[0]
    }
    elsif ( $self->base->mech->content !~ m{Logout</a>}mix ) {
        confess "Unable to login to Facebook using WWW::Mechanize\n";
    }

    $self->base->mech->agent($agent);
    return $token;
}

sub logout {
    my $self = shift;
    $self->base->mech->post( 'http://www.facebook.com/logout.php',
        { confirm => 1 } );
}

sub _make_secure {
    my $uri = shift;
    $uri =~ s{http://}{https://}mx;
    return $uri;
}

sub _make_unsecure {
    my $uri = shift;
    $uri =~ s{https://}{http://}mx;
    return $uri;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Auth - Authentication utilities for Client


=head1 VERSION

This document describes WWW::Facebook::API::Auth version 0.3.0


=head1 SYNOPSIS

    use WWW::Facebook::API;


=head1 DESCRIPTION

Methods for accessing auth with L<WWW::Facebook::API>

=head1 METHODS 

=over

=item new()

Returns a new instance of this class.

=item base()

The L<WWW::Facebook::API> object that the current object is attached to. (Used
to access settings.)

=item create_token()

auth.createToken of the Facebook API. Will always return the token string,
regardles of the 'parse' setting in L<WWW::Facebook::API>.

=item get_session( $auth_token )

auth.getSession of the Facebook API. If you have a desktop app,
C<create_token> will be called if C<$auth_token> isn't passed in. If you have
a web app, the C<secret> in L<WWW::Facebook::API> will be used if
C<$auth_token> isn't passed in. Either way, it automatically sets
C<session_uid> C<session_key> and C<session_expires>. Nothing is returned.

=item login( user => $username, pass => $password )

Not part of the official Facebook API. Logs in to Facebook using
L<WWW::Mechanize>. The 'user' and 'pass' parameters must be supplied. If you
have a desktop app, C<create_token> will automatically be called. Returns the
session token.

=item logout()

Sends a POST to http://www.facebook.com/logout.php, with the parameter
"confirm" set to 1 (Cf.
http://developers.facebook.com/documentation.php?v=1.0&doc=auth )

=back


=head1 INTERNAL FUNCTIONS

=over

=item _make_secure

Changes the server_uri to https for C<get_session>.

=item _make_unsecure

Changes the server_uri back to http at the end of C<get_session>.

=back


=head1 DIAGNOSTICS

None.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Auth requires no configuration files or
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
