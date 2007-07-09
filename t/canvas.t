#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 15;
use WWW::Facebook::API;
use strict;
use warnings;

{ package Mock::CGI;
    sub new { return bless {}, $_[0]; }

    sub set_param {
        my ($self, %param_new) = @_;
        %$self = %param_new;
    }

    sub param {
        my ( $self, $key ) = @_;
        return keys %$self unless $key;
        return $self->{$key};
    }
}

my $q = Mock::CGI->new();
$q->set_param(
    fb_sig_user => 1,
    fb_sig_session_key => 2,
    fb_sig_time => 3,
    fb_sig_in_canvas => 4,
    fb_sig => '',
    custom_1 => 5,
    custom_2 => 6,
);

my $api = WWW::Facebook::API->new();

ok $api->canvas->get_fb_params($q), 'get_fb_params returns';
is keys %{$api->canvas->get_fb_params}, 4, 'get_fb_params keys';

ok $api->canvas->get_non_fb_params, 'get_non_fb_params returns';
is keys %{$api->canvas->get_non_fb_params}, 2, 'get_non_fb_params keys';

$api->secret('foo');
ok !$api->canvas->validate_sig, 'validate_sig doesn\'t return';
$q->{'fb_sig'} = $api->generate_sig( params => $api->canvas->get_fb_params,
secret => $api->secret );
ok $api->canvas->validate_sig, 'validate_sig correct';

is $api->canvas->get_user, $q->param('fb_sig_user'), 'get_user correct';

my $cgi_no_sig = Mock::CGI->new();
$cgi_no_sig->set_param(
    fb_sig_user => 'foo',
);
isnt $api->canvas->get_user($cgi_no_sig), $q->param('fb_sig_user'),
'get_user incorrect (no sig)';

my $cgi_no_fb = Mock::CGI->new();
$cgi_no_fb->set_param(
    fb_sig => '',
);
isnt $api->canvas->get_user($cgi_no_fb), $cgi_no_fb->param('fb_sig_user'),
'get_user incorrect (no fb)';

my $cgi_has_sig = Mock::CGI->new();
$cgi_has_sig->set_param(
    fb_sig => '',
    fb_sig_user => 'foo',
);
isnt $api->canvas->get_user($cgi_has_sig), $cgi_has_sig->param('fb_sig_user'),
'get_user incorrect (bad sig)';

ok !$api->canvas->in_fb_canvas, 'not in fb_canvas';
ok $api->canvas->in_fb_canvas($q), 'in fb_canvas';

is $api->canvas->in_frame, 1, 'in frame from canvas';
$q->{'fb_sig_in_iframe'} = delete $q->{'fb_sig_in_canvas'};
is $api->canvas->in_frame($q), 1, 'in frame from iframe';
delete $q->{'fb_sig_in_iframe'};

ok !$api->canvas->in_frame($q), 'not in frame';
