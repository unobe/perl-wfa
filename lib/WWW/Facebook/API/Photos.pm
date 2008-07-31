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

use version; our $VERSION = qv('0.4.13');

sub add_tag      { return shift->base->call( 'photos.addTag',      @_ ) }
sub create_album { return shift->base->call( 'photos.createAlbum', @_ ) }
sub get          { return shift->base->call( 'photos.get',         @_ ) }
sub get_albums   { return shift->base->call( 'photos.getAlbums',   @_ ) }
sub get_tags     { return shift->base->call( 'photos.getTags',     @_ ) }
sub upload       { return shift->base->call( 'photos.upload',      @_ ) }

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Photos - Facebook Photos

=head1 VERSION

This document describes WWW::Facebook::API::Photos version 0.4.13

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing photos with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.

=item add_tag( %params )

The photos.addTag method of the Facebook API:

    $response = $client->photos->add_tag(
            pid => 2,
            tag_uid => 3,
            tag_text => "me",
            x => 5,
            y => 6,
        );

or

   $response = $client->photos->add_tag( tags => $json_serialized );

C<tag_text> is ignored if C<tag_uid> is set.

=item create_album( name => $name, location => $loc, description => $descr )

The photos.createAlbum method of the Facebook API:

    $response = $client->photos->create_album(
            name => 'fun in the sun',
            location => 'California',
            description => "Summer '07",
    );

=item get( subj_id => 'uid', aid => $album_id, pids => [ @photo_ids ] )

The photos.get method of the Facebook API:

    $response = $client->photos->get( subj_id => 3, aid => 2, pids => [4,7,8] );

=item get_albums( uid => $uid, pids => [ @photo_ids ] )

The photos.getAlbums method of the Facebook API:

    $response = $client->photos->get_albums( uid => 1, pids => [3,5] );

=item get_tags( pids => [ @photo_ids ] )

The photos.getTags method of the Facebook API:

    $response = $client->photos->get_tags( pids => [4,5] );

=item upload( aid => $album_id, caption => $caption, data => $data )

The photos.upload method of the Facebook API:

    $response = $client->photos->upload(
        aid => 5,
        caption => 'beach',
        data => 'raw data',
    );

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Photos requires no configuration files or environment
variables.

=head1 DEPENDENCIES

See L<WWW::Facebook::API>

=head1 INCOMPATIBILITIES

None reported.

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
