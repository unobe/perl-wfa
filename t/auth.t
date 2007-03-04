use Test::More tests => 8;
use Test::MockObject::Extends;
use WWW::Mechanize;
use WWW::Facebook::API::Base;
use strict;
use warnings;


BEGIN { use_ok('WWW::Facebook::API::Auth'); }

my $base = WWW::Facebook::API::Base->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);
$/ = "\n\n";
$base->mech->set_series('content', <DATA>);

my $auth = WWW::Facebook::API::Auth->new(
    base => $base, api_key => 1, secret => 1
);

{
    my $result = $auth->create_token->{result}->[0];
    is $result->{method}, 'facebook.auth.createToken', 'method correct';
    is $result->{token}->[0], '3e4a22bb2f5ed75114b0fc9995ea85f1', 'token correct';

}

{
    is eval { $auth->get_session->{result}->[0] }, undef,
        "auth token needed";
    like $@, '/^auth token required/', "auth token error message";

    my $result = $auth->get_session('8bd7eb80aef3778f2478921787d7e911')->{result}->[0];
    is $result->{method}, 'facebook.auth.getSession', 'method correct';
    is $result->{session_key}->[0], '5f34e11bfb97c762e439e6a5-8055', 'session key correct';
    is $result->{uid}->[0], '8055', 'uid correct';

}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<auth_createToken_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">3e4a22bb2f5ed75114b0fc9995ea85f1</auth_createToken_response>

<?xml version="1.0" encoding="UTF-8"?>
<auth_getSession_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
  <session_key>5f34e11bfb97c762e439e6a5-8055</session_key>
  <uid>8055</uid>
</auth_getSession_response>
