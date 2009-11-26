#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 10;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}
is_deeply $api->stream->add_comment(),
    [ 'stream.addComment' ], 'add_comment calls correctly';

is_deeply $api->stream->add_like(),
    [ 'stream.addLike' ], 'add_like calls correctly';

is_deeply $api->stream->get(),
    [ 'stream.get' ], 'get calls correctly';

is_deeply $api->stream->get_comments(),
    [ 'stream.getComments' ], 'get_comments calls correctly';

is_deeply $api->stream->get_filters(),
    [ 'stream.getFilters' ], 'get_filters calls correctly';

is_deeply $api->stream->publish(),
    [ 'stream.publish' ], 'publish calls correctly';
is_deeply $api->stream->publish( action_links => [qw/book cow/] ),
    [ 'stream.publish', 'action_links' => '["book","cow"]' ], 'publish with action_links calls correctly';

is_deeply $api->stream->remove(),
    [ 'stream.remove' ], 'remove calls correctly';

is_deeply $api->stream->remove_comment(),
    [ 'stream.removeComment' ], 'remove_comment calls correctly';

is_deeply $api->stream->remove_like(),
    [ 'stream.removeLike' ], 'remove_like calls correctly';
