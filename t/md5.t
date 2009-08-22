#######################################################################
# ex: set ts=8 sw=4 et
#########################################################################
use Test::More tests => 3;
use strict;
use warnings;

BEGIN { use_ok('WWW::Facebook::API'); }

chdir 't' if -d 't';

my %params = (
    v           => '1.0',
    session_key => 'f849e13d7c31bd1815eab65a-3309787',
    call_id     => 1180528987.70698,
    api_key     => 'an amazing summer is awaiting',
    format      => 'XML',
    method      => 'facebook.profile.setFBML',
);
my $sig    = 'f73d589a6f305f914b0086654f0b7f43';
my $secret = 'garden';
$params{'markup'} = join '', <DATA>;
my $api = WWW::Facebook::API->new;

is $api->generate_sig(
    params => \%params,
    secret => $secret
    ),
    $sig, 'signature generation okay';

$api->secret($secret);
is $api->verify_sig( params => \%params, sig => $sig ), 1, 'verify_sig ok';

__DATA__
<h3>Friends With Shared Interests</h3>

<table class="users">


<tr>
	<td><a href="/user/0000"><img src="http://XXXXXXXXXXX.facebook.com/ip002/v52/1863/115/t4802098_400.jpg" border=0></a></td>
	<td>
		<b><a href="/user/0000">XXX XXXXXX Darga</a></b><br>
		19 shared interests
		<a href="/user/0000">XXX XXXXXX interests</a>
	</td>
</tr>



<tr>
	<td><a href="/user/0000"><img src="http://XXXXXXXXXXX.facebook.com/ip008/profile2/729/105/t4813185_26882.jpg" border=0></a></td>
	<td>
		<b><a href="/user/0000">XXX XXXXXX Duong</a></b><br>
		6 shared interests
		<a href="/user/0000">XXX XXXXXX interests</a>
	</td>
</tr>



<tr>
	<td><a href="/user/0000"><img src="http://XXXXXXXXXXX.facebook.com/ip008/profile2/979/23/t30305005_26835.jpg" border=0></a></td>
	<td>
		<b><a href="/user/0000">XXX XXXXXX Szakal</a></b><br>
		5 shared interests
		<a href="/user/0000">XXX XXXXXX interests</a>
	</td>
</tr>



<tr>
	<td><a href="/user/0000"><img src="http://XXXXXXXXXXX.facebook.com/ip002/profile5/1969/96/t502789150_4966.jpg" border=0></a></td>
	<td>
		<b><a href="/user/0000">XXX XXXXXX Murphy</a></b><br>
		4 shared interests
		<a href="/user/0000">XXX XXXXXX interests</a>
	</td>
</tr>



<tr>
	<td><a href="/user/0000"><img src="" border=0></a></td>
	<td>
		<b><a href="/user/0000">XXX XXXXXX Park</a></b><br>
		4 shared interests
		<a href="/user/0000">XXX XXXXXX interests</a>
	</td>
</tr>


</table>
