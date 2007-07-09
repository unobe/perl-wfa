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
is_deeply $api->fbml->refresh_img_src( src => '' ),
    [ 'fbml.refreshImgSrc', src => '' ],
    'refresh image source calls correctly';
is_deeply $api->fbml->refresh_ref_url( url => '' ),
    [ 'fbml.refreshRefUrl', url => '' ], 'refresh url source calls correctly';
is_deeply $api->fbml->set_ref_handle( handle => '', fbml => '' ),
    [ 'fbml.setRefHandle', handle => '', fbml => '' ],
    'set ref handle calls correctly';
