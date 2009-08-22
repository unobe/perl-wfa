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

is_deeply $api->notifications->get, ['notifications.get'], 'get calls correctly';
is_deeply $api->notifications->get_list, ['notifications.getList'], 'get_list calls correctly';
is_deeply $api->notifications->mark_read, ['notifications.markRead'],
    'mark_read calls correctly';
is_deeply $api->notifications->send, ['notifications.send'],
    'send calls correctly';
is_deeply $api->notifications->send_email, ['notifications.sendEmail'],
    'send_email calls correctly';
