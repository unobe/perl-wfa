#########################################################################
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Exception;

use warnings;
use strict;
use Carp;

use overload ('""' => 'stringify');

sub new {
    my ($class, $method, $params, $response) = @_;

    my $self = {
        _method => $method,
        _params => $params,
        _response => $response
    };
    $self = bless $self, $class;
}

sub method { my $self = shift; return $self->{_method} }
sub params { my $self = shift; return $self->{_params} }
sub response { my $self = shift; return $self->{_response} }

sub stringify {
    my $self = shift;

    my $method = $self->method;
    my $params = $self->params;
    my $response = $self->response;

    return "Error during REST $method call:"
                . WWW::Facebook::API->log_string( $params, $response );
}


1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Exception - Facebook API exception

=head1 DESCRIPTION

Exception thrown by L<WWW::Facebook::API> when an error occurs.

=head1 SUBROUTINES/METHODS

=over

=item new( SCALAR $method, HASHREF $params, HASHREF $response )

Returns a new instance of this class for an error in the REST method 
call to $method, which was given parameters $params, and returned
$response.

=item method

Returns the method call which generated the error.

=item params

Returns the parameters passed to the method call which generated 
the error.

=item response

Returns the server's resopnse to the method call which generated
the error.

=item stringify

Returns a string describing the error.

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHORS

Kevin Riggle  C<< none >>

David Romano  C<< <unobe@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Certain part copyright (c) 2010, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
