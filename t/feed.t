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
is_deeply $api->feed->publish_story_to_user( title => '' ),
    [ 'feed.publishStoryToUser', title => '' ],
    'publish_story_to_user calls correctly';
is_deeply $api->feed->publish_action_of_user( title => '' ),
    [ 'feed.publishActionOfUser', title => '' ],
    'publish_action_of_user calls correctly';
is_deeply $api->feed->publish_templatized_action( actor_id => 2, title_template => '' ),
    [ 'feed.publishTemplatizedAction', actor_id => 2, title_template => '' ],
    'publish_templatized_action calls correctly';
