#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 19;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( api_key => 1, secret => 2 );

@_ = ();
is $api->_add_url_params(
    next       => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0', 'url params test 1';

@_ = ( ' hi ', 12 );
is $api->_add_url_params(
    'canvas',
    next       => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0&canvas&auth_token=12&next=%20hi%20',
    'url params test 2';

@_ = ( ' hi ', 'test', 12 );
is $api->_add_url_params(
    next       => shift @_,
    canvas      => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0&canvas&auth_token=12&next=%20hi%20',
    'url params test 3';

@_ = ();
is $api->_add_url_params(
    next       => shift @_,
    canvas      => shift @_,
    auth_token => shift @_
    ),
    '?api_key=1&v=1.0',
    'url params test 4';


my $params;
$api->desktop(1);
$params = { method => 'auth.hi' };
$api->_check_values_of( $params );
is keys %$params, 5, 'params amount';
ok !exists $params->{'session_key'}, 'session key not set';
is $params->{'method'}, 'facebook.auth.hi', 'method changed';
ok $params->{'call_id'}, 'call_id added';
is $params->{'v'}, '1.0', 'version added';
is $params->{'api_key'}, 1, 'api_key added';
is $params->{'format'}, 'JSON', 'format added';

$api->desktop(0);
my $time = time();
$params = { call_id => $time, method => 'hello' };
$api->_check_values_of( $params );
is $params->{'method'}, 'facebook.hello', 'method changed again';
is $params->{'call_id'}, $time, 'time not reset';
is $params->{'session_key'}, q{}, 'session key set from object\'s value';
ok !exists $params->{'callback'}, 'callback not set';

# Mostly just testing that session_key's passed in value is kept...
$params = { method => 'hello2', session_key => 'foo' };
$api->_check_values_of( $params );
is $params->{'method'}, 'facebook.hello2', 'method changed again';
is $params->{'session_key'}, q{foo}, 'session key not changed';
ok !exists $params->{'callback'}, 'callback not set';

$api->callback('/new_info');
$params = { call_id => $time, method => 'fun' };
$api->_check_values_of( $params );
is $params->{'callback'}, '/new_info', 'callback set';
