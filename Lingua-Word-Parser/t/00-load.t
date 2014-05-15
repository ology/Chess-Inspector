#!perl
use Test::More;

BEGIN {
    use_ok 'Lingua::Word::Parser';
}

diag("Testing Lingua::Word::Parser $Lingua::Word::Parser::VERSION, Perl $], $^X");

done_testing();
