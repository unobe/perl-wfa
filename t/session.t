use Test::More tests => 4;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Session'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $session = WWW::Facebook::API::Session->new(
    base => $base, api_key => 1, secret => 1
);

my $expect = {
    ping => {
        method => 'ping',
        args   => [],
        type   => undef,
        result => 'true',
    },
};

for my $meth ( qw/ping/ ) {
    my $result =
        $session->$meth( @{ $expect->{$meth}->{'args'} } )->{'result'}->[0];

    is $result->{'method'}, "facebook.session.$expect->{$meth}->{'method'}",
        "method '$meth' correct";
    
    is $result->{'type'}, $expect->{$meth}->{'type'}, 'type correct';

    is $result->{'content'}, $expect->{$meth}->{'result'};
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.session.ping">true</result>
