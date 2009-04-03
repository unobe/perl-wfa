#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

use WWW::Facebook::API;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->permissions->grant_api_access(
    permissions_apikey => 'otherappkey',
    method_arr => '["admin."]' ),
    [
        'Permissions.grantApiAccess',
        permissions_apikey => 'otherappkey',
        method_arr => '["admin."]'
    ],
    'grant_api_access calls correctly';

is_deeply $api->permissions->check_available_api_access( 
    permissions_apikey => 'masterappkey' ),
    [
        'Permissions.checkAvailableApiAccess',
        permissions_apikey => 'masterappkey'
    ],
    'check_available_api_access calls correctly';

is_deeply $api->permissions->revoke_api_access(
    permissions_apikey => 'revokedappkey' ),
    [
        'Permissions.revokeApiAccess',
        permissions_apikey => 'revokedappkey'
    ],
    'revoke_api_access calls correctly';

is_deeply $api->permissions->check_granted_api_access(
    permissions_apikey => 'otherappkey' ),
    [
        'Permissions.checkGrantedApiAccess',
        permissions_apikey => 'otherappkey'
    ],
    'check_granted_api_access calls correctly';
