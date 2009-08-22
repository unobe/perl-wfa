#######################################################################
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

is_deeply $api->fbml->delete_custom_tags( names => [1,2,3] ),
    [ 'fbml.deleteCustomTags', names => [1,2,3] ],
    'delete_custom_tags calls correctly';
is_deeply $api->fbml->get_custom_tags( app_id => '123' ),
    [ 'fbml.getCustomTags', app_id => '123' ],
    'get_custom_tags calls correctly';
is_deeply $api->fbml->register_custom_tags( tags => 'json' ),
    [ 'fbml.registerCustomTags', tags => 'json' ],
    'register_custom_tags calls correctly';
is_deeply $api->fbml->refresh_img_src( src => '' ),
    [ 'fbml.refreshImgSrc', src => '' ],
    'refresh image source calls correctly';
is_deeply $api->fbml->refresh_ref_url( url => '' ),
    [ 'fbml.refreshRefUrl', url => '' ], 'refresh url source calls correctly';
is_deeply $api->fbml->set_ref_handle( handle => '', fbml => '' ),
    [ 'fbml.setRefHandle', handle => '', fbml => '' ],
    'set ref handle calls correctly';
