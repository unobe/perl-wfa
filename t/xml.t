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
    plan tests => 4;
}

my $api = WWW::Facebook::API->new(
    app_path => 'test',
    parse    => 1,
    format   => 'XML'
);

SKIP: {
    eval q{use Test::Warn};
    skip 'Test::Warn required' => 1 if $@;
    no warnings 'redefine';
    local $WWW::Facebook::API::{log_string} = sub {q{}};
    $api->debug(1);
    warnings_are ( sub { $api->events->get },
    [ q{}, 'format is XML: setting parse to 0' ],
        'warning thrown and is correct');
    $api->debug(0);
}

$api->parse(1);
like $api->events->get,
    qr/\A<\?xml\sversion="1.0"\sencoding="UTF-8"\?>\s+<events_get_response/xms,
    'XML returned correctly with parse set to true';

is $api->parse, 0, 'parse set to false';

like $api->events->get,
    qr/\A<\?xml\sversion="1.0"\sencoding="UTF-8"\?>\s+<events_get_response/xms,
    'XML returned correctly with parse set to false';
