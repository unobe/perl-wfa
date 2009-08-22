#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 1;
use WWW::Facebook::API;
use strict;
use warnings;

my $api = WWW::Facebook::API->new( app_path => 'test' );

{
    no warnings 'redefine';
    *WWW::Facebook::API::call = sub { shift; return [@_] };
}
is_deeply $api->intl->get_translations, ['intl.getTranslations'], 'get_translations calls correctly';
