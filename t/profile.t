#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN {
    if ( 3 != grep defined,
        @ENV{qw/WFA_API_KEY_TEST WFA_SECRET_TEST WFA_SESSION_KEY_TEST/} )
    {
        plan skip_all => 'Live tests require API key, secret, and session';
    }
    plan tests => 3;
}

my $api = WWW::Facebook::API->new( app_path => 'test' );

my $fbml_orig = $api->profile->get_fbml();
my $time      = time();
ok $api->profile->set_fbml( markup => $time ), 'set fbml';
like $api->profile->get_fbml(), qr{\A <fb:fbml [^>]+ >$time</fb:fbml> \z }xms,
    'get fbml';
ok $api->profile->set_fbml( markup => $fbml_orig ), 'reset fmbl';
