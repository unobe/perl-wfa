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
