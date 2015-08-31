package Chess::Inspector;

use Dancer ':syntax';
use Chess::Pgn;
use Chess::PGN::Parse;
use Chess::Rep;
use Chess::Rep::Coverage;
use File::Basename;
use List::Tuples qw( :all );
use POSIX;

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
    my $last = params->{last}     || '';

    $fen = Chess::Rep::FEN_STANDARD unless $pgn;

    my $results = coverage( $fen, $pgn, $move, $posn, $prev, $last );

    template 'index', {
        response => $results,
        fen      => $fen,
        pgn      => $pgn,
    };
};

get '/history' => sub {
    my $index = parse_pgn('public/kasparov.pgn');

    my $forward = params->{forward} || 1;

    template 'history', {
        index   => $index->{$forward},
        forward => $forward,
        total   => scalar( keys %$index ),
    };
};

sub coverage {
    my ( $fen, $pgn, $move, $posn, $prev, $last ) = @_;

    my $results = {};

    # Total moves in game.
    my $moves = 0;

    my ( $white, $black ) = ( '', '' );

    my $last_move;

    if ( $pgn ) {
        # Set position and number of moves made.
        ( $fen, $moves, $white, $black, $last_move ) = _fen_from_pgn( pgn => $pgn, move => $move );
    }

    my $g = Chess::Rep::Coverage->new;
    $g->set_from_fen($fen);
    my $c = $g->coverage();

    my $player = {
        white => {
            name       => $white ? $white : '',
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
            last_move  => '',
        },
        black => {
            name       => $black ? $black : '',
            moves_made => 0,
            can_move   => 0,
            threaten   => 0,
            protect    => 0,
            last_move  => '',
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
        total   => ceil( $moves / 2 ),
     };

    # Grab the PGN files
    my @pgn;
    my $pgndir = 'public/pgn/';
    opendir( my $dh, $pgndir ) || die "Can't read $pgndir: $!";
    while( readdir $dh ) {
        next if /^\./;
        my $basename = basename( $_, '.pgn' );
        push @pgn, $basename;

        push @{ $results->{games} },
            {
                name     => $basename,
                selected => $basename eq $pgn ? $basename : 0,
            };
    }
    closedir $dh;

    # Reset the moves to the penultimate, if given the last as arg.
    $move = $moves if $move == -1;

    # Compute the player moves made.
    if ( $move % 2 )
    {
        $player->{black}{moves_made} = ( $move - 1 ) / 2;
        $player->{white}{moves_made} = $player->{black}{moves_made} + 1;

        $player->{white}{last_move} = $move ? $last_move : '';
        $player->{black}{last_move} = $move ? $last : '';
    }
    else
    {
        $player->{white}{moves_made} = $move / 2;
        $player->{black}{moves_made} = $player->{white}{moves_made};

        $player->{black}{last_move} = $move ? $last_move : '';
        $player->{white}{last_move} = $move ? $last : '';
    }

    # Add player status to the response.
    for my $color (qw( white black )) {
        $results->{$color} = $player->{$color};
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

    my $result;
    my $last_move;

    my $i = 0;
    for my $move (@moves) {
        # Are we on the selected move?
        if ( $args{move} == $i ) {
            # Set the FEN.
            $fen = $g->get_fen;

            # Set the last move.
            $last_move = $result->{san};

            last;
        }

        # Make the move.
        $result = $g->go_move($move);

        # Increment our move counter.
        $i++;
    }

    return $fen, $#moves, $p->white, $p->black, $last_move;
}

sub parse_pgn {
    my $file = shift;

    my $pgn = Chess::PGN::Parse->new($file);

    my $games = $pgn->quick_read_all;

    my %index;

    for my $game ( @$games ) {
        my $color = $game->{White} =~ /Kasparov/ ? 0 : 1;
        next if $color;
        my $i = 0;
        for my $tuple ( tuples[2] => @{ $game->{GameMoves} } ) {
            $i++;
            my $move = $tuple->[$color];
            $index{ $i }->{$move}++ if $move;
        }
    }

    my %vals;

    for my $i ( sort { $a <=> $b } keys %index ) {
        for my $row ( 1 .. 8 ) {
            for my $col ( 'a' .. 'h' ) {
                my $move = $col . $row;
                push @{ $vals{$i}->{$row} }, {
                    row => $row,
                    col => $col,
                    exists $index{$i}->{$move} ? ( val => $index{$i}->{$move} ) : (),
                };
            }
        }
    }

    return \%vals;
}

1;

true;
