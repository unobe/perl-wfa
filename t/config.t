#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 8;
use WWW::Facebook::API;
use strict;
use warnings;

local %ENV;
my $api = WWW::Facebook::API->new;
for ( qw/api_key secret desktop session_key/ ) {
    is $api->$_, '', "$_ initialized";
}

my $fn = 'wfa';
open my $file, '>', $fn or die "Cannot write to '$fn'";
print { $file } <<"END_CONFIG";
WFA_API_KEY=1
WFA_SECRET=2
WFA_SESSION_KEY=3
WFA_DESKTOP=4   
END_CONFIG
close $file;

$api = WWW::Facebook::API->new( config => 'wfa' );
is $api->api_key, 1, 'api_key set';
is $api->secret, 2, 'secret set';
is $api->session_key, 3, 'session_key set';
is $api->desktop, 4, 'desktop set';

unlink 'wfa';
