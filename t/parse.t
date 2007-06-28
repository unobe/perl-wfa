#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 12;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API'); }

my $api = WWW::Facebook::API->new( api_key => 1, secret => 1 );
isa_ok $api, 'WWW::Facebook::API';

for ( map { ( qq{"$_"}, $_ ) } q{true}, q{1} ) {
    is $api->_parse($_), 1, "no ref true returns correct";
}
for ( map { ( qq{"$_"}, $_ ) } q{false}, q{0}, q{} ) {
    is $api->_parse($_), 0, "no ref false returns correct";
}
