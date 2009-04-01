package WWW::Facebook::API::Permissions;

use warnings;
use strict;

use Carp;

=head1 NAME

WWW::Facebook::API::Permissions - Facebook Permissions

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Implementation of the Facebook Permissions API:

    use WWW::Facebook::API;
	
	# setup, etc
	# see below for full documentation
	$client->permissions->grant_api_access( ... );
	$client->permissions->check_available_api_access( ... );
	$client->permissions->revoke_api_access( ... );
	$client->permissions->check_granted_api_access( ... );

=head1 DESCRIPTION

Methods for accessing Permissions functions with L<WWW::Facebook::API>

Please note that this API is considered by Facebook to be in Beta.

=head1 METHODS

The first paragraph of documentation for each of these methods comes from Facebook's method documentation.

=head2 grant_api_access

This method gives another application access to certain API calls on behalf of the application calling it.

You B<MUST> supply the API key of the application you want to grant access to. You B<MAY> also supply an array of methods/namespaces for which access should be granted.

    $client->permissions->grant_api_access(
        permissions_apikey => $otherkey,
        method_arr => '["admin."]'
    );

L<http://wiki.developers.facebook.com/index.php/Permissions.grantApiAccess>

=cut

sub grant_api_access {
    return shift->base->call( 'Permissions.grantApiAccess', @_ );
}

=head2 check_available_api_access

This method returns the API methods to which access has been granted by the specified application.

You B<MUST> supply the API key of the application you want to check.

    $client->permissions->check_available_api_access(
        permissions_apikey => $master_key
    );

L<http://wiki.developers.facebook.com/index.php/Permissions.checkAvailableApiAccess>

=cut

sub check_available_api_access {
    return shift->base->call( 'Permissions.checkAvailableApiAccess', @_ );
}

=head2 revoke_api_access

This method revokes the API access granted to the specified application.

You B<MUST> supply the API key of the application for which you want to revoke access.

    $client->permissions->revoke_api_access(
        permissions_apikey => $other_key
    );
    
L<http://wiki.developers.facebook.com/index.php/Permissions.revokeApiAccess>

=cut

sub revoke_api_access {
	return shift->base->call( 'Permissions.revokeApiAccess', @_ );
}

=head2 check_granted_api_access

This method returns the API methods to which the specified application has been given access.

You B<MUST> supply the API key of the application for which you want the check to be made.

    $client->permissions->check_granted_api_access(
        permissions_apikey => $other_key
    );
    
L<http://wiki.developers.facebook.com/index.php/Permissions.checkGrantedApiAccess>

=cut

sub check_granted_api_access {
	return shift->base->call( 'Permissions.checkGrantedApiAccess', @_ );
}


=head1 AUTHOR

Pedro Figueiredo, C<< <pedro.figueiredo at playfish.com> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-www-facebook-api-permissions at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Facebook-API-Permissions>. I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Facebook::API::Permissions


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Facebook-API-Permissions>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Facebook-API-Permissions>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Facebook-API-Permissions>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Facebook-API-Permissions/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Playfish, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


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

=cut

45; # End of WWW::Facebook::API::Permissions
