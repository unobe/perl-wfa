#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN {
    if ( 3 != grep defined,
        @ENV{qw/WFA_API_KEY_TEST WFA_SECRET_TEST WFA_SESSION_KEY_TEST/} )
    {
        plan skip_all => 'Live tests require API key, secret, and session';
    }
    plan tests => 2;
}

my $api = WWW::Facebook::API->new( app_path => 'test' );
my $uid = $api->users->get_logged_in_user;
ok defined $api->data->set_cookie( uid => $uid, qw/name foo value bar/), 'Cookie created';
ok $api->data->get_cookies( uid => $uid, name => 'foo' ), 'Cookie retrieved';
