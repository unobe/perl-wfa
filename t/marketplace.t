#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 6;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->marketplace->get_categories,
['marketplace.getCategories'], 'get_categories calls correctly';
is_deeply $api->marketplace->get_subcategories,
['marketplace.getSubcategories'], 'get_subcategories calls correctly';
is_deeply $api->marketplace->get_listings,
['marketplace.getListings'], 'get_listings calls correctly';
is_deeply $api->marketplace->search,
['marketplace.search'], 'search calls correctly';
is_deeply $api->marketplace->create_listing,
['marketplace.createListing'], 'create_listing calls correctly';
is_deeply $api->marketplace->remove_listing,
['marketplace.removeListing'], 'remove_listing calls correctly';
