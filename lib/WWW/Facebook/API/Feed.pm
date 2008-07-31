#######################################################################
# $Date: 2007-05-28T14:18:18.679359Z $
# $Revision: 1508 $
# $Author: unobe $
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API::Feed;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.13');

sub publish_user_action {
    return shift->base->call( 'feed.publishUserAction', @_ );
}

sub register_template_bundle {
    return shift->base->call( 'feed.registerTemplateBundle', @_ );
}

sub deactivate_template_bundle {
    return shift->base->call( 'feed.deactivateTemplateBundleById', @_ );
}

sub get_registered_template_bundle {
    my $method =
        @_
        ? 'feed.getRegisteredTemplateBundleById'
        : 'feed.getRegisteredTemplateBundles';

    return shift->base->call( $method, @_ );
}

sub publish_story_to_user {
    my $self = shift;
    carp 'publish_story_to_user is deprecated' if $self->base->debug;
    return $self->base->call( 'feed.publishStoryToUser', @_ );
}

sub publish_action_of_user {
    my $self = shift;
    carp 'publish_action_of_user is deprecated' if $self->base->debug;
    return $self->base->call( 'feed.publishActionOfUser', @_ );
}

sub publish_templatized_action {
    return shift->base->call( 'feed.publishTemplatizedAction', @_ );
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API::Feed - Facebook Feeds

=head1 VERSION

This document describes WWW::Facebook::API::Feed version 0.4.13

=head1 SYNOPSIS

    use WWW::Facebook::API;

=head1 DESCRIPTION

Methods for accessing feeds with L<WWW::Facebook::API>

=head1 SUBROUTINES/METHODS

=over

=item base

Returns the L<WWW::Facebook::API> base object.

=item new


Constructor.


=item publish_user_action( %params )


The feed.publishUserAction method of the Facebook API. C<template_bundle_id> is the only
parameter required.


    $client->feed->publish_user_action(
        template_bundle_id => 'id',
        template_data      => 'JSON',
        body_general       => 'markup',
        target_ids         => [@array_of_ids],
    );

The format for C<template_data> is described on the developer wiki:
http://wiki.developers.facebook.com/index.php/Feed.publishUserAction


=item register_template_bundle( %params )


The feed.registerTemplateBundle method of the Facebook API. C<one_line_story_templates> is the only
parameter required.


    $client->feed->publish_user_action(
        one_line_story_templates => 'JSON',
        short_story_templates    => 'JSON',
        full_story_template      => 'JSON',
    );

The formats for C<one_line_story_templates>,C<short_story_templates>,C<full_story_template> are
described on the developer wiki:
http://wiki.developers.facebook.com/index.php/Feed.registerTemplateBundle

=item deactivate_template_bundle( %params )

The feed.deactivateTemplateBundle method of the Facebook API. C<template_bundle_id> is the only
parameter required.


    $client->feed->deactivate_template_bundle(
		template_bundle_id => 'template_bundle_id'
    );

=item get_registered_template_bundle

The combined feed.getRegisteredTemplateBundleByID and feed.getRegisteredTemplateBundles methods
of the Facebook API. If the C<template_bundle_id> parameter is present only that template bundle will be fetched.


    $client->feed->get_registered_template_bundle(
        template_bundle_id => 'template_bundle_id'
    );

=item publish_templatized_action( %params )

The feed.publishTemplatizedAction method of the Facebook API. C<actor_id> and
C<title_template> are required parameters.

    $client->feed->publish_templatized_action(
        page_actor_id   => 'page_id',
        title_template  => 'markup',
        title_data      => 'JSON',
        body_template   => 'markup',
        body_general    => 'markup',
        body_data       => 'JSON',
        image_1         => 'image url',
        image_1_link    => 'destination url',
        image_2         => 'image url',
        image_2_link    => 'destination url',
        image_3         => 'image url',
        image_3_link    => 'destination url',
        image_4         => 'image url',
        image_4_link    => 'destination url',
        target_ids      => [@array_of_ids],
    );

=back

=head1 DEPRECATED SUBROUTINES/METHODS

=over

=item publish_story_to_user( %params )

The feed.publishStoryToUser method of the Facebook API. C<title> is the only
parameter required.

    $client->feed->publish_story_to_user(
        title           => 'title',
        body            => 'markup',
        image_1         => 'image url',
        image_1_link    => 'destination url',
        image_2         => 'image url',
        image_2_link    => 'destination url',
        image_3         => 'image url',
        image_3_link    => 'destination url',
        image_4         => 'image url',
        image_4_link    => 'destination url',
        priority        => '100',
    );

=item publish_action_of_user( %params )

The feed.publishActionOfUser method of the Facebook API. C<title> is the only
parameter required.

    $client->feed->publish_action_of_user(
        title           => 'title',
        body            => 'markup',
        image_1         => 'image url',
        image_1_link    => 'destination url',
        image_2         => 'image url',
        image_2_link    => 'destination url',
        image_3         => 'image url',
        image_3_link    => 'destination url',
        image_4         => 'image url',
        image_4_link    => 'destination url',
    );

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API::Feed requires no configuration files or environment
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
