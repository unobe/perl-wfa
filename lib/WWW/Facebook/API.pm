#########################################################################
# $Date$
# $Revision$
# $Author$
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.3.9');

use LWP::UserAgent;
use Time::HiRes qw(time);
use Digest::MD5 qw(md5_hex);
use CGI::Util qw(escape);

our @namespaces = qw(
    Auth            Canvas          Events
    FBML            Feed            FQL
    Friends         Groups          Notifications
    Photos          Profile         Users
);

for (@namespaces) {
    my $package = __PACKAGE__ . "::$_";
    my $name    = "\L$_";
    ## no critic
    eval qq(
        use $package;

        *${package}::base = sub { return shift->{'base'}; };
        *${package}::new = sub {
            my ( \$class, \%args ) = \@_;
            my \$self = bless \\\%args, \$class;

            delete \$self->{\$_} for grep { !/base/xms } keys %{\$self};
            \$self->\$_ for keys %{\$self};

            return \$self;
        };

        sub $name {
            my \$self = shift;
            unless ( \$self->{'_$name'} ) {
                \$self->{'_$name'} = $package->new( base => \$self );
            }
            return \$self->{'_$name'};
        }
    );
    croak "Cannot create namespace $name: $@\n" if $@;
}

our %attributes = (
    api_key => ( exists $ENV{'WFA_API_KEY'}    && $ENV{'WFA_API_KEY'} ),
    secret  => ( exists $ENV{'WFA_SECRET_KEY'} && $ENV{'WFA_SECRET_KEY'} ),
    desktop => ( exists $ENV{'WFA_DESKTOP'}    && $ENV{'WFA_DESKTOP'} ),
    parse   => 1,
    format  => 'JSON',
    debug   => 0,
    throw_errors => 1,
    api_version  => '1.0',
    apps_uri     => 'http://apps.facebook.com/',
    server_uri   => 'http://api.facebook.com/restserver.php',
    (   map { $_ => q{} }
            qw(
            last_call_success   last_error  skipcookie
            popup               next        session_key
            session_expires     session_uid callback
            app_path            ua          query
            )
    ),
);

for ( keys %attributes ) {
    ## no critic
    eval qq( 
        sub $_ {
            my \$self = shift;
            return \$self->{$_} = shift if defined \$_[0];
            return \$self->{$_} if defined \$self->{$_};
            return \$self->{$_} = '$attributes{$_}';
        }
    );
    croak "Cannot create attribute $_: $@\n" if $@;
}

sub _set_from_env {
    my $self = shift;

    my $app_path = '_' . ( $self->{'app_path'} || $self->app_path );
    $app_path =~ tr/a-z/A-Z/;
    $app_path =~ tr/A-Za-z0-9_/_/c;

    my %ENV_VARS = qw(
        WFA_API_KEY     api_key
        WFA_SECRET_KEY  secret
        WFA_DESKTOP     desktop
        WFA_SESSION_KEY session_key
    );

    for ( keys %ENV_VARS ) {
        if ( exists $ENV{ $_ . $app_path } ) {
            $self->{ $ENV_VARS{$_} } ||= $ENV{ $_ . $app_path };
        }
    }
    return;
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;
    $self->_set_from_env();    # set api_key etc. if needed

    $self->{'ua'} ||=
        LWP::UserAgent->new( agent => "Perl-WWW-Facebook-API/$VERSION" );
    my $is_attribute = join q{|}, keys %attributes;
    delete $self->{$_} for grep { !/^($is_attribute)$/xms } keys %{$self};

    # set up default namespaces
    $self->$_($self) for map {"\L$_"} @namespaces;

    # set up default attributes
    $self->$_ for keys %attributes;

    return $self;
}

sub log_string {
    my ( $self, $params, $response ) = @_;
    my $string = "\nparams = \n";

    $string .= "\t$_:$params->{$_}\n" for sort keys %{$params};
    $string .= "response =\n$response\n";

    return $string;
}

sub call_success {
    my $self = shift;
    $self->last_call_success(shift) if @_;
    $self->last_error(shift)        if @_;
    return [ $self->last_call_success, $self->last_error ];
}

sub call {
    my ( $self, $method, %args, $params, $secret, $response ) = @_;
    $self->call_success(1);

    $params = delete $args{'params'} || {};
    $params->{$_} = $args{$_} for keys %args;

    $secret = $params->{'secret'} || $self->secret;
    $params->{'method'} ||= $method;
    $self->_check_values_of($params);
    my $sig = $self->generate_sig( params => $params, secret => $secret );
    $response = $self->_post_request( $params, $secret );

    $params->{'sig'} = $sig;
    carp $self->log_string( $params, $response ) if $self->debug;
    if ($response =~ m/ <error_code> (\d+) .* <error_msg> ([^<]+)
        |   \{ "error_code" \D (\d+) .* "error_msg"[^"]+ "([^"]+)" /xms
        )
    {
        $self->call_success( 0, "$1: $2" );

        confess "Error during REST $method call:",
            $self->log_string( $params, $response )
            if $self->throw_errors;
    }

    # get actual response when web app
    if ( $params->{'callback'} ) {
        $response =~ s/^$params->{'callback'} [^\(]* \((.+) \);$/$1/xms;
    }
    undef $params;

    # ... and unescape it if it's not going to be parsed
    if ( !$self->desktop && !$self->parse ) {
        $response = $self->unescape_string($response);
    }

    if ($self->parse and $self->format eq 'XML') {
        $self->parse(0);
        carp "format is XML: setting parse to 0" if $self->debug;
    }

    return $response if !$self->parse;

    return $self->_parse($response);
}

sub generate_sig {
    my ( $self, %args ) = @_;
    my %params = %{ $args{'params'} };
    return md5_hex( ( map {"$_=$params{$_}"} sort keys %params ),
        $args{'secret'} );
}

sub verify_sig {
    my ( $self, %args ) = @_;
    return $args{'sig'} eq $self->generate_sig(
        params => $args{'params'},
        secret => $args{'secret'} || $self->secret,
    );
}

sub session {
    my ( $self, %args ) = @_;
    $self->{"session_$_"} = $args{$_} for keys %args;
    return;
}

sub redirect {
    my $self = shift;
    my $url  = shift;
    $self->query(shift);

    if ( $self->canvas->in_fb_canvas ) {
        return qq{<fb:redirect url="$url" />};
    }
    elsif ( $url =~ m[^https?://([^/]*\.)?facebook\.com(:\d+)?]ixms ) {
        return join q{},
            map {"$_\n"}
            '<script type="text/javascript">'
            . qq{top.location.href = "$url"}
            . '</script>';
    }

    croak 'Cannot redirect!' unless $self->query->can('redirect');

    return $self->query->redirect($url);
}

sub require_add   { return shift->require( 'add',   @_ ); }
sub require_frame { return shift->require( 'frame', @_ ); }
sub require_login { return shift->require( 'login', @_ ); }

sub require {    ## no critic
    my $self = shift;
    my $what = shift;
    $self->query(shift) if @_;

    if ( $what eq 'frame' ) {
        return if $self->canvas->in_frame;
        @_ = ( 'canvas' => 1 );
        $what = 'login';
    }

    my $user = $self->users->get_logged_in_user();
    if ( $what eq 'add' ) {
        undef $user unless $self->canvas->get_fb_params->{'added'};
    }
    return $user if $user;

    return $self->redirect( $self->get_url( $what, @_ ) );
}

sub get_facebook_url { return shift->get_url( 'facebook', @_ ); }
sub get_add_url      { return shift->get_url( 'add',      @_ ); }
sub get_infinite_session_url { return shift->get_url('infinite_session'); }
sub get_login_url            { return shift->get_url( 'login', @_ ); }
sub get_app_url              { return shift->get_url( 'app', @_ ); }

sub get_url {
    my $self = shift;
    my $type = shift;

    if ( $type eq 'facebook' ) {
        my $site = shift || 'www';
        return "http://$site.facebook.com";
    }

    if ( $type eq 'app' ) {
        return $self->apps_uri . $self->app_path . q{/};
    }

    return $self->get_url('facebook')
        . (
          $type eq 'add'              ? '/add.php'
        : $type eq 'infinite_session' ? '/codegen.php'
        : $type eq 'login'            ? '/login.php'
        : q{}
        ) . $self->_add_url_params(@_);
}

sub unescape_string {
    my $self   = shift;
    my $string = shift;
    $string =~ s/(?<!\\)(\\.)/qq("$1")/xmsgee;
    return $string;
}

sub _add_url_params {
    my $self   = shift;
    my $params = q{?api_key=} . $self->api_key . q{&v=1.0};
    my %params = @_;
    for ( sort keys %params ) {
        next if not defined $params{$_};
        $params{$_} = escape( $params{$_} ) if $_ eq 'next';
        $params .= "&$_=$params{$_}";
    }
    return $params;
}

sub _parser {
    my $parser = JSON::Any->new;

    # JSON::Any needs to get fixed
    $parser->handler->allow_nonref() if $parser->handlerType eq 'JSON::XS';
    return $parser;
}

sub _parse {
    my ( $self, $response ) = @_;

    # Some shortcuts
    return q{} if $response =~ /\A"?"?\Z/xms;
    return 1   if $response =~ /\A"?true"?\Z/xms;
    return 0   if $response =~ /\A"?false"?\Z/xms;

    my $parser;
    eval { $parser = _parser() };

    # Only load JSON::Any if we haven't already.  Lets the developers
    # pick their choice of JSON modules (JSON::DWIW, for example)
    if ($@) {    ## no critic
        ## no critic
        eval q{use JSON::Any};
        croak "Unable to load JSON module for parsing:$@\n" if $@;
        $parser = _parser();
    }
    carp 'JSON::Any is parsing with ' . $parser->handlerType if $self->debug;

    return $parser->decode($response);
}

sub _check_values_of {
    my ( $self, $params ) = @_;

    if ( $self->desktop ) {
        $params->{'call_id'} = time if $self->desktop;
    }

    if ( $params->{'method'} !~ m/^auth/xms ) {
        $params->{'session_key'} = $self->session_key;
        if ( !$params->{'callback'} && $self->callback ) {
            $params->{'callback'} = $self->callback;
        }
    }

    $params->{'method'} = "facebook.$params->{'method'}";
    $params->{'v'} ||= $self->api_version;

    $params->{$_} ||= $self->$_ for qw(api_key format);
    return;
}

sub _post_request {
    my ( $self, $params, $secret, $sig, $post_params ) = @_;

    $self->_format_params($params);
    $sig = $self->generate_sig( params => $params, secret => $secret );
    $post_params = [ map { $_ => $params->{$_} } sort keys %{$params} ];
    push @{$post_params}, q{sig}, $sig;

    return $self->ua->post( $self->server_uri, $post_params )->content;
}

sub _format_params {
    my $self   = shift;
    my $params = shift;

    # reformat arrays and add each param to digest
    for ( keys %{$params} ) {
        next unless ref $params->{$_} eq 'ARRAY';
        $params->{$_} = join q{,}, @{ $params->{$_} };
    }
    return;
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API - Facebook API implementation

=head1 VERSION

This document describes WWW::Facebook::API version 0.3.9

=head1 SYNOPSIS

    use WWW::Facebook::API;

    # @ENV{qw/WFA_API_KEY WFA_SECRET_KEY WFA_DESKTOP/} are the initial values,
    # so use those if you only have one app and don't want to pass in values
    # to constructor
    my $client = WWW::Facebook::API->new(
        desktop => 0,
        api_key => 'your api key',
        secret => 'your secret key',
    );
    
    # Change API key and secret
    print "Enter your public API key: ";
    chomp( my $val = <STDIN> );
    $client->api_key($val);
    print "Enter your API secret: ";
    chomp($val = <STDIN> );
    $client->secret($val);
    
    # not needed if web app (see $client->canvas->get_fb_params)
    $client->auth->get_session( $token );
    
    use Data::Dumper;
    my $friends_perl = $client->friends->get;
    print Dumper $friends_perl;
    
    my $notifications_perl = $client->notifications->get;
    print Dumper $notifications_perl;
    
    # Current user's quotes
    my $quotes_perl = $client->users->get_info(
        uids   => $friends_perl,
        fields => ['quotes']
    );
    print Dumper $quotes_perl;
    
    $client->auth->logout;

=head1 DESCRIPTION

A Perl implementation of the Facebook API, working off of the canonical Java
and PHP implementations. By default it uses L<JSON::Any> to parse the response
returned by Facebook's server. There is an option to return the raw response
in either XML or JSON (See the C<parse> method below). As the synopsis states,
the following environment variables are used to set the defaults for new
instances:

    WFA_API_KEY
    WFA_SESSION_KEY
    WFA_DESKTOP

Additionally, for each instance that is created, the following environment
variables are used if no values are set:

    WFA_API_KEY_APP_PATH
    WFA_SESSION_KEY_APP_PATH
    WFA_DESKTOP_APP_PATH

Where C<APP_PATH> is replaced by whatever $client->app_path returns, with all
non-alphanumeric characters replaced with an underscore and all characters
upcased (e.g., foo-bar-baz becomes FOO_BAR_BAZ).

=head1 SUBROUTINES/METHODS 

=over

=item new( %params )

Returns a new instance of this class. You are able to pass in any of the
attribute method names in L<WWW::Facebook::API> to set its value:

    my $client = WWW::Facebook::API->new(
        parse           => 1,
        format          => 'JSON',
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
    );
    $copy = $client->new;

=back

=head1 NAMESPACE METHODS

All method names from the Facebook API are lower_cased instead of CamelCase.

=over

=item auth

For desktop apps, these are synonymous:

    $client->auth->get_session( $client->auth->create_token );
    $client->auth->get_session;

And that's all you really have to do (but see L<WWW::Facebook::API::Auth> for
details about opening a browser on *nix for Desktop apps). C<get_session>
automatically sets C<session_uid>, C<session_key>, and C<session_expires> for
C<$client>. It returns nothing.

If the desktop attribute is set to false the C<$token> must be the auth_token
returned from Facebook to your web app for that user:

    if ( $q->param('auth_token')  ) {
        $client->auth->get_session( $q->param('auth_token') );
    }

C<get_session> automatically sets C<session_uid>, C<session_key>, and
C<session_expires> for C<$client>. It returns nothing.

See L<WWW::Facebook::API::Auth> for details.

=item canvas

Work with the canvas. See L<WWW::Facebook::API::Canvas>.

    $response = $client->canvas->get_user( $q )
    $response = $client->canvas->get_fb_params( $q )
    $response = $client->canvas->get_non_fb_params( $q )
    $response = $client->canvas->validate_sig( $q )
    $response = $client->canvas->in_fb_canvas( $q )
    $response = $client->canvas->in_frame( $q )

=item events

events namespace of the API (See L<WWW::Facebook::API::Events>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->events->get( uid => 234233, eids => [23,2343,54545] );
    $response = $client->events->get_members( eid => 233 );

=item fbml

fbml namespace of the API (See L<WWW::Facebook::API::FBML>):
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->fbml->set_ref_handle( handle => '', fbml => '');
    $response = $client->fbml->refresh_img_src( url => '');
    $response = $client->fbml->refresh_ref_url( url => '');

=item fql

fql namespace of the API (See L<WWW::Facebook::API::FQL>):

    $response = $client->fql->query( query => 'FQL query' );


=item feed

feed namespace of the API (See L<WWW::Facebook::API::Feed>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response 
        = $client->feed->publish_story_to_user(
            title   => 'title',
            body    => 'markup',
            priority => 5,
            ...
    );
    $response 
        = $client->feed->publish_action_of_user(
            title   => 'title',
            body    => 'markup',
            priority => 7,
            ...
    );

=item friends

friends namespace of the API (See L<WWW::Facebook::API::Friends>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->friends->get;
    $response = $client->friends->get_app_users;
    $response
        = $client->friends->are_friends( uids1 => [1,5,8], uids2 => [2,3,4] );

=item groups

groups namespace of the API (See L<WWW::Facebook::API::Groups>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->groups->get( uid => 234324, gids => [2423,334] );
    $response = $client->groups->get_members( gid => 32 );

=item notifications

notifications namespace of the API (See L<WWW::Facebook::API::Notifications>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->notifications->get;
    $response = $client->notifications->send(
        to_ids => [ 1, 3 ],
        markup => 'markup',
        no_email => 1,
    );
    $response = $client->notifications->send_request(
        to_ids => [ 1, 2 ],
        type => 'event',
        content => 'markup',
        image   => 'image url',
        invite  => 0|1,
    );

=item photos

photos namespace of the API (See L<WWW::Facebook::API::Photos>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->photos->add_tag(
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

    $response = $client->profile->get_fbml( uid => 3 );
    $response = $client->profile->set_fbml( uid => 5, markup => 'markup' );

=item update

update namespace of the API (See L<WWW::Facebook::API::Update>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->update->decode_ids( ids => [5,4,3] );

=item users

users namespace of the API (See L<WWW::Facebook::API::Users>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->users->get_info(
        uids => [12,453,67],
        fields => ['quotes','activities','books']
    );

=back

=head1 ATTRIBUTE METHODS

These are methods to get/set the object's attributes.

=over

=item api_key( $new_api_key )

The developer's API key. If C<$ENV{'WFA_API_KEY'}> is set, all instances will
be initialized with its value. See the Facebook API documentation for more
information.

=item api_version( $new_version )

Which version to use (default is "1.0", which is the only one supported
currently. Corresponds to the argument C<v> that is passed in to methods as a
parameter.

=item app_path()

If using the Facebook canvas, the path to your application. For example if your
application is at http://apps.facebook.com/example/ this should be C<"example">.

=item apps_uri()

The apps uri for Facebook apps. The default is http://apps.facebook.com/.

=item callback( $new_default_callback )

The callback URL for your application. See the Facebook API documentation.
Just a convenient place holder for the value.

=item call_success( $is_success, $error_message )

Takes in two values, the first setting the object's last_call_success
attribute, and the second setting the object's last_error attribute. Returns
an array reference containing the last_call_success and last_error values, in
that order:

    my $response = $client->call_success( 1, undef );
    if ( $response->[0] == 1 ) {
        print 'Last call successful';
    }
    if ( not defined $response->[1] ) {
        print 'Error message is undefined';
    }

    $client->call_success( 0,'2: The service is not available at this time.');

    $response = $client->call_success;
    if ( not $response->[0] ) {
        print 'Last call unsuccessful';
    }
    if ( not defined $response->[1] ) {
        print "Error $response->[1]";
    }

The C<call> method calls this method, and shouldn't need to be called to set
anything, just to get the value later if C<throw_errors> is false.

=item debug(0|1)

A boolean set to either true or false, determining if debugging messages
should be carped for REST calls. Defaults to 0.

=item desktop(0|1)

A boolean signifying if the client is being used for a desktop application.
If C<$ENV{'WFA_DESKTOP'}> is set, all instances will be initialized with its
value. Defaults to 0 otherwise. See the Facebook API documentation for more
information.

=item format('JSON'|'XML')

The default format to use if none is supplied with an API method call.
Currently available options are XML and JSON. Defaults to JSON.

=item last_call_success(1|0)

A boolean set to true or false, to show whether the last call was succesful
or not. Called by C<call_success>. Defaults to 1.

=item last_error( $error_message )

A string holding the error message of the last failed call to the REST server.
Called by C<call_success>. Defaults to undef.

=item next( $new_default_next_url )

See the Facebook API documentation's Authentication Guide. Just a convenient
place holder for the value.

=item parse(1|0)

Defaults to 1. If set to true, the response returned by each method call will
be a Perl structure (see each method for the structure it will return). If it
is set to 0, the response string from the server will be returned. (The
response string is unescaped if the 'desktop' attribute is false).

=item popup( $popup )

See the Facebook API documentation's Authentication Guide. Just a convenient
place holder for the value.

=item query( $query )

Stores the current query object to use (either L<CGI> or L<Apache::Request>)
but really anything that implements the C<param()> method can be used. B<N.B.
When using C<require_*> methods below, Apache::Request will croak because it
does not implement a redirect method.>

=item secret( $new_secret_key )

For a desktop application, this is the secret that is used for calling
C<auth->create_token> and C<auth->get_session>. For a web application, secret
is used for all calls to the API. If C<$ENV{'WFA_SECRET_KEY'}> is set, all
instances will be initialized with its value. See the Facebook API
documentation under Authentication for more information.

=item server_uri( $new_server_uri )

The server uri to access the Facebook REST server. Default is
C<'http://api.facebook.com/restserver.php'>. Used to make calls to the
Facebook server, and useful for testing. See the Facebook API documentation. 

=item session_expires( $new_expires )

The session expire timestamp for the client's user. Automatically set when
C<$client->auth->get_session> is called. See the Facebook API documentation. 

=item session_key( $new_key )

The session key for the client's user. Automatically set when
C<<$client->auth->get_session>> is called. See the Facebook API documentation.

=item session_uid( $new_uid )

The session's uid for the client's user. Automatically set when
C<<$client->auth->get_session>> is called. See the Facebook API documentation.

=item skipcookie(0|1)

See the Facebook API documentation's Authentication Guide. Just a convenient
place holder for the value.

=item throw_errors(0|1)

A boolean set to either true of false, signifying whether or not to C<confess>
when an error is returned from the REST server.

=item ua

The L<LWP::UserAgent> agent used to communicate with the REST server.
The agent_alias is initially set to "Perl-WWW-Facebook-API/0.3.9".

=back

=head1 PUBLIC METHODS

=over

=item call( $method, %args )

The method which other submodules within L<WWW::Facebook::API> use
to call the Facebook REST interface. It takes in a string signifying the method
to be called (e.g., 'auth.getSession'), and key/value pairs for the parameters
to use:
    $client->call( 'auth.getSession', auth_token => 'b3324235e' );

=item generate_sig( params => $params_hashref, secret => $secret )

Generates a sig when given a parameters hash reference and a secret key.

=item get_add_url( %params )

Returns the URL to add your application with the parameters (that are given)
included. Note that the API key and the API version parameters are also
included automatically. If the C<next> parameter is passed in, it's
string-escaped. Used for platform applications:

    $response = $client->get_add_url( next => 'http://my.website.com' );

    # prints http://www.facebook.com/app.php?api_key=key&v=1.0
    #        &next=http%3A%2F%2Fmy.website.com
    print $response;

=item get_app_url

Returns the URL to your application, if using the Facebook canvas. Uses
<$client->app_path>, which you have to set yourself (See <app_path> below).

=item get_facebook_url( $subdomain )

Returns the URL to Facebook. You can specifiy a specific network as a
parameter:

    $response = $client->get_facebook_url( 'apps' );
    print $response;    # prints http://apps.facebook.com

=item get_infinite_session_url()

Returns the URL for the user to generate an infinite session for your
application:

    $response = $client->get_infinite_session_url;

    # prints http://www.facebook.com/codegen.php?api_key=key&v=1.0
    print $response;

From what I've seen, the session keys that Facebook returns don't expire
automatically, so as long as you don't call $client->auth->logout, you
shouldn't even need to worry about this.

=item get_login_url( %params )

Returns the URL to login to your application with the parameters (that are
defined) included. If the C<next> parameter is passed in, it's string-escaped:

    $response = $client->get_login_url( next => 'http://my.website.com' );

    # prints http://www.facebook.com/login.php?api_key=key&v=1.0
    #        &next=http%3A%2F%2Fmy.website.com
    print $response;

=item get_url( $type, @args )

Called by all the above C<get_*_url> methods above. C<$type> can be C<'login'>,
C<'app'>, C<'add'>, C<'facebook'>, or C<'infinite_session'>. C<@args> is
either a scalar (in the case when C<$type> is C<'facebook'>) or a hash. All of
these C<get_*_url> methods correspond to the ones in the official PHP client.

=item log_string($params_hashref, $response)

Pass in the params and the response from a call, and it will make a formatted
string out of it showing the parameters used, and the response received.

=item redirect( $url, $query_object )

Called by C<require()> to redirect the user either within the canvas or
without. This, as with C<require()> is only really useful when having a web
app. If no <$query_object> is defined, then whatever is in C<$self->query>
will be used. (See L<WWW::Facebook::API::Canvas>)

=item require_add( $query )

Redirects the user to what C<get_add_url()> returns. See C<require()> below
for the C<$query> parameter.

=item require_frame( $query )

Redirects the user to what C<get_login_url( canvas => '1' )> returns. See
C<require()> below for the C<$query> parameter.


=item require_login( $query )

Redirects the user to what C<get_login_url()> returns. See C<require()> below
for the C<$query> parameter.

=item require( $what, $query )

The official PHP client has C<require_*> methods that take no arguments.
Logically, you better know what you want to require when you call each of
them, so this API consolidates them into one method. The valid values for
C<$what> are C<'add'>, C<'frame'>, and C<'login'>. C<$query> is the query
object to use (most likely L<CGI>). If C<$query> is undefined, the value of
C<$self->query> is used.

=item session( uid => $uid, key => $session_key, expires => $session_expires )

Sets the C<user>, C<session_key>, and C<session_expires> all at once.

=item unescape_string($escaped_string)

Returns its parameter with all the escape sequences unescaped. If you're using
a web app, this is done automatically to the response.

=item verify_sig( sig => $expected_sig, params => $params_hashref )

Checks the signature for a given set of parameters against an expected value.

=back

=head1 PRIVATE METHODS

=over

=item _add_url_params( %params )

Called by both C<get_login_url> and C<get_add_url> to process any of their
parameters. Prepends the api_key and the version number as parameters and
returns the parameter string.

=item _check_values_of($params_hashref)

Makes sure all the values of the C<$params_hashref> that need to be set are
set. Uses the defaults for those values that are needed and not supplied.

=item _format_params($params_hashref)

Format parameters according to Facebook API specification.

=item _post_request( $params_hashref, $secret )

Used by C<call> to post the request to the REST server and return the
response.

=item _parse($string)

Parses the response from a call to the Facebook server to make it a Perl data
structure, and returns the result.

=item _parser()

Returns a new instance of JSON::Any.

=back

=head1 DIAGNOSTICS

=over

=item C<< Unable to load JSON module for parsing: %s >>

L<JSON::Any> was not able to load one of the JSON modules it uses to parse
JSON. Please make sure you have one (of the several) JSON modules it can use
installed.

=item C<< Error during REST call: %s >>

This means that there's most likely an error in the server you are using to
communicate to the Facebook REST server. Look at the traceback to determine
why an error was thrown. Double-check that C<server_uri> is set to the right
location.

=item C<< Cannot create namespace %s: %s >>

Cannot create the needed subclass method. Contact the developer to report.

=item C<< Cannot create attribute %s: %s >>

Cannot create the needed attribute method. Contact the developer to report.

=item C<< Cannot redirect without redirect method! >>

You're not using L<CGI> as a query object when calling C<redirect()> (or one
of the C<require_*> methods. The query object you're using must implement the
C<redirect()> method as L<CGI> does.

=back

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Facebook::API requires no configuration files or environment variables.

=head1 DEPENDENCIES

L<version>
L<Crypt::SSLeay>
L<Digest::MD5>
L<JSON::Any>
L<Time::HiRes>
L<LWP::UserAgent>

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-facebook-api@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SOURCE REPOSITORY

http://code.google.com/p/perl-www-facebook-api/

=head1 TESTING

There are some live tests included, but they are only run if the following
environment variables are set:
    WFA_API_KEY_TEST
    WFA_SECRET_KEY_TEST
    WFA_SESSION_KEY_TEST

Additionally, if your app is a desktop one, you must set C<WFA_DESKTOP_TEST>.
Also, the session key must be valid for the API key being used.

With live tests enabled, here is the current test coverage:

  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  File                           stmt   bran   cond    sub    pod   time  total
  ---------------------------- ------ ------ ------ ------ ------ ------ ------
  blib/lib/WWW/Facebook/API.pm   93.7   75.8   67.6   92.6  100.0    5.5   88.9
  .../WWW/Facebook/API/Auth.pm   94.7   66.7  100.0   87.5  100.0   94.1   88.8
  ...WW/Facebook/API/Canvas.pm   97.6   87.5  100.0  100.0  100.0    0.0   97.1
  ...WW/Facebook/API/Events.pm  100.0    n/a    n/a  100.0  100.0    0.1  100.0
  .../WWW/Facebook/API/FBML.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
  ...b/WWW/Facebook/API/FQL.pm  100.0  100.0  100.0  100.0  100.0    0.0  100.0
  .../WWW/Facebook/API/Feed.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
  ...W/Facebook/API/Friends.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
  ...WW/Facebook/API/Groups.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
  ...book/API/Notifications.pm   86.7    n/a    n/a   71.4  100.0    0.0   84.0
  ...WW/Facebook/API/Photos.pm  100.0    n/a    n/a  100.0  100.0    0.0  100.0
  ...W/Facebook/API/Profile.pm   87.5    n/a    n/a   75.0  100.0    0.0   85.7
  ...WWW/Facebook/API/Users.pm   86.7    n/a    n/a   71.4  100.0    0.0   84.0
  Total                          94.5   75.9   73.3   92.3  100.0  100.0   90.7
  ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>

=head1 CONTRIBUTORS

Clayton Scott C<< http://www.matrix.ca >>

David Leadbeater C<< http://dgl.cx >>

Gisle Aas C<< none >>

J. Shirley C<< <jshirley@gmail.com> >>

Jim Spath C<< <jspath@gmail.com> >>

Matt Sickler C<< <imMute@mail.msk3.ath.cx> >>

Nick Gerakines C<< <nick@socklabs.com> >>

Olaf Alders C<< <olaf@wundersolutions.com> >>

Patrick Michael Kane C<< <pmk@wawd.com> >>

Sean O'Rourke C<< <seano@cpan.org> >>

Shawn Van Ittersum C<< none >>

Simon Cavalletto C<< <simonm@cavalletto.org> >>

Skyler Clark C<< none >>

Thomas Sibley C<< <tsibley@cpan.org> >>

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
