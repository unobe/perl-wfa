#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Errors;

use strict;
use warnings;
use Carp;

use version; our $VERSION = qv('0.1.6');

our @attributes = qw(
    base
    debug   throw_errors    last_error
    last_call_success
);

sub base { return shift->{'base'}; }

sub debug        { return shift->{'debug'}        ||= @_ ? shift != 0 : 0; }
sub throw_errors { return shift->{'throw_errors'} ||= @_ ? shift != 0 : 1; }
sub last_error   { return shift->{'last_error'}   ||= @_ ? shift      : 0; }

sub last_call_success {
    return shift->{'last_call_success'} ||= @_ ? shift != 0 : 0;
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;

    my $is_attribute = join '|', @attributes;
    delete $self->{$_} for grep !/^($is_attribute)$/, keys %$self;
    $self->$_ for keys %$self;

    return $self;
}

sub log_string {
    my ( $self, $params, $response ) = @_;

    my $string = "uri = " . $self->base->server_uri;

    $string .= "\n\nparams = \n";
    for ( keys %{$params} ) {
        $string .= "\t$_ " . $params->{$_} . "\n";
    }

    $string .= "response =\n$response\n";

    return $string;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Errors - Errors class for Client


=head1 VERSION

This document describes WWW::Facebook::API::Errors version 0.1.6


=head1 SYNOPSIS

    use WWW::Facebook::API;


=head1 DESCRIPTION

Error methods and data used by L<WWW::Facebook::API::Base>


=head1 SUBROUTINES/METHODS 

=over

=item new

Returns a new instance of this class.

=item base

The L<WWW::Facebook::API::Base> object to use to access settings.

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

=item log_string

Pass in the params and the response from a call, and it will make a formatted
string out of it showing the server_uri, the parameters used, and the response
received. Used by log_debug and log_error.

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
