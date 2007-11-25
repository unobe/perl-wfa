#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 4;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->pages->get_info,
['pages.getInfo'], 'get_info calls correctly';
is_deeply $api->pages->is_app_added,
['pages.isAppAdded'], 'is_app_added calls correctly';
is_deeply $api->pages->is_admin,
['pages.isAdmin'], 'is_admin calls correctly';
is_deeply $api->pages->is_fan,
['pages.isFan'], 'is_fan calls correctly';
