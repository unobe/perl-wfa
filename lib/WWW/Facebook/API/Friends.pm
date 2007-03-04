#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Friends;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.5');

use Moose;

extends 'Moose::Object';

has 'base' => ( is => 'ro', isa => 'WWW::Facebook::API::Base' );

sub get { return $_[0]->base->call( method => 'facebook.friends.get' ); }

sub get_app_users {
    return $_[0]->base->call( method => 'facebook.friends.getAppUsers' );
}

sub get_requests {
    return $_[0]->base->call( method => 'facebook.friends.getRequests' );
}

sub get_typed {
    if ( not $_[1] ) { confess 'link type required'; }
    return $_[0]->base->call(
        method => 'facebook.friends.getTyped',
        params => { 'link_type' => $_[1] },
    );
}

sub are_friends {
    my ( $self ) = @_;
    for my $id ( 1..2 ) {
        if ( not $_[$id] ) { confess "id$id array ref required"; }
    }
    return $_[0]->base->call(
        method => 'facebook.friends.areFriends', 
        params => { 'id1' => $_[1], 'id2' => $_[2] },
    );
}

1; # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Friends - Friend methods for Client


=head1 VERSION

This document describes WWW::Facebook::API::Friends version 0.0.5


=head1 SYNOPSIS

    use WWW::Facebook::API;


=head1 DESCRIPTION

Methods for accessing friends with L<WWW::Facebook::API>


=head1 SUBROUTINES/METHODS 

=over

=item base

The L<WWW::Facebook::API::Base> object to use to make calls to
the REST server.

=item get

The friends.get method of the Facebook API.

=item get_app_users

The friends.getAppUsers method of the Facebook API.

=item get_requests

The friends.getRequests method of the Facebook API.

=item get_typed

The friends.getTyped method of the Facebook API. The only argument is the
value of 'link_type' per the API.

=item are_friends

The friends.areFriends method of the Facebook API. The two arguments are array
refs that make up an associative array. See the API for further details.

=back


=head1 DIAGNOSTICS

=over

=item C< link type required >

No link type was passed to get_typed. Pass a link type that is permitted by
the Facebook API.

=item C< id1 array ref required >

No id1 array ref was passed to are_friends. Pass two array refs as per the
Facebook API.

=item C< id2 array ref required >

No id2 array ref was passed to are_friends. Pass two array refs as per the
Facebook API.

=back


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Friends requires no configuration files or
environment variables.


=head1 DEPENDENCIES

L<WWW::Facebook::API::Base>.


=head1 INCOMPATIBILITIES

None reported.


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
