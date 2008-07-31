#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Canvas;
use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.13');

sub get_fb_params {
    my $self = shift;
    $self->base->query(shift);

    my $fb_params = {};
    my @query = grep {m/^fb_sig_/xms} $self->base->query->param;
    for my $param (@query) {
        my @values = $self->base->query->param($param);
        if ( @values > 1 || ref $values[0] ) {
            croak "Multiple values for $param: Are you using POST for forms?";
        }

        my $attribute = ( $param =~ /^fb_sig_ (.*) $/xms )[0];
        $fb_params->{$attribute} = $self->base->query->param($param);
    }

    return $fb_params;
}

sub get_non_fb_params {
    my $self = shift;
    $self->base->query(shift);

    my $non_fb_params = {};
    my @query = grep { !/^fb_sig_?/xms } $self->base->query->param;
    for my $param (@query) {
        my @values = $self->base->query->param($param);
        if ( @values > 1 || ref $values[0] ) {
            croak "Multiple values for $param. Are you using POST for forms?";
        }

        $non_fb_params->{$param} = $self->base->query->param($param);
    }

    return $non_fb_params;
}

sub validate_sig {
    my $self = shift;
    $self->base->query(shift);

    my $fb_params = $self->get_fb_params;
    return unless $self->base->query->param('fb_sig');
    return $fb_params
        if $self->base->verify_sig(
        params => $fb_params,
        sig    => $self->base->query->param('fb_sig'),
        );

    return;
}

sub get_user {
    my $self = shift;
    $self->base->query(shift);

    my $fb_params = $self->validate_sig;
    return $fb_params->{'user'} if exists $fb_params->{'user'};

    return q{};
}

sub in_fb_canvas {
    my $self = shift;
    $self->base->query(shift);

    return $self->get_fb_params->{'in_canvas'};
}

sub in_frame {
    my $self = shift;
    $self->base->query(shift);

    my $fb_params = $self->get_fb_params;
    return 1 if $fb_params->{'in_canvas'} or $fb_params->{'in_iframe'};

    return;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Canvas - Facebook Canvas

=head1 VERSION

This document describes WWW::Facebook::API::Canvas version 0.4.13

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for using the canvas with L<WWW::Facebook::API>

The C<$q> parameter should implement the param method (for example a L<CGI> or
L<Apache::Request> object).

=head1 SUBROUTINES/METHODS

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.

=item get_user( $q )

Return the UID of the canvas user or "" if it does not exist (See
L<DESCRIPTION>):

    $response = $client->canvas->get_user( $q )

If C<$q> is not passed in, the value returned by C<< $client->base->query() >> is
used.

=item get_fb_params( $q )

Return a hash reference to the signed parameters sent via Facebook (See
L<DESCRIPTION>):

    $response = $client->canvas->get_fb_params( $q )

If C<$q> is not passed in, the value returned by C<< $client->base->query() >> is
used.

=item get_non_fb_params( $q )

Return a hash reference to the parameters that are not part of the signed
facebook parameters. This is useful if your app send a POST request to
Facebook and you want to use the data you POSTed:

    $non_fb_params = $client->canvas->get_non_fb_params( $q )

If C<$q> is not passed in, the value returned by C<< $client->base->query() >> is
used.

=item in_fb_canvas( $q )

Return true if inside a canvas (See L<DESCRIPTION>):

    $response = $client->canvas->in_fb_canvas( $q )

If C<$q> is not passed in, the value returned by C<< $self->base->query() >> is
used.

=item in_frame( $q )

Return true if inside an iframe or canvas (See L<DESCRIPTION>):

    $response = $client->canvas->in_frame( $q )

If C<$q> is not passed in, the value returned by C<< $self->base->query() >> is
used.

=item validate_sig( $q )

Return a hash reference containing the fb_sig_* params (with C<fb_sig_>
stripped) if the signature of the $q object is valid for this application (See
L<DESCRIPTION>):

    $fb_params = $client->canvas->validate_sig( $q )
    # $fb_params doesn't contain a sig key

If C<$q> is not passed in, the value returned by C<< $self->base->query() >> is
used.

=back

=head1 DIAGNOSTICS

=over

=item C<< Multiple values for %s. Are you using POST for forms? >>

Your forms are most likely using GET rather than POST to the Facebook URLs.
Change your forms to using POST and the problem should be resolved. (See
RT#31620 and RT#31944 for more information).

=back

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Canvas requires no configuration files or environment
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

David Leadbeater  C<< http://dgl.cx >>
David Romano  C<< <unobe@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007, David Leadbeater C<< http://dgl.cx >>.
David Romano C<< <unobe@cpan.org> >>. All rights reserved. 

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
