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
    plan tests => 6;
}
use WWW::Mechanize;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API::Auth'); }

my $api = WWW::Facebook::API->new(
    api_key => 1,
    secret  => 1,
    mech    => Test::MockObject::Extends->new(WWW::Mechanize->new()),
    parse_response => 1,
    desktop => 1,
);

{
    local $/ = "\n\n";
    $api->mech->set_series('content', <DATA>);
}

my $auth = WWW::Facebook::API::Auth->new( base => $api );

my $token = $auth->create_token;
is $token, '3e4a22bb2f5ed75114b0fc9995ea85f1', 'token correct';

$auth->get_session( $token );
is $api->session_key, '5f34e11bfb97c762e439e6a5-8055', 'session key correct';
is $api->session_uid, '8055', 'uid correct';
is $api->session_expires, '1173309298', 'expires correct';
is $api->secret, '23489234289342389', 'secret correct';

__DATA__
"3e4a22bb2f5ed75114b0fc9995ea85f1"

{"session_key":"5f34e11bfb97c762e439e6a5-8055","uid":"8055","expires":1173309298,"secret":"23489234289342389"}
