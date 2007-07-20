#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################

use Test::More;
if (!$ENV{'AUTHOR_TESTS'}) {
    plan skip_all => "Skipping author tests";
    exit;
}

eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
