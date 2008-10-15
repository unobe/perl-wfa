package WWW::Facebook::API::Admin;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.14');

sub get_allocation {
    return shift->base->call( 'Admin.getAllocation', @_ );
}

sub get_metrics {
    return shift->base->call( 'Admin.getMetrics', @_ );
}

sub get_app_properties {
    return shift->base->call( 'Admin.getAppProperties', @_ );
}

sub set_app_properties {
    return shift->base->call( 'Admin.setAppProperties', @_ );
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Admin - Facebook Admin

=head1 VERSION

This document describes WWW::Facebook::API::Admin version 0.4.14

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing Admin functions with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

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

=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>

Thomas Burke  C<< <tburke@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
