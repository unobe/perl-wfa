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
is_deeply $api->admin->get_allocation( 
  integration_point_name => 'notifications_per_day' ),
  [ 'admin.getAllocation', integration_point_name => 'notifications_per_day'],
    'get_allocation calls correctly';

is_deeply $api->admin->get_metrics(
  start_time => 0, end_time => 0, period => 0,
  metrics => '["active_users", "canvas_page_views"]' ),
  [ 'admin.getMetrics',
  start_time => 0, end_time => 0, period => 0,
  metrics => '["active_users", "canvas_page_views"]' 
  ],
    'get_metrics calls correctly';

is_deeply $api->admin->get_app_properties( 
  properties => ["application_name","callback_url"] ),
  [ 'admin.getAppProperties',
    properties => ["application_name","callback_url"] ],
    'get_app_properties calls correctly';

is_deeply $api->admin->set_app_properties( ),
  [ 'admin.setAppProperties' ],
    'set_app_properties calls correctly';
