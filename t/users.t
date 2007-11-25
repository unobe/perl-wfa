#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 5;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->users->get_logged_in_user,
['users.getLoggedInUser'], 'get_logged_in_user calls correctly';
is_deeply $api->users->get_info,
['users.getInfo'], 'get_info calls correctly';
is_deeply $api->users->has_app_permission,
['users.hasAppPermission'], 'has_app_permission calls correctly';
is_deeply $api->users->is_app_added,
['users.isAppAdded'], 'is_app_added calls correctly';
is_deeply $api->users->set_status,
['users.setStatus'], 'set_status calls correctly';
