use Test::More tests => 6;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Messages'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $messages = WWW::Facebook::API::Messages->new(
    base => $base, api_key => 1, secret => 1
);

my $expect = {
    get_count => {
        method => 'getCount',
        type   => 'struct',
        result => {
            unread => 0,
            total  => 182,
            most_recent => 1161126800,
        },
    },
};

for my $meth ( qw/get_count/ ) {
    my $result =
        $messages->$meth( @{ $expect->{$meth}->{'args'} } )->{'result'}->[0];

    is $result->{'method'}, "facebook.messages.$expect->{$meth}->{'method'}",
        "method '$meth' correct";
    
    is $result->{'type'}, $expect->{$meth}->{'type'}, 'type correct';

    for ( keys %{ $expect->{$meth}->{'result'} } ) {
        is $result->{$_}->[0], $expect->{$meth}->{'result'}->{$_};
    }
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.messages.getCount" type="struct">
  <unread>0</unread>
  <total>182</total>
  <most_recent>1161126800</most_recent>
</result>
