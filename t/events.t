#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 6;
use WWW::Facebook::API;
use strict;
use warnings;


my $api = WWW::Facebook::API->new( app_path => 'test' );

my $events = $api->events->get;
is ref $events, 'ARRAY', 'get returns array ref';

SKIP: {
    skip 'No events to get members from' => 1 unless $events->[0]->{'eid'};
    is keys %{$api->events->get_members(eid => $events->[0]->{'eid'})}, 4,
    'four lists, as per API';
}

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
['events.get_members'], 'get_members calls correctly';
