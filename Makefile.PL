use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
    NAME                => 'WWW::Facebook::API',
    AUTHOR              => 'David Romano <unobe@cpan.org>',
    VERSION_FROM        => 'lib/WWW/Facebook/API/REST/Client.pm',
    ABSTRACT_FROM       => 'lib/WWW/Facebook/API/REST/Client.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0,
        'version'           => 0,
        'Moose'             => 0,
        'WWW::Mechanize'    => 0,
        'Digest::MD5'       => 0,
        'Time::HiRes'       => 0,
        'URI::Escape'       => 0,
        'XML::Simple'       => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Facebook-API-*' },
);
