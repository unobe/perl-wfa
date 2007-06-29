package WWW::Facebook::API::FBML;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.3.6');

sub base { return shift->{'base'}; }

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    delete $self->{$_} for grep { !/base/xms } keys %{$self};
    $self->$_ for keys %{$self};

    return $self;
}

sub refresh_img_src { return shift->base->call( 'fbml.refreshImgSrc', @_ ) }
sub refresh_ref_url { return shift->base->call( 'fbml.refreshRefUrl', @_ ) }
sub set_ref_handle  { return shift->base->call( 'fbml.setRefHandle',  @_ ) }

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::FBML - Facebook Markup Language

=head1 VERSION

This document describes WWW::Facebook::API::FBML version 0.3.6

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for updating FBML references with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item new()

Returns a new instance of this class.

=back

=head1 METHODS

=over

=item base()

The L<WWW::Facebook::API> object to use to make calls to the REST server.

=item set_ref_handle( handle => 'handleName', fbml => 'fbml' )

The fbml.setRefHandle method of the Facebook API. See this page on the wiki:
http://wiki.f8.facebook.com/index.php/Fb:ref

=item refresh_img_src( url => $url )

The fbml.refreshImgSrc method of the Facebook API.

=item refresh_ref_url( url => $url )

The fbml.refreshRefUrl method of the Facebook API.

=back


=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::FBML requires no configuration files or environment
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

TSIBLEY C<< <tsibley@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007, TSIBLEY C<< <tsibley@cpan.org> >>. All rights reserved.

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
