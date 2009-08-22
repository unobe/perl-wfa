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
is_deeply $api->status->get( uid => 1234 ),
    [ 'status.get', uid => 1234 ],
    'get calls correctly';

is_deeply $api->status->set( uid => 1234 ),
    [ 'status.set', uid => 1234 ],
    'set calls correctly';
