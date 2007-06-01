#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Simple;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.1.6');

use base 'WWW::Facebook::API';

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;

    $self = WWW::Facebook::API->new( %args, simple => 1 );

    bless $self, $class;
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Simple - 'Simpler' Facebook API implementation


=head1 VERSION

This document describes WWW::Facebook::API::Simple version 0.1.6


=head1 SYNOPSIS

    use WWW::Facebook::API::Simple;

    my $client = WWW::Facebook::API::Simple->new(
        desktop => 1,
        throw_errors => 1,
        parse_response => 1, # uses XML::Simple if set to 1
    );
    
    # Session initialization
    my $token = $client->auth->create_token;
    
    # prompts for login credentials from STDIN
    $client->login->login( $token );
    $client->auth->get_session( auth_token => $token );
    
    # Dump XML data returned
    use Data::Dumper;
    my @friends = @{ $client->friends->get };
    print Dumper $client->friends->are_friends(
        uids1 => [@friends[0,1,2,3]],
        uids2 => [@friends[4,5,6,7]],
    );
    
    my $unread_pokes = $client->notifications->get->{pokes}->[0]->{unread}->[0];
    print "You have $unread_pokes unread poke(s).";
    
    my @users
        = @{ $client->users->get_info( uids => \@friends, fields => ['quotes'] ) };
    print "Number of friends:".@users."\n";
    
    # Get number of quotes by derefrencing, and then removing the null items (hash
    # refs)
    my @quotes = grep !ref, map { @{$_->{'quotes'}} } @users;
    print "Number of quotes: ".@quotes."\n";
    print "Random quote: ".$quotes[int rand @quotes]."\n";
    
    $client->auth->logout;

    
=head1 DESCRIPTION

A simpler interface to deal with the XML responses of the Facebook API.
Basically, not as much typing to get at the information returned by the
server.

=head1 SUBROUTINES/METHODS 

See L<WWW::Facebook::API>.

=over

=item new

Returns a new instance of this class.

=item base

The L<WWW::Facebook::API::Base> object to use to make calls to
the REST server.

=back

=head1 DIAGNOSTICS

The errors that are thrown would most likely be from
L<WWW::Facebook::API::Base> or from L<DEPENDENCIES>, so look
there first.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Simple requires no configuration files or environment
variables.


=head1 DEPENDENCIES

See L<WWW::Facebook::API>


=head1 INCOMPATIBILITIES

None.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api-rest-client@rt.cpan.org>, or through the web interface at
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
