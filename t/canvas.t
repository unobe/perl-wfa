#######################################################################
# $Date: 2007-06-28 13:05:21 -0700 (Thu, 28 Jun 2007) $
# $Revision: 120 $
# $Author: david.romano $
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More 'no_plan';    # tests => 15;
use WWW::Facebook::API;
use strict;
use warnings;

{

    package Mock::CGI;
    sub new { return bless {}, $_[0]; }

    sub set_param {
        my ( $self, %param_new ) = @_;
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
    fb_sig_user        => 1,
    fb_sig_session_key => 2,
    fb_sig_time        => 3,
    fb_sig_in_canvas   => 4,
    fb_sig             => '',
    custom_1           => 5,
    custom_2           => 6,
);

my $api = WWW::Facebook::API->new();

ok $api->canvas->get_fb_params($q), 'get_fb_params returns';
is keys %{ $api->canvas->get_fb_params }, 4, 'get_fb_params keys';

ok $api->canvas->get_non_fb_params, 'get_non_fb_params returns';
is keys %{ $api->canvas->get_non_fb_params }, 2, 'get_non_fb_params keys';

$api->secret('foo');
ok !$api->canvas->validate_sig, 'validate_sig doesn\'t return';
$q->{'fb_sig'} = $api->generate_sig(
    params => $api->canvas->get_fb_params,
    secret => $api->secret
);
ok $api->canvas->validate_sig, 'validate_sig correct';

is $api->canvas->get_user, $q->param('fb_sig_user'), 'get_user correct';

my $cgi_no_sig = Mock::CGI->new();
$cgi_no_sig->set_param( fb_sig_user => 'foo', );
isnt $api->canvas->get_user($cgi_no_sig), $q->param('fb_sig_user'),
    'get_user incorrect (no sig)';

my $cgi_no_fb = Mock::CGI->new();
$cgi_no_fb->set_param( fb_sig => '', );
isnt $api->canvas->get_user($cgi_no_fb), $cgi_no_fb->param('fb_sig_user'),
    'get_user incorrect (no fb)';

my $cgi_has_sig = Mock::CGI->new();
$cgi_has_sig->set_param(
    fb_sig      => '',
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

$api->api_key(23432);
is $api->require_frame,
    qq{<script type="text/javascript">top.location.href = "http://www.facebook.com/login.php?api_key=23432&v=1.0&canvas"</script>\n},
    'require frame outside frame';

$q->{'fb_sig_in_iframe'} = 1;
ok !$api->require_frame($q), 'require_frame in frame';

is $api->require_login,
    qq{<script type="text/javascript">top.location.href = "http://www.facebook.com/login.php?api_key=23432&v=1.0&canvas"</script>\n},
    'require_login in frame';

delete $q->{'fb_sig_in_iframe'};
is $api->require_login($q),
    qq{<script type="text/javascript">top.location.href = "http://www.facebook.com/login.php?api_key=23432&v=1.0"</script>\n},
    'require_login outside frame';

$q->{'fb_sig_in_canvas'} = 1;
ok !$api->require_frame($q), 'require_frame in canvas';

is $api->require_login,
    qq{<fb:redirect url="http://www.facebook.com/login.php?api_key=23432&v=1.0&canvas" />},
    'require_login in canvas';

delete $q->{'fb_sig_in_canvas'};
is $api->require_login($q),
    qq{<script type="text/javascript">top.location.href = "http://www.facebook.com/login.php?api_key=23432&v=1.0"</script>\n},
    'require_login outside canvas';

is $api->require_add, qq{<script type="text/javascript">top.location.href = "http://www.facebook.com/add.php?api_key=23432&v=1.0"</script>\n}, 
'require_add w/o fb_sig_added';

$api->session_uid(123);
$q->{'fb_sig_added'} = 1;
is $api->require_add($q), 123, 'require_add w/uid';
delete $q->{'fb_sig_added'};

is $api->require_frame, 123, 'require_frame w/uid';
is $api->require_login, 123, 'require_login w/uid';
