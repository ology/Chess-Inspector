use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Chess::Inspector',
    AUTHOR           => q{C5 Builder <devteam@online-rewards.com>},
    VERSION_FROM     => 'lib/Chess/Inspector.pm',
    ABSTRACT_FROM    => 'lib/Chess/Inspector.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Chess::Pgn' => 0,
        'Chess::Rep' => 0,
        'Chess::Rep::Coverage' => 0.1003,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Chess::Inspector-*' },
);
