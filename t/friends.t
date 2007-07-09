#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 3;
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
