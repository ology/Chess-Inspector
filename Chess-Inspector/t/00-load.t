#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Chess::Inspector' ) || print "Bail out!\n";
}

diag( "Testing Chess::Inspector $Chess::Inspector::VERSION, Perl $], $^X" );
