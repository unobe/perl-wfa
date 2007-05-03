#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Errors;

use strict;
use warnings;
use XML::Simple qw(xml_out);
use Carp;

use version; our $VERSION = qv('0.0.6');

use Moose;
extends 'Moose::Object';

has 'debug' => ( is => 'ro', isa => 'Bool', default => 0 );
has 'throw_errors' => (
    is => 'ro', isa => 'Bool', required => 1, default => 1,
);
has 'last_call_success' => ( is => 'rw', isa => 'Bool' );
has 'last_error' => ( is => 'rw', isa => 'Str' );

sub log_debug {
    my ($self, $params, $xml ) = @_;
    # output the raw xml and its corresponding object, for debugging:
    my $debug = "params = \n";

    for ( keys %{$params} ) {
        $debug .= "\t$_ " . $params->{$_} . "\n";
    }
    $debug .= "xml = \n" . xml_out( $xml );
    carp $debug;
    return;
}

sub log_error {
    my ( $self, $xml ) = @_;
    $self->last_call_success( 0 );
    my $error_response = $xml->{'error_response'}->[0];
    $self->last_error( join ': ',
        $error_response->{'error_code'}->[0],
        $error_response->{'error_msg'}->[0]
    );
    if ( $self->throw_errors ) { confess xml_out( $xml ) }
    return;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Errors - Errors class for Client


=head1 VERSION

This document describes WWW::Facebook::API::Errors version 0.0.6


=head1 SYNOPSIS

    use WWW::Facebook::API::Errors;


=head1 DESCRIPTION

Error methods and data used by L<WWW::Facebook::API::Base>


=head1 SUBROUTINES/METHODS 

=over

=item debug

A boolean set to either true or false, determining if debugging messages
should be carped to STDERR for REST calls.

=item throw_errors

A boolean set to either true of false, signifying whether or not log_error
should carp when an error is returned from the REST server.

=item last_call_success

A boolean. True if the last call was a success, false otherwise.

=item last_error

A string holding the error message of the last failed call to the REST server.

=item log_debug

Logs debugging message by carping parameters and xml returned by REST server.
Only called if C<debug> is true.

=item log_error

Logs an error, and if C<throw_errors> is true, carps with the error code and
message.

=item meta

L<Moose>

=back


=head1 DIAGNOSTICS

Any error that is thrown is most likely an API error as well.

=over

=item C< 104: Incorrect signature >

This one in particular might get you: make sure you have passed in (desktop =>
1) when creating a new desktop client, or else the signature won't match
because the wrong session key will be passed in.

=back


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Errors requires no configuration files or
environment variables.


=head1 DEPENDENCIES

L<Moose>
L<XML::Simple>
L<version>


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

Copyright (c) 2006, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
