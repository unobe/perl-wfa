#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################

use Test::More;
if (!$ENV{'PERL_TEST_POD'}) {
    plan skip_all => "Skipping Test::Pod tests";
    exit;
}

eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
