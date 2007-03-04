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

    
    is $result->{token}->[0], '8bd7eb80aef3778f2478921787d7e911', 'token correct';

}

{
    is eval { $auth->get_session->{result}->[0] }, undef,
        "auth token needed";
    like $@, '/^auth token required/', "auth token error message";

    my $result = $auth->get_session('8bd7eb80aef3778f2478921787d7e911')->{result}->[0];
    is $result->{method}, 'facebook.auth.getSession', 'method correct';
    is $result->{session_key}->[0], 'f480f33c7927939f49b761f1-iDnIuRVGi6TwnYvgP-9yvqA..',
        'session key correct';
    is $result->{uid}->[0], 'i1eBQSkwz3UQ.', 'uid correct';

}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.auth.createToken" type="struct">
  <token>8bd7eb80aef3778f2478921787d7e911</token>
</result>

<?xml version="1.0" encoding="UTF-8"?>
<result method="facebook.auth.getSession" type="struct">
  <session_key>f480f33c7927939f49b761f1-iDnIuRVGi6TwnYvgP-9yvqA..</session_key>
  <uid>i1eBQSkwz3UQ.</uid>
</result>
