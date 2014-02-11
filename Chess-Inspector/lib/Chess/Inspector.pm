package Chess::Inspector;
use strict;
use warnings FATAL => 'all';
use parent qw(Chameleon5::Site::Base);

use Chess::Pgn;
use lib '/Users/gene/sandbox/github/ology/Chess-Rep-Coverage/lib';
use Chess::Rep::Coverage;
use Chess::Rep;

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

    my $fen  = $self->form('fen') || Chess::Rep::FEN_STANDARD;
    my $pgn  = $self->form('pgn') || 'Immortal';
    my $move = $self->form('move') || 0;

    # Total moves in game.
    my $moves = 0;

    if ( $self->form('move') )
    {
        ( $fen, $moves ) = $self->_fen_from_pgn( pgn => $pgn, move => $self->form('move') );
    }

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

    # Toggle black or white.
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

    my %chessfont = (
        wk => '&#9812;',
        wq => '&#9813;',
        wr => '&#9814;',
        wb => '&#9815;',
        wn => '&#9816;',
        wp => '&#9817;',
        bk => '&#9818;',
        bq => '&#9819;',
        br => '&#9820;',
        bb => '&#9821;',
        bn => '&#9822;',
        bp => '&#9823;',
    );

    for my $row (1 .. 8)
    {
        # Add the parent row to the response.
        my $parent = $self->fast_append( tag => 'board', data => { row => $row } );
        for my $col ('A' .. 'H')
        {
            # Convenience.
            my $key = $col . $row;

            # Compute the cell occupancy, protection, threat & move state.
            # TODO Use the rep bitmask instead of this hack.
            my $piece = exists $c->{$key}{occupant}
                ? ($c->{$key}{color} ? 'w' : 'b') . lc $c->{$key}{occupant} : '';
            # Convert to a single chess piece character.
            $piece = $chessfont{$piece};
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
                $player->{$color->[0]}{can_move} += $color->[0] eq 'white' ? $wmove : $bmove;
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
            pgn     => $pgn,
            reverse => $move == -1 ? $moves - 1 : $move - 1,
            forward => $move + 1,
        }
    );

    # Reset the moves to the penultimate, if given the last as arg.
    $move = $moves if $move == -1;

    # Compute the player moves made.
    if ( $move % 2 )
    {
        $player->{black}{moves_made} = ( $move - 1 ) / 2;
        $player->{white}{moves_made} = $player->{black}{moves_made} + 1;
    }
    else
    {
        $player->{white}{moves_made} = $move / 2;
        $player->{black}{moves_made} = $player->{white}{moves_made};
    }


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

sub _fen_from_pgn
{
    my ($self, %args) = @_;

    # Assume that the PGN is given as a filename without the extension.
    $args{pgn} = $self->env->{'chameleon.domain_root'} . 'site_root/pgn/' . $args{pgn} . '.pgn';

    # Consume the game moves (only).
    my $p = Chess::Pgn->new($args{pgn});
    $p->ReadGame;
    my $game = $p->game;
    $game =~ s/\n/ /g; # De-wrap.
    my @pairs = split /\s*\d+\.\s+/, $game; 
    my @moves = ();
    for my $pair (@pairs) {
        next if $pair =~ /^\s*$/;
        last if $pair =~ /{/;
        push @moves, split /\s+/, $pair;
    }

    # Reset the move to the penultimate, if given the last as arg.
    $args{move} = $#moves - 1 if $args{move} == -1;

    my $g = Chess::Rep->new;

    # Declare the FEN.
    my $fen = '';

    my $i = 0;
    for my $move (@moves)
    {
        # Are we on the selected move?
        if ( $args{move} == $i )
        {
            # Set the FEN.
            $fen = $g->get_fen;

            # Show our status.
            $self->logger->debug("$i. $move: $fen");

            # All done!
            last;
        }

        # Make the move.
        $g->go_move($move);

        # Increment our move counter.
        $i++;
    }

    return $fen, $#moves - 1;
}

1;
