#######################################################################
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

is_deeply $api->users->get_logged_in_user,
['users.getLoggedInUser'], 'get_logged_in_user calls correctly';
is_deeply $api->users->get_info,
['users.getInfo'], 'get_info calls correctly';
is_deeply $api->users->has_app_permission,
['users.hasAppPermission'], 'has_app_permission calls correctly';
is_deeply $api->users->is_app_user,
['users.isAppUser'], 'is_app_user calls correctly';
is_deeply $api->users->set_status,
['users.setStatus'], 'set_status calls correctly';
is_deeply $api->users->is_verified,
['users.isVerified'], 'is_verified calls correctly';
