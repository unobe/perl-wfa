#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 36;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( api_key => 1, secret => 1,
session_uid => '', session_key => '', session_expires => '' );
isa_ok $api, 'WWW::Facebook::API';

for ( qw/require_frame require_login/ ) {
    eval { $api->$_ };
    like $@, qr/^Can't call method "param"/, "need query for $_";
}

# Test global environment settings
{
    local %ENV = %ENV;
    @ENV{ map { "WFA_$_" } qw/API_KEY SECRET DESKTOP/} = qw/3 2 1/;

    ## no warnings 'redefine' still warns... :-(
    local %WWW::Facebook::API::;
    delete @INC{ grep { m[^WWW/Facebook/API]xms } keys %INC};
    require WWW::Facebook::API;
    
    my $api = WWW::Facebook::API->new( app_path => 'hey' );
    is $api->api_key, 3, 'WFA_API_KEY ok';
    is $api->secret, 2, 'WFA_SECRET ok';
    is $api->desktop, 1, 'WFA_DESKTOP ok';
}

# Test app-specific environment settings
{
    local %ENV = %ENV;
    @ENV{ map { "WFA_${_}_TEST_ME" } qw/API_KEY SECRET DESKTOP/} = qw/3 2 1/;
    my $api = WWW::Facebook::API->new( app_path => 'test-me' );
    is $api->api_key, 3, 'WFA_API_KEY_TEST_ME ok';
    is $api->secret, 2, 'WFA_SECRET_TEST_ME ok';
    is $api->desktop, 1, 'WFA_DESKTOP_TEST_ME ok';
}

is $api->$_, '', "$_ init ok" for qw(session_uid session_key session_expires);

my %final_session = (
    uid     => 22343,
    expires => 2343423,
    key     => 'cd324235fe34353',
);
$api->session(%final_session);
for ( keys %final_session ) {
    is eval "\$api->session_$_", $final_session{$_}, "session_$_ set ok";
}

my @escaped = ( '\"hell\nhath\nno\nfury\"' => qq("hell\nhath\nno\nfury") );
is $api->unescape_string( $escaped[0] ), $escaped[1], 'unescape_string ok';

is $api->get_facebook_url, 'http://www.facebook.com', 'get_facebook_url ok';
is $api->get_facebook_url('apps'), 'http://apps.facebook.com',
    'get_facebook_url arg ok';

is $api->_add_url_params, '?api_key=1&v=1.0', '_add_url_params ok';
is $api->_add_url_params( auth_token => 'efdb34342ef' ),
    '?api_key=1&v=1.0&auth_token=efdb34342ef', '_add_url_params arg ok';
is $api->_add_url_params( next => '" woot "' ),
    '?api_key=1&v=1.0&next=%22%20woot%20%22',
    '_add_url_params next escapes ok';

is $api->get_add_url, 'http://www.facebook.com/add.php?api_key=1&v=1.0',
    'get_add_url ok';
is $api->get_login_url, 'http://www.facebook.com/login.php?api_key=1&v=1.0',
    'get_login_url ok';

is $api->apps_uri, 'http://apps.facebook.com/', 'apps_uri ok';
is $api->app_path, '', 'app_path ok';
$api->app_path('foo');
is $api->app_path, 'foo', 'app_path set ok';
is $api->get_app_url, 'http://apps.facebook.com/foo/', 'get_app_url ok';

# test for passing undef (shouldn't reset value)
$api->app_path(undef);
is $api->app_path, 'foo', 'app_path not reset';

## sig stuff
my %sig_params = ( params => { method => 'hi' }, secret => 'cool' );
my $sig = '54b12be659505fa965d7fcee080c32ee';
is $api->generate_sig( %sig_params ), $sig, 'sig generate ok';
is $api->verify_sig( sig => $sig, %sig_params ), 1, 'sig verify 1 ok';
$api->secret(delete $sig_params{'secret'});
is $api->verify_sig( sig => $sig, %sig_params ), 1, 'sig verify 2 ok';
$api->secret('');
is $api->verify_sig( sig => $sig, %sig_params ), '', 'sig verify 3 nok';

# call method
{
    no warnings 'redefine';
    local $WWW::Facebook::API::{_post_request} = sub { return qq{"$_[2]"} };
    my $args = { params => { method => 'hello', secret => 'foo' } };
    my $secret = $api->call( 'hey', %$args );
    isnt $secret, $api->secret, 'secret not object\'s';
    is  $secret, $args->{'params'}->{'secret'}, 'secret is param\'s';
    is $args->{'params'}->{'method'}, 'facebook.hello', 'call method changed';
    eval q{use IO::String};
    SKIP: {
        skip 'Need IO::String to test debug output' => 1 if $@;

        my ($old_stderr, $new_stderr) = redirect_fh(*STDERR);
        *STDERR = $new_stderr;
        $api->debug(1);
        $secret = $api->call( 'hey', %$args );
        $api->debug(0);
        seek($new_stderr, 0, 0);
        my $debug = join '', <$new_stderr>;
        *STDERR = $old_stderr;
        like $debug, <<'END_DEBUG', 'debug string ok';
/\s*params\s=\s*
       api_key:1\s*
       format:JSON\s*
       method:facebook.facebook.hello\s*
       secret:foo\s*
       session_key:cd324235fe34353\s*
       sig:54c540e9324e6daf895c120736c9ac59\s*
       v:1.0\s*
 response\s=\s*
 "foo"\s*
(?-x: at [^\ ]+ line \d+
JSON::Any is parsing with [^\ ]+ at [^\ ]+ line \d+)/xms
END_DEBUG

    }
}

sub redirect_fh {
    my $old = select shift;
    my $new = IO::String->new;
    return ( $old, $new );
}
