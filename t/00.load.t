#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 29;

BEGIN {
    use_ok('WWW::Facebook::API');

    for (@WWW::Facebook::API::namespaces) {
        use_ok("WWW::Facebook::API::$_");
    }
}

diag("Testing WWW::Facebook::API $WWW::Facebook::API::VERSION");
