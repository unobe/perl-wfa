#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 2;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}
is_deeply $api->sms->can_send( uid => 1234 ),
    [ 'sms.canSend', uid => 1234 ],
    'can_send calls correctly';

is_deeply $api->sms->send( uid => 1234 ),
    [ 'sms.send', uid => 1234 ],
    'send calls correctly';

