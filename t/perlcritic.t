#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More;
BEGIN {
    if (! $ENV{'PERL_TEST_CRITIC'} ) {
        plan( skip_all => 'Skipping Perl::Critic tests' );
        exit;
    }
    eval q{require Test::Perl::Critic};
    if ( $@ ) {
        plan( skip_all =>
            "Test::Perl::Critic required for testing PBP compliance" );
    }
}


use Test::Perl::Critic ( -severity => 1, -profile => 't/perlcriticrc' );
Test::Perl::Critic::all_critic_ok();
