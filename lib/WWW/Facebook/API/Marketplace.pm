#######################################################################
# $Date: 2007-05-28T14:18:18.679359Z $
# $Revision: 1508 $
# $Author: unobe $
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Marketplace;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.13');

sub get_categories {
    return shift->base->call( 'marketplace.getCategories', @_ );
}

sub get_subcategories {
    return shift->base->call( 'marketplace.getSubcategories', @_ );
}

sub get_listings {
    return shift->base->call( 'marketplace.getListings', @_ );
}

sub search {
    return shift->base->call( 'marketplace.search', @_ );
}

sub create_listing {
    return shift->base->call( 'marketplace.createListing', @_ );
}

sub remove_listing {
    return shift->base->call( 'marketplace.removeListing', @_ );
}

1;    # Magic true value required at end of module

__END__

=head1 NAME

WWW::Facebook::API::Marketplace - Facebook Marketplace

=head1 VERSION

This document describes WWW::Facebook::API::Marketplace version 0.4.13

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing the marketplace with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.

=item get_categories()

The marketplace.getCategories method of the Facebook API:

    $categories = $client->marketplace->get_categories;

=item get_subcategories( category => 'category' )

The marketplace.getSubcategories method of the Facebook API:

    $subcats = $client->marketplace->get_subcategories(
        category => 'category',
    );

=item get_listings( listing_ids => [@listing_ids], uids => [@uids] )

The marketplace.getListings method of the Facebook API:

    $listings_response = $client->marketplace->get_listings(
        listing_ids => [@listing_ids],
        uids => [@uids],
    );

=item search( %params )

The marketplace.search method of the Facebook API:

    $response = $client->marketplace->search(
        category => 'category',
        subcategory => 'subcategory',
        query => 'query',
    );

=item create_listing( %params )

The marketplace.createListing method of the Facebook API:

    $listing_id = $client->marketplace->create_listing(
        listing_id => 0|existing_id,
        show_on_profile => 0|1,
        listing_attrs => 'JSON',
    );

=item remove_listing( listing_id => 'id', status => 'status' )

The marketplace.removeListing method of the Facebook API:

    $success = $client->marketplace->remove_listing(
        listing_id => 'id',
        status => 'SUCCESS|NOT_SUCCESS|DEFAULT',
    );

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Marketplace requires no configuration files or environment
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
