#!perl
use Test::More;

BEGIN {
    use_ok 'Lingua::Word::Parser';
}

my $obj = eval { Lingua::Word::Parser->new };
isa_ok $obj, 'Lingua::Word::Parser';
ok !$@, 'created with no arguments';
my $x = $obj->{foo};
is $x, 'bar', "foo: $x";

$obj = Lingua::Word::Parser->new(
    foo => 'Zap!',
);
$x = $obj->{foo};
like $x, qr/zap/i, "foo: $x";

done_testing();
