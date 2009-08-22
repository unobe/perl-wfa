#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 5;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->feed->publish_templatized_action( actor_id => 2, title_template => '' ),
    [ 'feed.publishTemplatizedAction', actor_id => 2, title_template => '' ],
    'publish_templatized_action calls correctly';
is_deeply $api->feed->deactivate_template_bundle,
    [ 'feed.deactivateTemplateBundleById' ],
    'deactivate_template_bundle calls correctly';
is_deeply $api->feed->publish_user_action,
    [ 'feed.publishUserAction' ],
    'publish_user_action calls correctly';
is_deeply $api->feed->get_registered_template_bundle,
    [ 'feed.getRegisteredTemplateBundles' ],
    'get_registered_template_bundle calls correctly';
is_deeply $api->feed->get_registered_template_bundle( template_bundle_id => 1 ),
    [ 'feed.getRegisteredTemplateBundleById', template_bundle_id => 1 ],
    'get_registered_template_bundle calls correctly';
