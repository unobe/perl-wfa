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
    *WWW::Facebook::API::call = sub {
        shift; my $call = shift;
        my %h = @_; return [$call, %h]
    };
}

is_deeply $api->video->get_upload_limits,
['video.getUploadLimits'], 'get_upload_limits calls correctly';
is_deeply $api->video->upload,
['video.upload', format => 'JSON' ], 'upload calls correctly';
is_deeply $api->video->upload(format => 'JSON'),
['video.upload', format => 'JSON' ], 'JSON upload calls correctly';
is_deeply $api->video->upload(format => 'XML'),
['video.upload', format => 'XML' ], 'XML upload calls correctly';
