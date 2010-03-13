#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Admin;

use warnings;
use strict;
use Carp;

sub get_allocation {
    return shift->base->call( 'admin.getAllocation', @_ );
}

sub get_app_properties {
    return shift->base->call( 'admin.getAppProperties', @_ );
}

sub get_metrics {
    return shift->base->call( 'admin.getMetrics', @_ );
}

sub get_restriction_info {
    return shift->base->call( 'admin.getRestrictionInfo', @_ );
}

sub set_app_properties {
    return shift->base->call( 'admin.setAppProperties', @_ );
}

sub set_restriction_info {
    return shift->base->call( 'admin.setRestrictionInfo', @_ );
}

sub ban_users {
    return shift->base->call( 'admin.banUsers', @_ );
}

sub unban_users {
    return shift->base->call( 'admin.unbanUsers', @_ );
}

sub get_banned_users {
    return shift->base->call( 'admin.getBannedUsers', @_ );
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Admin - Facebook Admin

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing Admin functions with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.

=item get_allocation( %params )

The Admin.getAllocation method of the Facebook API. 

    $allocation = $client->Admin->get_allocation(
        integration_point_name => 'notifications_per_day',
    );

=item get_metrics( %params )

The Admin.getMetrics method of the Facebook API. 

    $result = $client->Admin->get_metrics(
      start_time => 1222285298,
      end_time   => 1222300000,
      period     => 86400,
      metrics    => '["active_users", "canvas_page_views"]'
    );

=item get_app_properties( %params )

The Admin.getAppProperties method of the Facebook API. 

    $properties = $client->Admin->get_app_properties(
      properties => '["application_name","callback_url"]'
    );

=item set_app_properties( %params )

The Admin.setAppProperties method of the Facebook API. 

    $result = $client->Admin->set_app_properties(
      properties => encode_json {
        application_name => 'testapp',
        callback_url => 'http://example.com/testapp/'
        }
    );

=item get_restriction_info( %params )

The Admin.getRestrictionInfo method of the Facebook API. 

    $result = $client->Admin->get_restriction_info();

=item set_restriction_info( %params )

The Admin.setRestrictionInfo method of the Facebook API. 

    $result = $client->Admin->set_restriction_info(
        encode_json { age => '21+', location => 'us' }
    );

=item ban_users( %params )

The Admin.banUsers method of the Facebook API. 

    $result = $client->Admin->ban_users( uids => [@uids] );

==item unban_users( %params )

The Admin.unbanUsers method of the Facebook API. 

    $result = $client->Admin->unban_users( uids => [@uids] );

=item get_banned_users( %params )

The Admin.getBannedUsers method of the Facebook API. 

    $result = $client->Admin->getBannedUsers();

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Admin requires no configuration files or environment
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

=head1 AUTHORS

David Romano  C<< <unobe@cpan.org> >>

Thomas Burke  C<< <tburke@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008-2010, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
