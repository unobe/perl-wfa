use Test::More tests => 12;

BEGIN {
use_ok( 'WWW::Facebook::API' );
use_ok( 'WWW::Facebook::API::Base' );
use_ok( 'WWW::Facebook::API::Errors' );
use_ok( 'WWW::Facebook::API::Events' );
use_ok( 'WWW::Facebook::API::Auth' );
use_ok( 'WWW::Facebook::API::Login' );
use_ok( 'WWW::Facebook::API::Messages' );
use_ok( 'WWW::Facebook::API::Photos' );
use_ok( 'WWW::Facebook::API::Pokes' );
use_ok( 'WWW::Facebook::API::Users' );
use_ok( 'WWW::Facebook::API::Session' );
use_ok( 'WWW::Facebook::API::Friends' );
}

diag( "Testing WWW::Facebook::API $WWW::Facebook::API::VERSION" );
