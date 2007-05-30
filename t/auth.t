#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
BEGIN {
    eval 'use Test::MockObject::Extends';
    if ($@) {
        plan skip_all => 'Tests require Test::MockObject::Extends';
    }
    plan tests => 5;
}
use WWW::Mechanize;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API::Auth'); }

my $base = WWW::Facebook::API->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
);

{
    local $/ = "\n\n";
    $base->mech->set_series('content', <DATA>);
}

my $auth = WWW::Facebook::API::Auth->new(
    base => $base, api_key => 1, secret => 1
);

{
    my $result = $auth->create_token->{auth_createToken_response}->[0];
    is $result->{content}, '3e4a22bb2f5ed75114b0fc9995ea85f1', 'token correct';
}

{
    my $result = $auth->get_session( auth_token => '8bd7eb80aef3778f2478921787d7e911' )
        ->{auth_getSession_response}->[0];
    is $result->{session_key}->[0], '5f34e11bfb97c762e439e6a5-8055', 'session key correct';
    is $result->{uid}->[0], '8055', 'uid correct';
    is $result->{expires}->[0], '1173309298', 'expires correct';
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<auth_createToken_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">3e4a22bb2f5ed75114b0fc9995ea85f1</auth_createToken_response>

<?xml version="1.0" encoding="UTF-8"?>
<auth_getSession_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
  <session_key>5f34e11bfb97c762e439e6a5-8055</session_key>
  <uid>8055</uid>
  <expires>1173309298</expires>
</auth_getSession_response>
