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

    my $player = {
        white => {
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
        },
        black => {
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
        }
    };

    if ( $self->form('toggle') && $fen =~ /^(.+?) (w|b) (.+)$/ )
    {
        $fen = $1;
        $fen .= $2 eq 'w' ? ' b ' : ' w ';
        $fen .= $3;
    }

    my $g = Chess::Rep::Coverage->new;
    $g->set_from_fen($fen);
    my $c = $g->coverage();
#use Data::Dumper; $self->logger->debug(Dumper $c);

    for my $row (1 .. 8)
    {
        # Add the parent row to the response.
        my $parent = $self->fast_append( tag => 'board', data => { row => $row } );
        for my $col ('A' .. 'H')
        {
            # Convenience.
            my $key = $col . $row;

            # Compute the cell occupancy, protection, threat & move state.
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

            # Compute the player stats.
            for my $color ( [ white => 128 ], [ black => 0 ] )
            {
                $player->{$color->[0]}{can_move} += $color eq 'white' ? $wmove : $bmove;
                $player->{$color->[0]}{threaten} += @{ $c->{$key}{threatens} }
                    if exists $c->{$key}{threatens} && $c->{$key}{color} == $color->[1];
                $player->{$color->[0]}{protect}  += @{ $c->{$key}{protects} }
                    if exists $c->{$key}{protects} && $c->{$key}{color} == $color->[1];
            }

            # Add the cell state to the response.
            $self->fast_append(
                parent => $parent,
                tag    => 'cell',
                data   => {
                    col            => $col,
                    piece          => $piece,
                    # Add one to protected to thicken the CSS border.
                    protected      => $protect ? $protect + 1 : 0,
                    threatened     => $threat,
                    white_can_move => $wmove,
                    black_can_move => $bmove,
                },
            );
        }
    }

    # Add the game state to the response.
    $self->fast_append(
        tag => 'game',
        data => {
            to_move => $g->{to_move},
            fen     => $fen,
            pgn     => $pgn ? $pgn : 0,
        }
    );

    # Add player status to the response.
    for my $color (qw( white black ))
    {
        $self->fast_append(
            tag => $color,
            data => {
                moves_made => $player->{$color}{moves_made},
                can_move   => $player->{$color}{can_move},
                threaten   => $player->{$color}{threaten},
                protect    => $player->{$color}{protect},
            }
        );
    }

    return;
}

1;
