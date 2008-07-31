#######################################################################
# $Date: 2007-05-28T14:18:18.679359Z $
# $Revision: 1508 $
# $Author: unobe $
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Profile;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.13');

sub set_fbml { return shift->base->call( 'profile.setFBML', @_ ) }
sub get_fbml { return shift->base->call( 'profile.getFBML', @_ ) }
sub get_info { return shift->base->call( 'profile.getInfo', @_ ) }

sub get_info_options {
    return shift->base->call( 'profile.getInfoOptions', @_ );
}
sub set_info { return shift->base->call( 'profile.setInfo', @_ ) }

sub set_info_options {
    return shift->base->call( 'profile.setInfoOptions', @_ );
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Profile - Facebook Profile

=head1 VERSION

This document describes WWW::Facebook::API::Profile version 0.4.13

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing profiles with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.


=item get_fbml( uid => $single_uid )

The profile.getFBML method of the Facebook API.

=item set_fbml( profile => $fbml_markup, uid => $single_uid, ... )

The profile.setFBML method of the Facebook API.


=item get_info( %params )

The profile.getInfo method of the Facebook API. C<uid> is the only
required parameter.

	$client->profile->get_info( uid => 'user_id' );

=item get_info_options( %params )

The profile.getInfoOptions method of the Facebook API. C<field> is the only
required parameter.

	$client->profile->get_info_options( field => 'field_title' );


=item set_info( %params )

The profile.setInfo method of the Facebook API. All parameters are required.

	$client->profile->set_info(
						title 		=> 'title',
						type  		=> '1|5',
						info_fields => 'JSON',
						uid			=> 'user_id',

	);

The format for C<info_fields> is described on the developer wiki:
http://wiki.developers.facebook.com/index.php/Profile.setInfo

=item set_info_options( %params )

The profile.setInfoOptions method of the Facebook API. C<field> and C<options>
parameters are required.

    $client->profile->set_info_options(
                        field       => 'field_title',
                        options     => 'JSON',
    );

The format for C<options> is described on the developer wiki:
http://wiki.developers.facebook.com/index.php/Profile.setInfoOptions

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Profile requires no configuration files or environment
variables.

=head1 DEPENDENCIES

See L<WWW::Facebook::API>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
