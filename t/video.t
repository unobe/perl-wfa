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

is_deeply $api->video->get_upload_limits,
['video.getUploadLimits'], 'get_upload_limits calls correctly';
is_deeply $api->video->has_app_permission,
['video.upload'], 'upload calls correctly';
