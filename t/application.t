#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 1;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}
is_deeply $api->application->get_public_info( application_id => 1234 ),
    [ 'Application.getPublicInfo', application_id => 1234 ],
    'get_public_info calls correctly';

