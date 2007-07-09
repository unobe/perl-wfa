#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
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
is_deeply $api->photos->add_tag(
    pid  => 1,
    tags => '[{"x":"30.0","y":"30.0","uid":1234567890}]'
    ),
    [
    'photos.addTag',
    pid  => 1,
    tags => '[{"x":"30.0","y":"30.0","uid":1234567890}]'
    ],
    'add_tag calls correctly';
is_deeply $api->photos->create_album(
    name        => 'Foo',
    location    => 'Bar',
    description => 'Baz'
    ),
    [
    'photos.createAlbum',
    name        => 'Foo',
    location    => 'Bar',
    description => 'Baz'
    ],
    'create_album calls correctly';
is_deeply $api->photos->get, ['photos.get'], 'get calls correctly';
is_deeply $api->photos->get_albums, ['photos.getAlbums'],
    'get_albums calls correctly';
is_deeply $api->photos->get_tags, ['photos.getTags'],
    'get_tags calls correctly';
is_deeply $api->photos->upload( data => 'foo' ),
    [ 'photos.upload', data => 'foo' ], 'upload calls correctly';
