#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;

BEGIN {
    eval 'use Test::MockObject::Extends';
    if ($@) {
        plan skip_all => 'Tests require Test::MockObject::Extends';
    }
    plan 'no_plan';
}

use CGI;
use WWW::Facebook::API;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API::Canvas'); }

my $api = WWW::Facebook::API->new(
        api_key        => 1,
        secret         => 1,
        desktop        => 1,
);

my $q = Test::MockObject::Extends->new(
    CGI->new
);
$q->set_list('param', map { chomp; $_ } <DATA>);
my $fb_params = $api->canvas->get_fb_params($q);

use Data::Dumper;
diag Dumper $fb_params;
is keys %$fb_params, 2, 'keys correct';

__DATA__
fb_sig_user
1003303
fb_sig_time
1293012319023
code
whatever you want
