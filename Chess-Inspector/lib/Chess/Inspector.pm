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
    my $fen = $self->form('fen') || Chess::Rep::FEN_STANDARD;
    my $pgn = $self->form('pgn') || undef;

    my $w_moves_made = 0;
    my $w_can_move = 0;
    my $w_threaten = 0;
    my $w_protect = 0;
    my $b_moves_made = 0;
    my $b_can_move = 0;
    my $b_threaten = 0;
    my $b_protect = 0;

    my $g = Chess::Rep::Coverage->new;
    $g->set_from_fen($fen);
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

            $w_can_move += $wmove;
            $w_threaten += @{ $c->{$key}{threatens} }
                if exists $c->{$key}{threatens} && $c->{$key}{color} == 128;
            $w_protect += @{ $c->{$key}{protects} }
                if exists $c->{$key}{protects} && $c->{$key}{color} == 128;
            $b_can_move += $bmove;
            $b_threaten += @{ $c->{$key}{threatens} }
                if exists $c->{$key}{threatens} && $c->{$key}{color} == 0;
            $b_protect += @{ $c->{$key}{protects} }
                if exists $c->{$key}{protects} && $c->{$key}{color} == 0;

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

    $self->fast_append(
        tag => 'game',
        data => {
            to_move => $g->{to_move},
            fen     => $fen,
            pgn     => $pgn ? $pgn : 0,
        }
    );

    $self->fast_append(
        tag => 'white',
        data => {
            moves_made => $w_moves_made,
            can_move   => $w_can_move,
            threaten   => $w_threaten,
            protect    => $w_protect,
        }
    );
    $self->fast_append(
        tag => 'black',
        data => {
            moves_made => $b_moves_made,
            can_move   => $b_can_move,
            threaten   => $b_threaten,
            protect    => $b_protect,
        }
    );

    return;
}

1;
