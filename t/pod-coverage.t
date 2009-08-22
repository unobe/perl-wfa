#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################

use Test::More;
if (!$ENV{'PERL_TEST_POD'}) {
    plan skip_all => "Skipping Pod::Coverage tests";
    exit;
}

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;
all_pod_coverage_ok();
