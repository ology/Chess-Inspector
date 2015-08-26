package Chess::Inspector;

use Dancer ':syntax';

use Chess::Pgn;
use Chess::Rep;
use Chess::Rep::Coverage;
use File::Basename;

our $VERSION = '0.1';

=head1 NAME

Chess::Inspector

=head1 DESCRIPTION

Visualize a chess game potential energy transformation

=head1 METHOD

=head2 coverage

Compute the chess board coverage and append the game meta-data, each cell and
player state to the response.

=cut

get '/' => sub {
    my $fen  = params->{fen}      || Chess::Rep::FEN_STANDARD;
    my $pgn  = params->{pgn}      || '';
    my $move = params->{move}     || 0;
    my $posn = params->{position} || 0;
    my $prev = params->{previous} || $posn;

    my $results = coverage( $fen, $pgn, $move, $posn, $prev );

    template 'index', {
        response => $results,
        fen      => $fen,
        pgn      => $pgn,
        selected => $pgn,
    };
};

sub coverage {
    my ( $fen, $pgn, $move, $posn, $prev ) = @_;

    my $results = {};

    # Total moves in game.
    my $moves = 0;

    my ( $white, $black ) = ( '', '' );

    if ($move) {
        # Set position and number of moves made.
        ( $fen, $moves, $white, $black ) = _fen_from_pgn( pgn => $pgn, move => $move );
    }

    my $g = Chess::Rep::Coverage->new;
    $g->set_from_fen($fen);
    my $c = $g->coverage();

    my $player = {
        white => {
            name       => $white ? (split / /, $white)[-1] : '',
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
        },
        black => {
            name       => $black ? (split / /, $black)[-1] : '',
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
        }
    };

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

    for my $row ( 1 .. 8 ) {
        for my $col ( 'A' .. 'H' ) {
            # Convenience.
            my $key = $col . $row;

            # Compute the cell occupancy, protection, threat & move state.
            # TODO Use the rep bitmask instead of this hack.
            my $piece = exists $c->{$key}{occupant}
                ? ($c->{$key}{color} ? 'w' : 'b') . lc $c->{$key}{occupant} : '';
            # Convert to a single chess piece character.
            $piece = $chessfont{$piece};

            # Get the cell coverage states
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
            push @{ $results->{rows}{$row} }, {
                row            => $row,
                col            => $col,
                position       => $posn,
                previous       => $prev,
                piece          => $piece,
                protected      => $protect,
                threatened     => $threat,
                white_can_move => $wmove,
                black_can_move => $bmove,
            };
        }
    }

    # Add the game state to the response.
    $results->{game} = {
        to_move => $g->{to_move},
        fen     => $fen,
        pgn     => $pgn,
        reverse => $move == -1 ? $moves - 1 : $move - 1,
        forward => $move > $moves + 1 ? 0 : $move + 1,
     };

    # TODO Grab PGN files from the PGN directory instead!
    for my $game (qw( Game-of-the-Century Immortal )) {
        push @{ $results->{games} },
            {
                name     => $game,
                selected => $game eq $pgn ? $game : 0,
            };
    }

    # Grab the PGN files
    my @pgn;
    my $pgndir = 'public/pgn/';
    opendir( my $dh, $pgndir ) || die "Can't read $pgndir: $!";
    while( readdir $dh ) {
        next if /^\./;
        my $basename = basename( $_, '.pgn' );
        push @pgn, $basename;
    }
    closedir $dh;

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
    for my $color (qw( white black )) {
        $results->{$color} = {
            name       => $player->{$color}{name},
            moves_made => $player->{$color}{moves_made},
            can_move   => $player->{$color}{can_move},
            threaten   => $player->{$color}{threaten},
            protect    => $player->{$color}{protect},
        };
    }

    return $results;
}

sub _fen_from_pgn {
    my %args = @_;

    # Assume that the PGN is given as a filename without the extension.
    $args{pgn} = 'public/pgn/' . $args{pgn} . '.pgn';

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
    $args{move} = $#moves if $args{move} == -1;

    my $g = Chess::Rep->new;

    # Declare the FEN.
    my $fen = '';

    my $i = 0;
    for my $move (@moves) {
        # Are we on the selected move?
        if ( $args{move} == $i ) {
            # Set the FEN.
            $fen = $g->get_fen;

            # Show our status.
#            $self->logger->debug("$i. $move: $fen");

            # All done!
            last;
        }

        # Make the move.
        $g->go_move($move);

        # Increment our move counter.
        $i++;
    }

    return $fen, $#moves, $p->white, $p->black;
}

1;

true;
