package Chess::Inspector;
use strict;
use warnings FATAL => 'all';
use parent qw(Chameleon5::Site::Base);

use lib '/Users/gene/sandbox/github/ology/Chess-Rep-Coverage/lib';
use Chess::Rep::Coverage;

our $VERSION = '0.01';

=head1 NAME

Chess::Inspector - Inspect a chess game

=head1 SYNOPSIS

    use Chess::Inspector;
    my $foo = Chess::Inspector->new();

=head1 METHODS

=cut

sub coverage
{
    my ($self, %args) = @_;
    my $g = Chess::Rep::Coverage->new;
    $g->set_from_fen('rnbqkbnr/pppp11pp/4p3/5p2/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2');
    my $c = $g->coverage();
#use Data::Dumper; $self->logger->debug(Dumper $c);
    for my $row (1 .. 8)
    {
        my $parent = $self->fast_append( tag => 'board', data => { row => $row } );
        for my $col ('A' .. 'H')
        {
            my $key = $col . $row;
            my $piece = exists $c->{$key}{occupant}
                ? ($c->{$key}{color} ? 'w' : 'b') . lc $c->{$key}{occupant} : '';
            my $protect = exists $c->{$key}{is_protected_by}
                ? scalar @{ $c->{$key}{is_protected_by} }     : 0;
            my $threat = exists $c->{$key}{is_threatened_by}
                ? scalar @{ $c->{$key}{is_threatened_by} }    : 0;
            my $wmove = exists $c->{$key}{white_can_move_here}
                ? scalar @{ $c->{$key}{white_can_move_here} } : 0;
            my $bmove = exists $c->{$key}{black_can_move_here}
                ? scalar @{ $c->{$key}{black_can_move_here} } : 0;

            $self->fast_append(
                parent => $parent,
                tag    => 'cell',
                data   => {
                    col            => $col,
                    piece          => $piece,
                    protected      => $protect,
                    threatened     => $threat,
                    white_can_move => $wmove,
                    black_can_move => $bmove,
                },
            );
        }
    }
    return;
}

1;
