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
is_deeply $api->notes->create, ['notes.create'], 'create calls correctly';
is_deeply $api->notes->delete, ['notes.delete'], 'delete calls correctly';
is_deeply $api->notes->edit, ['notes.edit'], 'edit calls correctly';
is_deeply $api->notes->get, ['notes.get'], 'get calls correctly';
