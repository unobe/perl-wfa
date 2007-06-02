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

use version; our $VERSION = qv('0.2.1');

sub base { return shift->{'base'}; }

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    delete $self->{$_} for grep !/base/, keys %$self;
    $self->$_ for keys %$self;

    return $self;
}

sub get_fb_params {
    my ( $self, $q ) = @_;
    return {
        map { (/^fb_sig_(.*)/)[0] => $q->param($_) }
            sort grep {/^fb_sig_/} $q->param
    };
}

sub validate_sig {
    my ( $self, $q ) = @_;
    my $fb_params = $self->get_fb_params($q);
    return $fb_params
        if $self->base->validate_sig( $fb_params, $q->param('fb_sig') );
    return;
}

sub get_user {
    my ( $self, $q ) = @_;
    my $fb_params = $self->validate_sig($q);

    return $fb_params->{'user'} if $fb_params;
    return "";
}

sub in_fb_canvas {
    my ( $self, $q ) = @_;
    return $self->get_fb_params($q)->{'in_canvas'};
}

sub in_frame {
    my ( $self, $q ) = @_;
    my $fb_params = $self->get_fb_params($q);
    return 1 if $fb_params->{'in_canvas'} or $fb_params->{'in_frame'};
    return;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Canvas - Facebook canvas related methods


=head1 VERSION

This document describes WWW::Facebook::API::Canvas version 0.2.0


=head1 SYNOPSIS

    use WWW::Facebook::API;


=head1 DESCRIPTION

Methods for using the canvas with L<WWW::Facebook::API>

The C<$q> parameter should implement the param method (for example
a L<CGI> or L<Apache::Request> object).

=head1 SUBROUTINES/METHODS 

=over

=item new

Returns a new instance of this class.

=item base

The L<WWW::Facebook::API::Base> object to use to make calls to
the REST server.

=item get_user($q)

Return the UID of the canvas user or "" if it does not exist.

=item get_fb_params($q)

Return a hash reference to the signed parameters sent via Facebook.

=item validate_sig($q)

Return true if the signature on the $q object is valid for this application.

=item in_fb_canvas($q)

Return true if inside a canvas.

=item in_frame($q)

Return true if inside a frame or canvas.

=back


=head1 DIAGNOSTICS

This module is used by L<WWW::Facebook::API> and right now does
not have any unique error messages.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Canvas requires no configuration files or
environment variables.


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
