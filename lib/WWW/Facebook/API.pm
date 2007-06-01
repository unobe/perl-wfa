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

use version; our $VERSION = qv('0.1.6');

use base 'WWW::Facebook::API::Base';

our @attributes = qw(simple);

sub simple { shift->_check_default( 0, 'simple', @_ ) }

our @namespaces = qw(
    Auth        Events      FBML
    Feed        FQL         Friends
    Groups      Login       Notifications
    Photos      Profile     Update
    Users
);

my $create_attribute_code = sub {
    local $_ = shift;
    my $attribute = shift;
    eval qq(
        use WWW::Facebook::API::$_;
        sub $attribute {
            return shift->{'_$attribute'}
                ||= WWW::Facebook::API::$_->new( base => shift )
        }
    );
    croak "Cannot create attribute $attribute: $@\n" if $@;
};

for (@namespaces) {
    my $attribute = "\L$_";
    $create_attribute_code->( $_, $attribute );
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;

    my %no_super;
    for (@attributes) {
        $no_super{$_} = delete $args{$_} if exists $args{$_};
    }
    $self = WWW::Facebook::API::Base->new(%args);
    bless $self, $class;

    $self->$_( $no_super{$_} ) for @attributes;
    $self->$_($self) for map {"\L$_"} @namespaces;

    return $self;
}

1;
__END__

=head1 NAME

WWW::Facebook::API - Facebook API implementation


=head1 VERSION

This document describes WWW::Facebook::API version 0.1.6


=head1 SYNOPSIS

    use WWW::Facebook::API;
    
    my $client = WWW::Facebook::API->new(
        desktop => 1,
        throw_errors => 1,
        parse_response => 1, # uses XML::Simple if set to 1
    );
    
    # Session initialization
    my $token
        = $client->auth->create_token->{auth_createToken_response}->[0]->{content};
    
    # prompts for login credentials from STDIN
    $client->login->login( $token );
    $client->auth->get_session( auth_token => $token );
    
    # Dump XML data returned
    use Data::Dumper;
    my @friends = @{ $client->friends->get->{friends_get_response}->[0]->{uid} };
    print Dumper $client->friends->are_friends(
        uids1 => [@friends[0,1,2,3]],
        uids2 => [@friends[4,5,6,7]],
    );
    
    my $unread_pokes
        = $client->notifications->get
            ->{notifications_get_response}->[0]->{pokes}->[0]->{unread}->[0];
    print "You have $unread_pokes unread poke(s).\n";
    
    my @users
        = @{ $client->users->get_info( uids => \@friends, fields => ['quotes'])
                ->{users_getInfo_response}->[0]->{user}
    };
    print "Number of friends:".@users."\n";
    
    # Get number of quotes by derefrencing, and then removing the null items (hash
    # refs)
    my @quotes = grep !ref, map { @{$_->{'quotes'}} } @users;
    print "Number of quotes: ".@quotes."\n";
    print "Random quote: ".$quotes[int rand @quotes]."\n";
    
    $client->auth->logout;


=head1 DESCRIPTION

A Perl implementation of the Facebook API, working off of the canonical Java
and PHP implementations. If you have L<XML::Simple> or L<JSON::XS> installed,
then you can have them parse the response returned by Facebook's server,
instead of parsing them by hand. In the case that you want the format to be
XML, L<XML::Simple> is used with C<ForceArray => 1> and C<KeepRoot => 1>
values.  Also see L<WWW::Facebook::API::Simple> for a bit easier response
values when working with L<XML::Simple>.

=head1 SUBROUTINES/METHODS 

=over

=item new

Returns a new instance of this class. You are able to pass in any of the
method names in L<WWW::Facebook::API::Base> to set the value (except the
methods C<call>, C<new>, and its internal methods ):
    my $client = WWW::Facebook::API->new(
        format          => 'JSON',
        parse_response  => 1,
        server_uri      => 'http://www.facebook.com/restserver.php',
        secret          => 'application_secret_key',
        api_key         => 'application_key',
        session_key     => 'session_key',
        session_expires => 'session_expires',
        session_uid     => 'session_uid',
        desktop         => 1,
        api_version     => '1.0',
        callback        => 'callback_url',
        next            => 'next',
        popup           => 'popup',
        skipcookie      => 'skip_cookie',
        mech            => WWW::Mechanize->new,
        errors          => WWW::Facebook::API::Errors->new( base => $base ),
    );

See L<WWW::Facebook::API::Base> for the default values.

=over



=back

=item auth

auth namespace of the API (See L<WWW::Facebook::API::Auth>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $token = $client->auth->create_token;
    $client->auth->get_session( auth_token => $token );

You only need ot call $client->auth->create_token if you're running a Desktop
application. Otherwise, the token is created during the user's login, which is
sent to your callback URL as a single parameter (auth_token).

=item login

Not defined in the API, but useful for testing with your own account. Asks for
username and password (not stored outside of run) to authenticate token.
    $new_token = $client->login->login( $token );

C<$new_token> is the token that will be used for the rest of the session.

=item events

events namespace of the API (See L<WWW::Facebook::API::Events>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $events = $client->events->get( uid => 234233, eids => [23,2343,54545] );
    my $members = $client->events->getMembers( eid => 233 );

=item fbml

fbml namespace of the API (See L<WWW::Facebook::API::FBML>):
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->fbml->set_ref_handle;
       $response = $client->fbml->refresh_img_src;
       $response = $client->fbml->refresh_ref_url;

=item fql

fql namespace of the API (See L<WWW::Facebook::API::FQL>):
    my $response = $client->fql->query( query => 'FQL query' );


=item feed

feed namespace of the API (See L<WWW::Facebook::API::Feed>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response 
        = $client->feed->publish_story_to_user(
            title   => 'title',
            body    => 'body',
            priority => 5,
            ...
    );
    $response 
        = $client->feed->publish_action_of_user(
            title   => 'title',
            body    => 'body',
            priority => 7,
            ...
    );

=item friends

friends namespace of the API (See L<WWW::Facebook::API::Friends>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->friends->get;
    $response = $client->friends->get_app_users;
    $response
        = $client->friends->are_friends( uids => [1,5,7,8], uids2 => [2,3,4]);

=item groups

groups namespace of the API (See L<WWW::Facebook::API::Groups>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->groups->get_members( gid => 32 );
    $response    = $client->groups->get( uid => 234324, gids => [2423,334] );

=item notifications

notifications namespace of the API (See L<WWW::Facebook::API::Notifications>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->notifications->get;
    $response = $client->notifications->send(
        to_ids => [1],
        markup => 'markup',
        no_email => 1,
    );
    $response = $client->notifications->send_request(
        to_ids => [1],
        type => 'event',
        content => 'markup',
        image   => 'string',
        invite  => 0,
    );

=item photos

photos namespace of the API (See L<WWW::Facebook::API::Photos>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response
        = $client->photos->add_tag(
            pid => 2,
            tag_uid => 3,
            tag_text => "me",
            x => 5,
            y => 6
        );
    $response = $client->photos->create_album(
            name => 'fun in the sun',
            location => 'California',
            description => "Summer '07",
    );
    $response = $client->photos->get( aid => 2, pids => [4,7,8] );
    $response = $client->photos->get_albums( uid => 1, pids => [3,5] );
    $response = $client->photos->get_tags( pids => [4,5] );
    $response = $client->photos->upload(
        aid => 5,
        caption => 'beach',
        data => 'raw data',
    );

=item profile

profile namespace of the API (See L<WWW::Facebook::API::Profile>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->profile->get_fbml( uid => 3 );
    $response = $client->profile->set_fbml( uid => 5, markup => 'markup' );

=item update

update namespace of the API (See L<WWW::Facebook::API::Update>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->update->decode_ids( ids => [5,4,3] );

=item users

users namespace of the API (See L<WWW::Facebook::API::Users>).
All method names from the Facebook API are lower_cased instead of CamelCase:
    my $response = $client->users->get_info(
        uids => [12,453,67],
        fields => ['quotes','activities','books']
    );

=item simple

Defaults to false.  L<WWW::Facebook::API::Simple> defaults to true. Compare
this module's synopsis with L<WWW::Facebook::API::Simple> to see an example of
what difference it makes. If set to true, makes all methods return an
easier-to-manage value by dereferencing the top nodes of the XML hierarchy.

=back 


=head1 DIAGNOSTICS

The errors that are thrown come from L<WWW::Facebook::API::Base> or from
others in one of the L<DEPENDENCIES>.


=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<WWW::Mechanize>
L<XML::Simple>
L<Digest::MD5>
L<Crypt::SSLeay>

=head1 INCOMPATIBILITIES

None.

=head1 SEE ALSO

L<WWW::Facebook::FQL> for an interface to just work with Facebook's FQL query
language.


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
