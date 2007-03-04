use Test::More tests => 13;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Events'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $events = WWW::Facebook::API::Events->new(
    base => $base, api_key => 1, secret => 1
);

{
    my $result = $events->get_in_window->{result}->[0];
    is $result->{method}, 'facebook.events.getInWindow', 'method correct';

    my @events_ids = @{$result->{result_elt}};
    is @events_ids, 2, 'num of elements correct for get_in_window';
    my %expect = (
        first => {
            name => 'Hackathon 3: Loyal to the Game',
            oid  => 'oXr5SfR1DoT9p7IXUyWhuig..',
            start_time => 1154055600,
            end_time   => 1154098800,
            attending => 'Attending',
        },
        second => {
            name => 'Summer House Luau',
            oid  => 'og9be-325j0jTSKcN_m8n6Q..',
            start_time => 1154228400,
            end_time   => 1154282400,
            attending => '',
        },
    );
    for my $item ( qw/first second/ ) {
        my $event = shift @events_ids;
        for my $field ( keys %{ $expect{$item} } ) {
            is $event->{$field}->[0], $expect{$item}{$field},
                "$item $field correct";
        }
    }
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.events.getInWindow" type="list">
  <result_elt type="struct">
    <name>Hackathon 3: Loyal to the Game</name>
    <oid>oXr5SfR1DoT9p7IXUyWhuig..</oid>
    <start_time>1154055600</start_time>
    <end_time>1154098800</end_time>
    <attending>Attending</attending>
  </result_elt>
  <result_elt type="struct">
    <name>Summer House Luau</name>
    <oid>og9be-325j0jTSKcN_m8n6Q..</oid>
    <start_time>1154228400</start_time>
    <end_time>1154282400</end_time>
    <attending></attending>
  </result_elt>
</result>
