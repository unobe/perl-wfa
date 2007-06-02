#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 9;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API'); }

my $api = WWW::Facebook::API->new( api_key => 1, secret => 1 );
isa_ok $api, 'WWW::Facebook::API::Base';
is $api->simple, 0, 'simple attribute set correctly';
{ # Test parse_params
    my $api = WWW::Facebook::API->new( api_key => 1, secret => 1 );
    is ref $api->parse_params, 'HASH', 'parse_params returns hash';
    is keys %{$api->parse_params}, 2, '2 keys for parse_params';
    for (qw/ForceArray KeepRoot/ ) {
        is exists $api->parse_params->{$_}, 1, "$_ exists in parse_params";
    }
    $api = WWW::Facebook::API->new( api_key => 1, secret => 1, parse_params => { ForceArray => 1 } );
    is keys %{$api->parse_params}, 1, '1 key for parse_params';
    is exists $api->parse_params->{'ForceArray'}, 1, "ForceArray exists in parse_params";
}
