use Test::More tests => 5;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Pokes'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $pokes = WWW::Facebook::API::Pokes->new(
    base => $base, api_key => 1, secret => 1
);

my $expect = {
    get_count => {
        method => 'getCount',
        type   => 'struct',
        result => {
            unseen => 1,
            total  => 63,
        },
    },
};

for my $meth ( qw/get_count/ ) {
    my $result =
        $pokes->$meth( @{ $expect->{$meth}->{'args'} } )->{'result'}->[0];

    is $result->{'method'}, "facebook.pokes.$expect->{$meth}->{'method'}",
        "method '$meth' correct";
    
    is $result->{'type'}, $expect->{$meth}->{'type'}, 'type correct';

    for ( keys %{ $expect->{$meth}->{'result'} } ) {
        is $result->{$_}->[0], $expect->{$meth}->{'result'}->{$_};
    }
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.pokes.getCount" type="struct">
  <unseen>1</unseen>
  <total>63</total>
</result>
