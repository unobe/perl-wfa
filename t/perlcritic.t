#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################

if ( !require Test::Perl::Critic ) {
    Test::More::plan( skip_all =>
            "Test::Perl::Critic required for testing PBP compliance" );
}

use Test::Perl::Critic ( -severity => 1, -profile => 't/perlcriticrc' );
Test::Perl::Critic::all_critic_ok();
