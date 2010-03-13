#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Permissions;

use warnings;
use strict;

use Carp;

sub begin {
    my $self = shift;
    shift; # get rid of hash key
    $self->base->call_as_api_key(shift);
    return;
}

sub end {
    shift->base->call_as_api_key(q{});
    return;
}

sub grant_api_access {
    return shift->base->call( 'permissions.grantApiAccess', @_ );
}

sub check_available_api_access {
    return shift->base->call( 'permissions.checkAvailableApiAccess', @_ );
}

sub revoke_api_access {
	return shift->base->call( 'permissions.revokeApiAccess', @_ );
}

sub check_granted_api_access {
	return shift->base->call( 'permissions.checkGrantedApiAccess', @_ );
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Permissions - Facebook Permissions

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

=head1 SUBROUTINES/METHODS

=over

=item begin($call_as_apikey)

Mimics C<begin_permissions_mode> of official PHP API. Successive calls will
automatically insert the C<call_as_apikey> key and whatever value is passed in
as <$call_as_apikey>.

    $client->permissions->begin(
        call_as_apikey => $key,
    );

=item end

Mimics C<end_permissions_mode> of official PHP API. Opposite of C<begin>.

    $client->permissions->end(
        call_as_apikey => $key,
    );

=item grant_api_access

This method gives another application access to certain API calls on behalf of the application calling it.

You B<MUST> supply the API key of the application you want to grant access to. You B<MAY> also supply an array of methods/namespaces for which access should be granted.

    $client->permissions->grant_api_access(
        permissions_apikey => $otherkey,
        method_arr => '["admin."]'
    );

L<http://wiki.developers.facebook.com/index.php/Permissions.grantApiAccess>

=item check_available_api_access

This method returns the API methods to which access has been granted by the specified application.

You B<MUST> supply the API key of the application you want to check.

    $client->permissions->check_available_api_access(
        permissions_apikey => $master_key
    );

L<http://wiki.developers.facebook.com/index.php/Permissions.checkAvailableApiAccess>

=item revoke_api_access

This method revokes the API access granted to the specified application.

You B<MUST> supply the API key of the application for which you want to revoke access.

    $client->permissions->revoke_api_access(
        permissions_apikey => $other_key
    );
    
L<http://wiki.developers.facebook.com/index.php/Permissions.revokeApiAccess>

=item check_granted_api_access

This method returns the API methods to which the specified application has been given access.

You B<MUST> supply the API key of the application for which you want the check to be made.

    $client->permissions->check_granted_api_access(
        permissions_apikey => $other_key
    );
    
L<http://wiki.developers.facebook.com/index.php/Permissions.checkGrantedApiAccess>

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHORS

Pedro Figueiredo, C<< <pedro.figueiredo at playfish.com> >>

David Romano C<< <unobe@cpan.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Facebook::API::Permissions


You can also look for information at:

=head1 COPYRIGHT & LICENSE

Copyright (c) 2010 Playfish. All Rights reserved.
Certain parts copyright (c) 2010, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
