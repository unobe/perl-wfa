#!/usr/bin/perl
# Copyright (c) 2008 David Romano <unobe@cpan.org>
use strict;
use warnings;
use CGI;
use WWW::Facebook::API;

my $APP_NAME = 'ReplaceMe';
my $API_KEY = 'ReplaceMe';
my $SECRET = 'ReplaceMe';
my $DESKTOP = 0;

my $facebook = WWW::Facebook::API->new(
    app_path => $APP_NAME,
    parse    => 1,
    api_key => $API_KEY,
    secret => $SECRET,
    desktop => $DESKTOP,
);

my %action_map = (
    tos         => sub {
       print q{
            <fb:title>Terms of Service</fb:title>
            <fb:header>Terms of Service</fb:header>
            <div style="padding: 10px">
                REPLACE WITH OWN TEXT
            </div>
        }
    },
    about => sub { print "The Great New $APP_NAME"; },
    '' => sub {
        my ( $facebook, $uid, @args ) = @_;
        print qq{<p>Hello <fb:name uid="$uid" useyou="false" />!</p>};
    },


);

start($facebook);

sub start {
    my $facebook = shift;

    my $fb_params = $facebook->canvas->validate_sig( CGI->new );

    my $log_in = $facebook->require_login( undef,
        next => "$ENV{'PATH_INFO'}?$ENV{'QUERY_STRING'}" );

    print $facebook->query->header( -expires => 'now' );

    if ($log_in) {
        print $log_in;
        return;
    }
    else {    # store credentials
        $facebook->session(
            uid     => $fb_params->{'user'},
            key     => $fb_params->{'session_key'},
            expires => $fb_params->{'expires'},
        );
        if ( !$fb_params->{'added'} ) {
            $action_map{'tos'}->($facebook);
            return;
        }
    }

    find_action_for($facebook);

    return;
}

sub find_action_for {
    my $facebook = shift;
    my ( $action, $uid );

    ($action) = ( $facebook->query->path_info =~ m[^/(\w+)] );
    if ( exists $ENV{'QUERY_STRING'} ) {
        ($uid) = $ENV{'QUERY_STRING'} =~ /\bid=([^&]+)/;
    }

    if ( my $s = $action_map{$action} ) {
        my @args = split m[(?<!\\)/],
            ( $facebook->query->path_info =~ m[^/(?:\w+)/(.*)] )[0];
        @args = () unless @args;
        $uid ||= $facebook->session_uid;

        $s->( $facebook, $uid, @args );
    }
    else {
        print '<fb:error>'
            ."<fb:message>I don't know how to do $action</fb:message>"
            .'</fb:error>';
    }
    return;
}


