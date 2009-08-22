#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 6;
use WWW::Facebook::API;
use strict;
use warnings;


my $api = WWW::Facebook::API->new( app_path => 'test' );

# at least show the right method is being called.
{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}

is_deeply $api->events->cancel,
['events.cancel'], 'cancel calls correctly';
is_deeply $api->events->create,
['events.create'], 'create calls correctly';
is_deeply $api->events->edit,
['events.edit'], 'edit calls correctly';
is_deeply $api->events->rsvp,
['events.rsvp'], 'rsvp calls correctly';
is_deeply $api->events->get,
['events.get'], 'get calls correctly';
is_deeply $api->events->get_members,
['events.getMembers'], 'get_members calls correctly';
