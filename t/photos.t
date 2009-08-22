#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 9;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    local *WWW::Facebook::API::call = sub { shift; return [@_] };
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
    
}

SKIP: {
    if ( 3 != grep defined,
        @ENV{qw/WFA_API_KEY_TEST WFA_SECRET_TEST WFA_SESSION_KEY_TEST/} ) {
        skip 'Live tests require API key, secret, and session' => 3;
    }

    use File::Spec::Functions 'catfile';
    open my $file, '<:raw', catfile('t', 'upload.jpg') or die "Unable to open image file";
    local $/ = undef;
    my $data = <$file>;
    close $file;

    my $resp = $api->photos->upload( data => $data );
    for ( qw(aid pid owner) ) {
        ok exists $resp->{$_}, "Storable value for $_ returned";
    }
}
