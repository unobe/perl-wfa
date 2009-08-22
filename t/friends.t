#######################################################################
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
is_deeply $api->friends->get, ['friends.get'], 'get calls correctly';
is_deeply $api->friends->get_app_users, ['friends.getAppUsers'],
    'get_app_users calls correctly';
is_deeply $api->friends->are_friends( uids1 => 'a', uids2 => 'b' ),
    [ 'friends.areFriends', uids1 => 'a', uids2 => 'b' ],
    'are_friends calls correctly';
is_deeply $api->friends->get_lists( flid => '223324' ),
    [ 'friends.getLists', flid => '223324' ],
    'get_lists calls correctly';
is_deeply $api->friends->get_mutual_friends( target_id => '223324' ),
    [ 'friends.getMutualFriends', target_id => '223324' ],
    'get_mutual_friends calls correctly';
