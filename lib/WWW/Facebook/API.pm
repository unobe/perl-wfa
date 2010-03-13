#########################################################################
# ex: set ts=8 sw=4 et
#########################################################################
package WWW::Facebook::API;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.4.18');

use LWP::UserAgent;
use Time::HiRes qw(time);
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8 is_utf8);
use CGI;
use CGI::Util qw(escape);

use WWW::Facebook::API::Exception;

our @namespaces = qw(
    Admin           Application     Auth
    Canvas          Comments        Connect
    Data            Events          FBML
    Feed            FQL             Friends
    Groups          Intl            Links
    LiveMessage     Message         Notes
    Notifications   Pages           Permissions
    Photos          Profile         SMS
    Status          Stream          Users
    Video
);

for (@namespaces) {
    my $package = __PACKAGE__ . "::$_";
    my $name    = "\L$_";
    ## no critic
    my $namespace = eval qq(
        use $package;

        sub $name {
            my \$self = shift;
            unless ( \$self->{'_$name'} ) {
                \$self->{'_$name'} = $package->new( base => \$self );
            }
            return \$self->{'_$name'};
        }

        package $package;
        sub base { return shift->{'base'}; };
        sub new {
            my ( \$class, \%args ) = \@_;
            my \$self = bless \\\%args, \$class;

            delete \$self->{\$_} for grep { !/base/xms } keys %{\$self};
            \$self->\$_ for keys %{\$self};

            return \$self;
        };
        1;

    );
    croak "Cannot create namespace $name: $@\n" if not $namespace;
}

our %attributes = (
    parse        => 1,
    format       => 'JSON',
    debug        => 0,
    throw_errors => 1,
    api_version  => '1.0',
    apps_uri     => 'http://apps.facebook.com/',
    server_uri   => 'http://api.facebook.com/restserver.php',
    (   map { $_ => q{} }
            qw(
            api_key             secret      desktop
            last_call_success   last_error  skipcookie
            popup               next        session_key
            session_expires     session_uid callback
            app_path            ua          query
            config              app_id      call_as_apikey
            )
    ),
);

for ( keys %attributes ) {
    ## no critic
    my $attribute = eval qq( 
        sub $_ {
            my \$self = shift;
            return \$self->{$_} = shift if defined \$_[0];
            return \$self->{$_} if defined \$self->{$_};
            return \$self->{$_} = '$attributes{$_}';
        }
        1;
    );
    croak "Cannot create attribute $_: $@\n" if not $attribute;
}

sub _set_from_outside {
    my $self = shift;

    my $app_path = '_' . ( $self->{'app_path'} || $self->app_path );
    $app_path =~ tr/a-z/A-Z/;
    $app_path =~ tr/A-Za-z0-9_/_/c;

    my %ENV_VARS = qw(
        WFA_API_KEY     api_key
        WFA_SECRET      secret
        WFA_DESKTOP     desktop
        WFA_SESSION_KEY session_key
    );

    $self->_set_from_file( $app_path, %ENV_VARS ) if $self->{'config'};
    $self->_set_from_env( $app_path, %ENV_VARS );

    return;
}

sub _set_from_file {
    my $self     = shift;
    my $app_path = shift;
    my %ENV_VARS = @_;

    open my $config, '<', $self->{'config'}    ## no critic
        or croak "Cannot open $self->{'config'}";

    while (<$config>) {
        carp "Config line: $_" if $self->{'debug'};
        chomp;
        my ( $key, $val ) = split m/=/xms, $_, 2;
        next if !$key;
        carp "Key/Val pair: $key -> $val" if $self->{'debug'};
        for ( $key, $val ) {
            s/\A\s+//xms;
            s/\s+\Z//xms;
        }
        $ENV{$key} ||= $val;
    }

    close $config or croak "Cannot close $self->{'config'}";

    return;
}

sub _set_from_env {
    my $self     = shift;
    my $app_path = shift;
    my %ENV_VARS = @_;

    for ( keys %ENV_VARS ) {
        if ( exists $ENV{ $_ . $app_path } ) {
            $self->{ $ENV_VARS{$_} } ||= $ENV{ $_ . $app_path };
        }
        elsif ( exists $ENV{$_} ) {
            $self->{ $ENV_VARS{$_} } ||= $ENV{$_};
        }
    }

    return;
}

sub new {
    my ( $self, %args ) = @_;
    my $class = ref $self || $self;
    $self = bless \%args, $class;
    $self->_set_from_outside();    # set api_key etc. if needed

    $self->{'ua'} ||=
        LWP::UserAgent->new( agent => "Perl-WWW-Facebook-API/$VERSION" );
    my $is_attribute = join q{|}, keys %attributes;
    delete $self->{$_} for grep { !/^ $is_attribute $/xms } keys %{$self};

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
    my ( $self, $method, %args ) = @_;
    my ( $response, $params, $sig, $raw_data, $filename );
    $self->call_success(1);

    if ( $self->call_as_apikey ) { 
         $args{'call_as_apikey'} = $self->call_as_apikey;
    }

    ( $params, $raw_data, $filename ) =
        $self->_format_and_check_params( $method, %args );
    $sig = $self->generate_sig(
        params => $params,
        secret => delete $params->{'secret'},
    );

    $response = $self->_post_request( $params, $sig, $raw_data, $filename );

    carp $self->log_string( $params, $response ) if $self->debug;
    if ( $self->_has_error_response($response) ) {
        if ( $self->throw_errors ) {
            warn WWW::Facebook::API::Exception->new(
                $method, $params, $response
            );
        }
    }

    return $self->_reformat_response( $params, $response );
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
    elsif ($url =~ m{^https?://([^/]*\.)?facebook\.com(:\d+)?}ixms
        && $self->session_uid )
    {
        return join q{},
            map {"$_\n"}
            '<script type="text/javascript">'
            . qq{top.location.href = "$url"}
            . '</script>';
    }

    print CGI->new->redirect(
        $self->get_app_url( next => $self->get_login_url ) );
    return 1;
}

sub require_add   { return shift->require( 'add',   @_ ); }
sub require_frame { return shift->require( 'frame', @_ ); }
sub require_login { return shift->require( 'login', @_ ); }

sub require {    ## no critic
    my $self = shift;
    my $what = shift;
    $self->query(shift);

    if ( $what eq 'login' ) {
        unshift @_, qw( canvas ) if $self->canvas->in_frame;
    }
    if ( $what eq 'frame' ) {
        return if $self->canvas->in_frame;
        unshift @_, qw( canvas );
        $what = 'login';
    }

    my $user = $self->canvas->get_fb_params->{'user'};
    if ( $what eq 'add' ) {
        if ( !$self->canvas->get_fb_params->{'added'} ) {
            $user = undef;
        }
    }
    return if $user;

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

    if ( $type eq 'custom' ) {
        return (shift) . $self->_add_url_params(@_);
    }

    return $self->get_url('facebook')
        . (
          $type eq 'add'              ? '/add.php'
        : $type eq 'infinite_session' ? '/code_gen.php'
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
    if (@_) {
        if ( @_ % 2 ) {

            # Odd number of elelemts, so didn't pass in canvas => 1
            $params .= q{&canvas} if grep { $_ eq 'canvas' } @_;  ## no critic
            @_ = grep { $_ ne 'canvas' } @_;
        }
        my %params = @_;
        $params .= q{&canvas} if delete $params{'canvas'};

        for ( sort keys %params ) {
            next if not defined $params{$_};
            $params{$_} = escape( $params{$_} ) if $_ eq 'next';
            $params .= "&$_=$params{$_}";
        }
    }
    return $params;
}

sub _parser {
    my $parser = JSON::Any->new;

    $parser->handler->allow_nonref;
    return $parser;
}

sub _parse {
    my ( $self, $response ) = @_;

    # Some shortcuts
    return q{} if $response =~ /\A"?"?\Z/xms;
    return 1   if $response =~ /\A"?true"?\Z/xms;
    return 0   if $response =~ /\A"?false"?\Z/xms;

    my $parser;
    eval { $parser = _parser(); 1; } or do {

        # Only load JSON::Any if we haven't already.  Lets the developers
        # pick their choice of JSON modules (JSON::DWIW, for example)
        ## no critic
        eval q{use JSON::Any};
        croak "Unable to load JSON module for parsing:$@\n" if $@;
        $parser = _parser();
    };
    carp 'JSON::Any is parsing with ' . $parser->handlerType if $self->debug;

    return $parser->decode($response);
}

sub _check_values_of {
    my ( $self, $params ) = @_;

    if ( $self->desktop ) {
        $params->{'call_id'} = time if $self->desktop;
    }

    if ( $params->{'method'} !~ m/^auth/xms ) {
        $params->{'session_key'} ||= $self->session_key;
        if ( !$params->{'callback'} && $self->callback ) {
            $params->{'callback'} = $self->callback;
        }
    }

    $params->{'method'} = "facebook.$params->{'method'}";
    $params->{'v'} ||= $self->api_version;

    $params->{$_} ||= $self->$_ for qw(api_key format);
    return;
}

sub _format_and_check_params {
    my ( $self, $method, %args ) = @_;

    my $params = delete $args{'params'} || {};
    $params->{$_} = $args{$_} for keys %args;
    $params->{'secret'} ||= $self->secret;
    $params->{'method'} ||= $method;

    $self->_check_values_of($params);

    # reformat arrays and add each param to digest
    for ( keys %{$params} ) {
        if ( ref $params->{$_} eq 'ARRAY' ) {
            $params->{$_} = join q{,}, @{ $params->{$_} };
        }

        if ( is_utf8( $params->{$_} ) ) {
            $params->{$_} = encode_utf8( $params->{$_} );
        }
    }

    croak '_format_and_check_params must be called in list context!'
        if !wantarray;

    return ( $params, delete $params->{'data'}, delete $params->{'filename'} );
}

sub _has_error_response {
    my $self     = shift;
    my $response = shift;

    # The different type of error responses
    my $json = q{ \{ "error_code" \D+ (\d+) .* "error_msg" [^"]+ "([^"]+)" };
    my $xml  = q{ <error_code> (\d+) .* <error_msg> ([^<]+)};

    for ( $json, $xml ) {
        if ( $response =~ m/$_/xms ) {
            $self->call_success( 0, "$1: $2" );
            return 1;
        }
    }

    return;
}

sub _reformat_response {
    my ( $self, $params, $response ) = @_;

    # get actual response when web app
    if ( $params->{'callback'} ) {
        $response =~ s/^$params->{'callback'} [^(]* [(](.+) [)];$/$1/xms;
    }
    undef $params;

    # ... and unescape it if it's not going to be parsed
    if ( !$self->desktop && !$self->parse ) {
        $response = $self->unescape_string($response);
    }

    if ( $self->parse && $self->format eq 'XML' ) {
        $self->parse(0);
        carp q{format is XML: setting parse to 0} if $self->debug;
    }
    return $response if !$self->parse;

    $response = $self->_parse($response);
    return if $self->_is_empty_response($response);
    return $response;
}

sub _is_empty_response {
    my ( $self, $response ) = @_;

    return 1 if ref $response eq 'HASH'  && !keys %{$response};
    return 1 if ref $response eq 'ARRAY' && @{$response} == 0;
    return;
}

sub _post_request {
    my ( $self, $params, $sig, $raw_data, $filename ) = @_;

    my $post_params = [ map { $_ => $params->{$_} } sort keys %{$params} ];
    push @{$post_params}, 'sig' => $sig;

    if ($raw_data) {
        push @{$post_params}, data => [
            undef, ( $filename || 'filename'),
            'Content-Type' => 'application/octet-stream',
            'Content'      => $raw_data,
        ];
    }
    return $self->ua->post(
        $self->server_uri,
        'Content_type' => 'form-data',
        'Content'      => $post_params,
    )->content;
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Facebook::API - Facebook API implementation

=head1 VERSION

This document and others distributed with this module describe
WWW::Facebook::API version 0.4.18

=head1 SYNOPSIS

    use WWW::Facebook::API;

    # @ENV{qw/WFA_API_KEY WFA_SECRET WFA_DESKTOP/} are the initial values,
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
    WFA_SECRET
    WFA_SESSION_KEY
    WFA_DESKTOP

Additionally, for each instance that is created, the following environment
variables are used if no values are set:

    WFA_API_KEY_APP_PATH
    WFA_SECRET_APP_PATH
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
        throw_errors    => 1,
    );
    $copy = $client->new;

=back

=head1 NAMESPACE METHODS

All method names from the Facebook API are lower_cased instead of CamelCase.

=over

=item admin

admin namespace of the API (See L<WWW::Facebook::API::Admin>).

=item application

application namespace of the API (See L<WWW::Facebook::API::Application>).

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

=item comments

comments namespace of the API (See L<WWW::Facebook::API::Comments>).

=item connect

connect namespace of the API (See L<WWW::Facebook::API::Connect>).

=item data

data namespace of the API (See L<WWW::Facebook::API::Data>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->data->set_cookie( uid => 23, qw/name foo value bar/);
    $cookies = $client->data->get_cookies(
        uid => 4534,
        name => 'foo',
    );

=item events

events namespace of the API (See L<WWW::Facebook::API::Events>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->events->get(
        uid => 'uid',
        eids => [@eids],
        start_time => 'utc',
        end_time => 'utc',
        rsvp_status => 'attending|unsure|declined|not_replied',
    );
    $response = $client->events->get_members( eid => 233 );

=item fbml

fbml namespace of the API (See L<WWW::Facebook::API::FBML>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->fbml->set_ref_handle( handle => '', fbml => '');
    $response = $client->fbml->refresh_img_src( url => '');
    $response = $client->fbml->refresh_ref_url( url => '');

=item feed

feed namespace of the API (See L<WWW::Facebook::API::Feed>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response
        = $client->feed->publish_story_to_user(
            title   => 'title',
            body    => 'markup',
            ...
    );
    $response
        = $client->feed->publish_action_of_user(
            title   => 'title',
            body    => 'markup',
            ...
    );
    $response
        = $client->feed->publish_templatized_action(
            actor_id       => 'title',
            title_template => 'markup',
            ...
    );

=item fql

fql namespace of the API (See L<WWW::Facebook::API::FQL>):

    $response = $client->fql->query( query => 'FQL query' );

=item friends

friends namespace of the API (See L<WWW::Facebook::API::Friends>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->friends->get;
    $response = $client->friends->get_app_users;
    $response
        = $client->friends->are_friends( uids1 => [1,5,8], uids2 => [2,3,4] );
    $response = $client->friends->get_lists;

=item groups

groups namespace of the API (See L<WWW::Facebook::API::Groups>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->groups->get( uid => 234324, gids => [2423,334] );
    $response = $client->groups->get_members( gid => 32 );

=item intl

intl namespace of the API (See L<WWW::Facebook::API::Intl>).

=item links

links namespace of the API (See L<WWW::Facebook::API::Links>).

=item livemesssage

liveMesssage namespace of the API (See L<WWW::Facebook::API::LiveMesssage>).

=item message

message namespace of the API (See L<WWW::Facebook::API::Message>).

=item notes

notes namespace of the API (See L<WWW::Facebook::API::Notes>).

=item notifications

notifications namespace of the API (See L<WWW::Facebook::API::Notifications>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->notifications->get;
    $response = $client->notifications->send(
        to_ids => [ 1, 3 ],
        notification => 'FBML notification markup',
    );
    $response = $client->notifications->send_email(
        recipients => [1, 2343, 445],
        subject => 'subject',
        text => 'text version of email body',
        fbml  => 'fbml version of email body',
    );

=item pages

pages namespace of the API (See L<WWW::Facebook::API::Pages>). All
method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->pages->get_info(
        page_ids => [@pages],
        fields   => [@fields],
        uid      => 'user',
        type     => 'page type',
    );
    $page_added_app = $client->pages->is_app_added( page_id => 'page' );
    $is_admin = $client->pages->is_admin( page_id => 'page' );
    $is_fan = $client->pages->is_fan( page_id => 'page', uid => 'uid' )

=item permissions

permissions namespace of the API (See L<WWW::Facebook::API::Permissions>).

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
    $response = $client->profile->set_fbml( uid => 5,
        profile => 'markup',
        profile_action => 'markup',
        mobile_profile => 'markup',
    );

=item sms

sms namespace of the API (See L<WWW::Facebook::API::SMS>).

=item status

status namespace of the API (See L<WWW::Facebook::API::Status>).

=item stream

stream namespace of the API (See L<WWW::Facebook::API::Stream>).

=item users

users namespace of the API (See L<WWW::Facebook::API::Users>).
All method names from the Facebook API are lower_cased instead of CamelCase:

    $response = $client->users->get_info(
        uids => 2343,
        fields => [ qw/about_me quotes/ ]
    );
    $uid = $client->users->get_logged_in_user;
    $response = $client->users->has_app_permission(
        ext_perm => 'status_update|photo_upload'
    );
    $app_added = $client->users->is_app_user;
    $response = $client->users->set_status(
        status => 'status message',
        clear => 1|0,
    );

=item video

video namespace of the API (See L<WWW::Facebook::API::Video>).

=back

=head1 ATTRIBUTE METHODS

These are methods to get/set the object's attributes.

=over

=item api_key( $new_api_key )

The developer's API key. If C<$ENV{'WFA_API_KEY'}> is set, all instances will
be initialized with its value. See the Facebook API documentation for more
information.

=item api_version( $new_version )

Which version to use (default is "1.0", which is the latest one supported
currently). Corresponds to the argument C<v> that is passed in to methods as a
parameter.

=item app_id()

The application id where your Facebook app is described, e.g.:

    http://www.facebook.com/apps/application.php?id=THIS_NUMBER

Remember, C<WWW::Facebook::API> is not that clairvoyant: You must first
set this number (when calling C<new()>) in order to use it.

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

=item config($filename)

Used when instantiating a new object to set the environment variables. The
file has a simple, BASH-style format:

    WFA_API_KEY_MYAPP=383378efa485934bc
    WFA_SECRET_MYAPP=234234ac902f340923
    WFA_SESSION_KEY_MYAPP=34589349abce989d
    WFA_DESKTOP_MYAPP=1

If the file is found, and the environment variables are already set, then the
variables will not be changed.

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
C<< auth->create_token >> and C<< auth->get_session >>. For a web application,
secret is used for all calls to the API. If C<$ENV{'WFA_SECRET'}> is set,
all instances will be initialized with its value. See the Facebook API
documentation under Authentication for more information.

=item server_uri( $new_server_uri )

The server uri to access the Facebook REST server. Default is
C<'http://api.facebook.com/restserver.php'>. Used to make calls to the
Facebook server, and useful for testing. See the Facebook API documentation. 

=item session_expires( $new_expires )

The session expire timestamp for the client's user. Automatically set when
C<< $client->auth->get_session >> is called. See the Facebook API
documentation.

=item session_key( $new_key )

The session key for the client's user. Automatically set when
C<< $client->auth->get_session >> is called. See the Facebook API documentation.

=item session_uid( $new_uid )

The session's uid for the client's user. Automatically set when
C<< $client->auth->get_session >> is called. See the Facebook API documentation.

=item skipcookie(0|1)

See the Facebook API documentation's Authentication Guide. Just a convenient
place holder for the value.

=item throw_errors(0|1)

A boolean set to either true of false, signifying whether or not to C<confess>
when an error is returned from the REST server.

=item ua

The L<LWP::UserAgent> agent used to communicate with the REST server.
The agent_alias is initially set to "Perl-WWW-Facebook-API/0.4.18".

=back

=head1 PUBLIC METHODS

=over

=item call( $method, %args )

The method which other submodules within L<WWW::Facebook::API> use
to call the Facebook REST interface. It takes in a string signifying the method
to be called (e.g., 'auth.getSession'), and key/value pairs for the parameters
to use:
    $client->call( 'auth.getSession', auth_token => 'b3324235e' );

For all calls, if C< parse > is set to true and an empty hash/array reference
is returned from facebook, nothing will be returned instead of the empty
hash/array reference.

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
C<'app'>, C<'add'>, C<'facebook'>, C<'infinite_session'>, or C<'custom'>.
C<@args> contains the query parameters for the the cases when C<$type> is not
C<'app'> or C<'facebook'>. In the case of C<'custom'>, the first item in
C<@args> is the url path relative to the facebook website. All of the
C<get_*_url> methods correspond to the ones in the official PHP client.

=item log_string($params_hashref, $response)

Pass in the params and the response from a call, and it will make a formatted
string out of it showing the parameters used, and the response received.

=item redirect( $url, $query_object )

Called by C<require()> to redirect the user either within the canvas or
without. If no <$query_object> is defined, then whatever is in C<<
$client->query >> will be used. (See L<WWW::Facebook::API::Canvas>) If no
redirect is required, nothing is returned. That is the only case when there is
no return value. If a redirect B<is> required, there are two cases that are
covered:

=over 4

=item user not logged in

If there isn't a user logged in to Facebook's system, then a redirect to the Facebook
login page is printed to STDOUT with a next parameter to the appropriate page.
The redirect is called with the the CGI module that comes standard with perl.
The return value in this case is 1.

=item user logged in

If the user is logged in to Facebook, and a redirect is required, the
necessary FBML is returned: C<< <fb:redirect url="WHATEVER"> >>.
So the return value is the FBML, which you can then print to STDOUT.

=back


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
C< $client->query >> is used.

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

=item _format_and_check_params( $method, %args )

Format method parameters (given in C<%args>) according to Facebook API
specification. Returns a list of items: A hash reference of the newly
formatted params (based on C<%params>) and the raw data (and filename, if
passed in) if the call is a photo or video upload:

    ($params, $raw_data, $filename) = $self->_format_and_check_params( $method, %args );

=item _has_error_response( $response )

Determines if the response is an error, and logs it appropriately. Returns
true if response is an error, false otherwise.

=item is_empty_response( $response )

Determines if the response is an empty hash or array reference. Returns true
if the response is empty, false otherwise.

=item _post_request( $params_hashref, $sig, $raw_data, $filename )

Used by C<call> to post the request to the REST server and return the
response. C<$raw_data> and C<$filename> are used when uploading a photo or
video to Facebook.

=item _parse($string)

Parses the response from a call to the Facebook server to make it a Perl data
structure, and returns the result.

=item _parser()

Returns a new instance of JSON::Any.

=item _reformat_response( $params, $response )

Reformats the response according to whether the app is a desktop app, if the
response should be parsed (i.e., changed to a Perlish structure), if the
response is empty, etc. Returns the reformatted response.

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

=item C<<_format_and_check_params must be called in list context!>>

You're using a private method call and you're not calling it in list context.
It returns a list of items, all of which should be interesting to you.

=item C<< Cannot open %s >>

Cannot open the configuration file. Make sure the filename is correct and that
the program has the appropriate permissions.

=item C<< Cannot close %s >>

Cannot close the configuration file. Make sure the filename is correct and
that the program has the appropriate permissions.

=back

=head1 FAQ

=over

=item Id numbers returned by Facebook are being rounded. What is the problem?

The JSON module that is installed on your system is converting the numbers to
Perl and is losing precision in the process. Make sure you have the latest
L<JSON::XS> module installed or L<JSON::DWIW> (any recent version of either
should work).

=item How do I run the examples in the examples directory?

There are two types of examples in the examples directory, desktop-based and
web-based. With desktop-based, the api key and secret key are prompted for on
STDIN, and then the user's browser is opened and directed to the Facebook
log in page. Currently, the desktop-based examples pause for 20 seconds to
allow for the user to enter in their credentials.

With web-based, you have to pass in the api key, secret key, and app path to
the constructor, and then place the script at the callback url you specified
in the Facebook setup for your application. For instance, when using the
web-based example, you might have the following callback url (note the
trailing slash):
    
    http://www.example.com/facebook-canvas-json/

You have to make sure the required Perl modules are in the C<@INC> path for
the web server process, otherwise there will be a 500 Internal Server error.
The easiest way to do that is to put the following at the top of the example
script (as long as "path-to-perl5-libs" is readable by the web server
process):

    use lib "path-to-perl5-libs";

=item I'm getting the "Multiple values for %s" error from WFA::Canvas. Help?

This usually means that your forms are using GET rather than POST to Facebook
URLs. Change your forms to use POST and the problem should be resolved. (See
RT#31620 and RT#31944 for more information).

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

http://github.com/unobe/perl-wfa/tree/master

=head1 TESTING

There are some live tests included, but they are only run if the following
environment variables are set:
    WFA_API_KEY_TEST
    WFA_SECRET_TEST
    WFA_SESSION_KEY_TEST

Additionally, if your app is a desktop one, you must set C<WFA_DESKTOP_TEST>.
Also, the session key must be valid for the API key being used.

To enable POD coverage and POD formattings tests, set C<PERL_TEST_POD> to
true. To enable L<Perl::Critic> tests, set C<_PERL_TEST_CRITIC> to true.

=head1 AUTHOR

David Romano  C<< <unobe@cpan.org> >>

=head1 CONTRIBUTORS

Anthony Bouvier C<< none >>

Clayton Scott C<< http://www.matrix.ca >>

David Leadbeater C<< http://dgl.cx >>

Derek Del Conte C<< derek@delconte.org >>

Gisle Aas C<< none >>

J. Shirley C<< <jshirley@gmail.com> >>

Jim Spath C<< <jspath@gmail.com> >>

Kevin Riggle C<< none >>

Larry Mak C<< none >>

Louis-Philippe C<< none >>

Matt Sickler C<< <imMute@mail.msk3.ath.cx> >>

Nick Gerakines C<< <nick@socklabs.com> >>

Olaf Alders C<< <olaf@wundersolutions.com> >>

Patrick Michael Kane C<< <pmk@wawd.com> >>

Ryan D Johnson C<< ryan@innerfence.com >>

Sean O'Rourke C<< <seano@cpan.org> >>

Shawn Van Ittersum C<< none >>

Simon Cavalletto C<< <simonm@cavalletto.org> >>

Skyler Clark C<< none >>

Thomas Sibley C<< <tsibley@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007-2010, David Romano C<< <unobe@cpan.org> >>. All rights reserved.

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
