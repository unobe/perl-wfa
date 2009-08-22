#######################################################################
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

my $groups = $api->groups->get;
is ref $groups, 'ARRAY', 'get returns array ref';

SKIP: {
    skip 'No groups to get members from' => 1 unless $groups->[0]->{'gid'};
    is keys %{$api->groups->get_members(gid => $groups->[0]->{'gid'})}, 4,
    'four lists, as per API';
}
