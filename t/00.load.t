#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 14;

BEGIN {
use_ok( 'WWW::Facebook::API' );
use_ok( 'WWW::Facebook::API::Simple' );
use_ok( 'WWW::Facebook::API::Base' );
use_ok( 'WWW::Facebook::API::Errors' );
use_ok( 'WWW::Facebook::API::Events' );
use_ok( 'WWW::Facebook::API::Auth' );
use_ok( 'WWW::Facebook::API::Login' );
use_ok( 'WWW::Facebook::API::Groups' );
use_ok( 'WWW::Facebook::API::FQL' );
use_ok( 'WWW::Facebook::API::Photos' );
use_ok( 'WWW::Facebook::API::Update' );
use_ok( 'WWW::Facebook::API::Users' );
use_ok( 'WWW::Facebook::API::Notifications' );
use_ok( 'WWW::Facebook::API::Friends' );
}

diag( "Testing WWW::Facebook::API $WWW::Facebook::API::VERSION" );
