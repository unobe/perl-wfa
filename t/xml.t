#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN {
    if ( 3 != grep defined,
        @ENV{qw/WFA_API_KEY_TEST WFA_SECRET_KEY_TEST WFA_SESSION_KEY_TEST/} )
    {
        plan skip_all => 'Live tests require API key, secret, and session';
    }
    plan tests => 1;
}

my $api = WWW::Facebook::API->new(
    app_path => 'test',
    parse    => 1,
    format   => 'XML'
);

like $api->events->get,
    qr/\A<\?xml\sversion="1.0"\sencoding="UTF-8"\?>\s+<events_get_response/xms,
    'XML returned correctly with parse set to true';
