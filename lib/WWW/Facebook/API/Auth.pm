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

use version; our $VERSION = qv('0.0.8');

use Moose;
extends 'Moose::Object';

has 'base' => ( is => 'ro', isa => 'WWW::Facebook::API' );

sub create_token {
    my $self = shift;
    my $value = $self->base->call(
        method => 'auth.createToken',
        params => { api_key => $self->base->api_key, @_ },
        secret => $self->base->secret,
    );
    return $self->base->simple
        ? $value->{auth_createToken_response}->[0]->{content}
        : $value;
}

sub get_session {
    my $self = shift;

    if ( $self->base->desktop ) {
        # swap to using https for the sake of getting the session secret
        $self->base->server_uri( _make_secure( $self->base->server_uri ) )
    }

    my $xml = $self->base->call(
        method => 'auth.getSession',
        params => { @_ },
        secret => $self->base->secret,
    );

    for ( qw/session_key session_expires session_uid/ ) {
        $self->base->$_( $xml->{auth_getSession_response}->[0]->{$_}->[0] );
    }
    if ( $self->base->desktop ) {
        $self->base->secret(
            $xml->{auth_getSession_response}->[0]->{secret}->[0]
        );
        $self->base->server_uri( _make_unsecure( $self->base->server_uri ) );
    }
    return $self->base->simple
        ? $xml->{auth_getSession_response}->[0]
        : $xml;
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

This document describes WWW::Facebook::API::Auth version 0.0.8


=head1 SYNOPSIS

    use WWW::Facebook::API::Auth;


=head1 DESCRIPTION

Methods for accessing auth with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item create_token

auth.createToken of the Facebook API.

=item get_session

auth.getSession of the Facebook API.

=back


=head1 INTERNAL METHODS AND FUNCTIONS

=over

=item base

The L<WWW::Facebook::API::Base> object to use to make calls to
the REST server.

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

L<Moose>
L<WWW::Facebook::API>

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
