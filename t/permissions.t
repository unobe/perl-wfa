#######################################################################
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

is_deeply $api->permissions->grant_api_access(
    permissions_apikey => 'otherappkey',
    method_arr => '["admin."]' ),
    [
        'permissions.grantApiAccess',
        permissions_apikey => 'otherappkey',
        method_arr => '["admin."]'
    ],
    'grant_api_access calls correctly';

is_deeply $api->permissions->check_available_api_access( 
    permissions_apikey => 'masterappkey' ),
    [
        'permissions.checkAvailableApiAccess',
        permissions_apikey => 'masterappkey'
    ],
    'check_available_api_access calls correctly';

is_deeply $api->permissions->revoke_api_access(
    permissions_apikey => 'revokedappkey' ),
    [
        'permissions.revokeApiAccess',
        permissions_apikey => 'revokedappkey'
    ],
    'revoke_api_access calls correctly';

is_deeply $api->permissions->check_granted_api_access(
    permissions_apikey => 'otherappkey' ),
    [
        'permissions.checkGrantedApiAccess',
        permissions_apikey => 'otherappkey'
    ],
    'check_granted_api_access calls correctly';
