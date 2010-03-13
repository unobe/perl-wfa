#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Stream;

use warnings;
use strict;
use Carp;

sub add_comment {
    return shift->base->call( 'stream.addComment', @_ );
}

sub add_like {
    return shift->base->call( 'stream.addLike', @_ );
}

sub get {
    return shift->base->call( 'stream.get', @_ );
}

sub get_comments {
    return shift->base->call( 'stream.getComments', @_ );
}

sub get_filters {
    return shift->base->call( 'stream.getFilters', @_ );
}

sub publish {
    my $base = shift->base;
    my %args = @_;

    if (ref($args{'action_links'}) eq 'ARRAY') {
        eval q{use JSON::Any};
        croak "Unable to load JSON module to encode 'action_links':$@\n" if $@;
        $args{'action_links'} = $base->_parser->encode( $args{'action_links'} );
    }

    return $base->call( 'stream.publish', %args );
}

sub remove {
    return shift->base->call( 'stream.remove', @_ );
}

sub remove_comment {
    return shift->base->call( 'stream.removeComment', @_ );
}

sub remove_like {
    return shift->base->call( 'stream.removeLike', @_ );
}

1;
__END__

=head1 NAME

WWW::Facebook::API::Stream - Facebook Stream

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing stream with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS 

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new

Constructor.

=item add_comment( %params )

The stream.add_comment method of the Facebook API. 

    $client->stream->add_comment(
        uid           => $uid,
    );

=item add_like( %params )

The stream.add_like method of the Facebook API. 

    $client->stream->add_like(
        uid        => $uid,
        post_id    => $post_id,
    );

=item get( %params )

The stream.get method of the Facebook API. 

    $client->stream->get(
        viewer_id    => id,
        source_ids   => [@source_ids],
    );

=item get_comments( %params )

The stream.get_comments method of the Facebook API. 

    $client->stream->get_comments(
        post_id    => $number,
    );

=item get_filters( %params )

The stream.getFilters method of the Facebook API. 

    $client->stream->get_filters(
        uid         => $uid,
        session_key => $key,
    );

=item publish( %params )

The stream.publish method of the Facebook API. 

    $client->stream->publish(
        message      => $message,
        attachment   => $json,
        action_links => [@links],
    );

=item remove( %params )

The stream.remove method of the Facebook API. 

    $client->stream->remove(
        post_id      => $post_id,
    );

=item remove_comment( %params )

The stream.removeComment method of the Facebook API. 

    $client->stream->remove_comment(
        comment_id      => $comment_id,
    );

=item remove_like( %params )

The stream.removeLike method of the Facebook API. 

    $client->stream->remove_like(
        post_id      => $post_id,
    );

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Stream requires no configuration files or environment
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

=head1 AUTHORS

Herman Polloni C<< <hpolloni@gmail.com> >>

David Romano  C<< <unobe@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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

