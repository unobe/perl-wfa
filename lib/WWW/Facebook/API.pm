#######################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.5');

use Moose;

use WWW::Facebook::API::Auth;
use WWW::Facebook::API::Login;
use WWW::Facebook::API::Events;
use WWW::Facebook::API::Friends;
use WWW::Facebook::API::Messages;
use WWW::Facebook::API::Photos;
use WWW::Facebook::API::Pokes;
use WWW::Facebook::API::Session;
use WWW::Facebook::API::Users;

extends 'WWW::Facebook::API::Base';

has 'auth' => (is => 'ro',
    isa => 'WWW::Facebook::API::Auth',
    default => sub {
        return WWW::Facebook::API::Auth->new(base => $_[0] )
    },
);
has 'login' => (is => 'ro',
    isa => 'WWW::Facebook::API::Login',
    default => sub {
        return WWW::Facebook::API::Login->new(base => $_[0] )
    },
);
has 'events' => (is => 'ro',
    isa => 'WWW::Facebook::API::Events',
    default => sub {
        return WWW::Facebook::API::Events->new(base => $_[0] )
    },
);
has 'friends' => (is => 'ro',
    isa => 'WWW::Facebook::API::Friends',
    default => sub {
        return WWW::Facebook::API::Friends->new(base => $_[0] )
    },
);
has 'messages' => (is => 'ro',
    isa => 'WWW::Facebook::API::Messages',
    default => sub {
        return WWW::Facebook::API::Messages->new(base => $_[0] )
    },
);
has 'photos' => (is => 'ro',
    isa => 'WWW::Facebook::API::Photos',
    default => sub {
        return WWW::Facebook::API::Photos->new(base => $_[0] )
    },
);
has 'pokes' => (is => 'ro',
    isa => 'WWW::Facebook::API::Pokes',
    default => sub {
        return WWW::Facebook::API::Pokes->new(base => $_[0] )
    },
);
has 'session' => (is => 'ro',
    isa => 'WWW::Facebook::API::Session',
    default => sub {
        return WWW::Facebook::API::Session->new(base => $_[0] )
    },
);
has 'users' => (is => 'ro',
    isa => 'WWW::Facebook::API::Users',
    default => sub {
        return WWW::Facebook::API::Users->new(base => $_[0] )
    },
);

1;
__END__

=head1 NAME

WWW::Facebook::API - Facebook API implementation


=head1 VERSION

This document describes WWW::Facebook::API version 0.0.5


=head1 SYNOPSIS

    use WWW::Facebook::API;

    my $client = WWW::Facebook::API->new(
        throw_errors => 1,
        desktop => 1,
        api_key => '5ac7d432',
        secret => '459ade099c',
    );
    my $token = $client->auth->create_token->{result}->[0]->{token}->[0];
    $client->login->login($token); # prompts for email and password from STDIN
    $client->auth->get_session($token);
    my @friends = @{$client->friends->get->{result}->[0]->{result_elt}};
    $client->friends->are_friends([@friends[0,1,2,3]], [@friends[4,5,6,7]]);
    print 'You have '.$client->pokes->get_count->{result}->[0]->{unseen}->[0]
        .' new poke(s).';
    my @quotes = map { @{$_->{quote}} }
        values %{$client->users->get_info(\@friends, 'quote')->{result}->[0]->{result_elt}};
    print 'A lot of quotes: '.@quotes."\n";
    print "Random one:\t".$quotes[int rand @quotes]."\n";


=head1 DESCRIPTION

A Perl implementation of the Facebook API, working off of the Java and PHP
implementations initially proffered by the Facebook development team. The
results are returned as a hash parsed by L<XML::Simple> with ForceArray => 1
and KeepRoot => 1. So, as per the API description at
L<http://developers.facebook.com/documentation.php>, there's a result key,
with an array which has the result items (be they hashes or whatever) inside.
I thought this would give the most direct access to the actual data without
filtering any important data (or ordering of data) out.


=head1 SUBROUTINES/METHODS 

=over

=item auth

auth namespace of the API (See L<WWW::Facebook::API::Auth>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., auth.createToken is auth->create_token

=item login

Not defined in the API, but useful for testing with your own account. Asks for
username and password (not stored) to authenticate token. Called as
$client->login->login($token);

=item events

events namespace of the API (See L<WWW::Facebook::API::Events>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., events.getInWindow is events->get_in_window

=item friends

friends namespace of the API (See L<WWW::Facebook::API::Friends>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., friends.areFriends(list1, list2) is friends->are_friends(list1, list2)

=item messages

messages namespace of the API (See
L<WWW::Facebook::API::Messages>). All method names from the
Facebook API are lower_cased instead of CamelCase, e.g., messages.getCount is
message->get_count

=item photos

photos namespace of the API (See L<WWW::Facebook::API::Photos>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., photos.getOfUser is photos->get_of_user

=item pokes

pokes namespace of the API (See L<WWW::Facebook::API::Pokes>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., pokes.getCount is pokes->get_count

=item session

session namespace of the API (See L<WWW::Facebook::API::Session>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., session.ping is session->ping

=item users

users namespace of the API (See L<WWW::Facebook::API::Users>).
All method names from the Facebook API are lower_cased instead of CamelCase,
e.g., users.getInfo is users->get_info

=back 


=head1 DIAGNOSTICS

The errors that are thrown would most likely be from
L<WWW::Facebook::API::Base> or from L<DEPENDENCIES>, so look
there first.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<Moose>
L<WWW::Mechanize>
L<XML::Simple>
L<Digest::MD5>
L<Time::HiRes>
L<URI::Escape>


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
