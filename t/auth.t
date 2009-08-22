#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;

# Tries use subs 'system', but after use WWW::Facebook::API, didn't work :-(
# May have something to do with autogenerating WWW::Facebook::API::* in
# API.pm? Anyway, this is needed for testing WWW::Facebook::API::Auth->login
BEGIN { *CORE::GLOBAL::system = sub { 0 }; }

use WWW::Facebook::API;
use strict;
use warnings;

BEGIN {
    eval 'use Test::MockObject::Extends';
    if ($@) {
        plan skip_all => 'Tests require Test::MockObject::Extends';
    }
    plan tests => 16;
}

my $api = Test::MockObject::Extends->new(
    WWW::Facebook::API->new(
        api_key        => 1,
        secret         => 1,
        parse_response => 1,
        desktop        => 1,
    ),
);

{
    local $/ = "\n\n";
    $api->set_series( '_post_request', <DATA> );
}

my $auth = WWW::Facebook::API::Auth->new( base => $api );

my $token = $auth->create_token;
is $token, '3e4a22bb2f5ed75114b0fc9995ea85f1', 'token correct';

$auth->get_session($token);
is $api->session_key, '5f34e11bfb97c762e439e6a5-8055', 'session key correct';
is $api->session_uid, '8055', 'uid correct';
is $api->session_expires, '1173309298',        'expires correct';
is $api->secret,          '23489234289342389', 'secret correct';

eval { $auth->get_session; };
ok $@, 'token needed';

$api->desktop(0);
$token = $auth->create_token;
is $token, '4358934543983b234c4389ef45489456', '!desktop token correct';

$auth->get_session($token);
is $api->session_key, '3453498345945943ca343834-4323', '!desktop session key correct';
is $api->session_uid, '34333', '!desktop uid correct';
is $api->session_expires, '1283218372187',        '!desktop expires correct';
is $api->secret,          '23489234289342389', '!desktop secret unchanged';

eval { $auth->login; };
ok $@, q{can't use login with web app};

$api->desktop(1);
if ($^O =~ /darwin|MSWin/ ) {
    diag q{Sleeping for a bit (so don't fret)...};
    is $auth->login, '3e4a22bb2f5ed75114b0fc9995ea85f1', 'login default sleep ok';
}
else {
    eval { $auth->login; };
    diag $@;
    like $@, qr/open browser/, 'login default can\'t open browser';
}

my $start_time = time;
is $auth->login( sleep => 1, browser => 'dummy' ), '4358934543983b234c4389ef45489456', 'login set sleep ok';
ok time() - $start_time, 'did sleep';


ok $auth->can('logout'), 'logout works';

__DATA__
"3e4a22bb2f5ed75114b0fc9995ea85f1"

{"session_key":"5f34e11bfb97c762e439e6a5-8055","uid":"8055","expires":1173309298,"secret":"23489234289342389"}

"4358934543983b234c4389ef45489456"

{"session_key":"3453498345945943ca343834-4323","uid":"34333","expires":1283218372187,"secret":"344893458934598"}

"3e4a22bb2f5ed75114b0fc9995ea85f1"

"4358934543983b234c4389ef45489456"
