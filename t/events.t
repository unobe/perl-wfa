#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN {
    if ( 3 != grep defined,
        @ENV{qw/WFA_API_KEY_TEST WFA_SECRET_TEST WFA_SESSION_KEY_TEST/} )
    {
        plan skip_all => 'Live tests require API key, secret, and session';
    }
    plan tests => 2;
}

my $api = WWW::Facebook::API->new( app_path => 'test' );

my $events = $api->events->get;
is ref $events, 'ARRAY', 'get returns array ref';

SKIP: {
    skip 'No events to get members from' => 1 unless $events->[0]->{'eid'};
    is keys %{$api->events->get_members(eid => $events->[0]->{'eid'})}, 4,
    'four lists, as per API';
}
