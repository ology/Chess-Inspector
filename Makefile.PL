use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on them.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME         => 'Chess::Inspector',
    AUTHOR       => 'Gene Boggs <gene@cpan.org>',
    VERSION_FROM => 'lib/Chess/Inspector.pm',
    ABSTRACT     => 'Visualize a chess game potential energy transformation',
    ($eumm_version >= 6.3001 ? ('LICENSE'=> 'perl') : ()),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'           => 0,
        'YAML'                 => 0,
        'Template'             => 0,
        'Dancer'               => 1.3140,
        'Chess::Pgn'           => 0,
        'Chess::Rep'           => 0,
        'Chess::Rep::Coverage' => 0,
        'File::Basename'       => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Chess-Inspector-*' },
);
