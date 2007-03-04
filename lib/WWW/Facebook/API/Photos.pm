#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Photos;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.5');

use Moose;

extends 'Moose::Object';

has 'base' => ( is => 'ro', isa => 'WWW::Facebook::API::Base' );

sub get_albums {
    if ( not $_[1] ) { confess 'id required'; }
    return $_[0]->base->call(
        method => 'facebook.photos.getAlbums', 
        params => { 'id' => $_[1] },
    );
}

sub get_comment_count {
    return $_[0]->base->call( method => 'facebook.photos.getCommentCount' );
}

sub get_from_album {
    if ( not $_[1] ) { confess 'id required'; }
    if ( not $_[2] ) { confess 'aid required'; }
    return $_[0]->base->call(
        method => 'facebook.photos.getFromAlbum',
        params => { 'id' => $_[1], 'aid' => $_[2] },
    );
}

sub get_of_user {
    if ( not $_[1] ) { confess 'id required'; }
    return $_[0]->base->call(
        method => 'facebook.photos.getOfUser',
        params => { 'id'=> $_[1], 'max'=> ($_[2] ? $_[2] : 0) },
    );
}

1; # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Photos - Photos methods for Client


=head1 VERSION

This document describes WWW::Facebook::API::Photos version 0.0.5


=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing photos with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item base

The L<WWW::Facebook::API::Base> object to use to make calls to
the REST server.

=item get_albums

The photos.getAlbums method of the Facebook API. The first argument is the
'id' as per the API.

=item get_comment_count

The photos.getCommentCount method of the Facebook API.

=item get_from_album

The photos.getFromAlbum method of the Facebook API. The first argument
corresponds to the 'id' and the second corresponds to the 'aid' as per the
API.

=item get_of_user

The photos.getOfUser method of the Facebook API. The first argument
corresponds to the 'id' and the second corresponds to the 'max' as per the
API.


=back


=head1 DIAGNOSTICS

=over

=item C< id required >

No id was passed to the function. Pass an id that is permitted by the Facebook
API.

=item C< aid required >

No aid value was passed to the function. Pass an album id that is permitted by
the Facebook API.

=item C< max required >

No max value was passed to the function. Pass a max value that is permitted by
the Facebook API.

=back


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Photos requires no configuration files or
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
