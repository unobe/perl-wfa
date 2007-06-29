#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 23;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API'); }

my $api = WWW::Facebook::API->new( api_key => 1, secret => 1 );
isa_ok $api, 'WWW::Facebook::API';

@_ = ();
is $api->_add_url_params(
    next       => shift @_,
    canvas     => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0', 'url params test 1';

@_ = ( " hi ", 'test', 12 );
is $api->_add_url_params(
    next       => shift @_,
    canvas     => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0&auth_token=12&canvas=test&next=%20hi%20',
    'url params test 2';

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
