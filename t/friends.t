use Test::More tests => 28;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Friends'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $friends = WWW::Facebook::API::Friends->new(
    base => $base, api_key => 1, secret => 1
);

{
    is eval {$friends->get_typed->{'result'}->[0]}, undef,
        "argument needed: link type";
    like $@, '/^link type required/', "link type error message correct";
}

my $expect = {
    get => {
        method => 'get',
        type   => 'list',
        result => [
            'iPF_ahrjO4z3fpYh8-ySIMA..',
            'iNKaODV1u8Aq1HNcGvfk27w..',
        ],
    },
    get_app_users => {
        method  => 'getAppUsers',
        args    => [],
        type    => 'list',
        result => [
            'iPF_ahrjO4z3fpYh8-ySIMA..',
            'iNKaODV1u8Aq1HNcGvfk27w..',
        ],
    },
    get_requests => {
        method  =>  'getRequests',
        args    =>  [],
        type    => 'list',
        result => [
            'iPF_ahrjO4z3fpYh8-ySIMA..',
            'iNKaODV1u8Aq1HNcGvfk27w..',
        ],
    },
    get_typed => {
        method  => 'getTyped',
        args    => [ 'LIVED' ],
        type    => 'list',
        result => [
            'i9MrePeIUZxk.',
            'iEbreE8U_f5E.',
        ],
    },
    are_friends => {
        method  => 'areFriends',
        args    => [ [12, 13], [13, 15] ],
        type    => 'list',
        result => [
            1,
            0,
        ],
    },
};

for my $meth ( qw/get get_app_users get_requests get_typed are_friends/ ) {
    my $result =
        $friends->$meth( @{ $expect->{$meth}->{'args'} } )->{'result'}->[0];

    is $result->{'method'}, "facebook.friends.$expect->{$meth}->{'method'}",
        "method '$meth' correct";
    
    is $result->{'type'}, $expect->{$meth}->{'type'}, 'type correct';

    is +@{ $result->{'result_elt'} }, +@{ $expect->{$meth}->{'result'} },
        "num of elements correct for $meth";

    for ( @{ $result->{'result_elt'} } ) {
        is $_, shift @{ $expect->{$meth}->{'result'} };
    }
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.friends.get" type="list">
  <result_elt>iPF_ahrjO4z3fpYh8-ySIMA..</result_elt>
  <result_elt>iNKaODV1u8Aq1HNcGvfk27w..</result_elt>
</result>

<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.friends.getAppUsers" type="list">
  <result_elt>iPF_ahrjO4z3fpYh8-ySIMA..</result_elt>
  <result_elt>iNKaODV1u8Aq1HNcGvfk27w..</result_elt>
</result>

<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.friends.getRequests" type="list">
  <result_elt>iPF_ahrjO4z3fpYh8-ySIMA..</result_elt>
  <result_elt>iNKaODV1u8Aq1HNcGvfk27w..</result_elt>
</result>

<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.friends.getTyped" type="list">
  <result_elt>i9MrePeIUZxk.</result_elt>
  <result_elt>iEbreE8U_f5E.</result_elt>
</result>

<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.friends.areFriends" type="list">
  <result_elt>1</result_elt>
  <result_elt>0</result_elt>
</result>
