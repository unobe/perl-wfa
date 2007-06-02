use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
    NAME                => 'WWW::Facebook::API',
    AUTHOR              => 'David Romano <unobe@cpan.org>',
    VERSION_FROM        => 'lib/WWW/Facebook/API.pm',
    ABSTRACT_FROM       => 'lib/WWW/Facebook/API.pm',
    LICENSE             => 'perl',
    PL_FILES            => {},
    PREREQ_PM => {
        'version'           => 0,
        'WWW::Mechanize'    => 0,
        'Digest::MD5'       => 0,
        'XML::Simple'       => 0,
        'Time::HiRes'       => 0,
        'Crypt::SSLeay'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Facebook-API-*' },
);
