package Lingua::Word::Parser;

# ABSTRACT: Frobnicate Universes

use strict;
use warnings;
use Carp qw(croak);

use Bit::Vector;
use Data::Dumper::Concise;
use Data::PowerSet;
use IO::File;

our $VERSION = '0.01';

=head1 NAME

Lingua::Word::Parser - Parse word parts

=head1 SYNOPSIS

  use Lingua::Word::Parser;
  $x = Lingua::Word::Parser->new(%arguments);

=head1 DESCRIPTION

A C<Lingua::Word::Parser> breaks a word into known affixes.

=cut

=head1 METHODS

=head2 new()

  $x = Lingua::Word::Parser->new(%arguments);

Create a new C<Lingua::Word::Parser> object.

Arguments and defaults:

  word: undef
  lex:  undef

=cut

sub new {
    my $class = shift;
    my %args = @_;
    # Explicit constructor:
    my $self = {
        word => $args{word} || undef,
        lex  => $args{lex}  || undef,
        %args # Final override.
    };
    bless $self, $class;
    $self->_init(%args);
    return $self;
}
sub _init {
    my ($self, %args) = @_;
#    $self->{word} ||= 'bar';
#    $self->{lex} ||= 123;
}

=head2 fetch_lex()
=cut

sub fetch_lex { # Populate word-part regular expression lexicon.
    my $self = shift;

    if ( $self->{file} ) {
        my $fh = IO::File->new();
        if ( $fh->open( '<' . $self->{file} ) ) {
            chomp;
            my ($re, $defn) = split /\s+/, $_, 2;
            $self->{lex}{$re} = { defn => $defn, re => qr/$re/ };

            $fh->close;
        }
    }
    # TODO if ( $self->{store} ) {
    # TODO if ( $self->{db} ) {

    return $self->{lex};
}

=head2 main()

=cut

sub main {
    # Find the known word-part positions.
    my ($known, $mask_id) = get_knowns($word, $lex);
    #warn Dumper $known;
    my $combos = power($mask_id);
    #warn Dumper $combos;
    my $score  = score($combos);
    #warn Dumper $score;
    warn Dumper $score->{ [ sort keys $score ]->[-1] };
}

=head2 score()

=cut

sub score {
    # Get the list of combinations.
    my $combos = shift;

    # Declare the score hash.
    my $score = {};

    # Visit each
    my $i = 0;
    for my $c (@$combos) {
        $i++;
        my $together = or_together(@$c);

        # Run-length encode an "un-digitized" string.
        my $scored = rle($together);

        my %count = (
            knowns   => 0,
            unknowns => 0,
            knownc   => 0,
            unknownc => 0,
        );
        my $val = '';
        for my $x ( reverse sort @$c ) {
            # Breakdown knowns vs unknowns and knowncharacters vs unknowncharacters.
            my $y = rle($x);
            my ( $knowns, $unknowns, $knownc, $unknownc ) = grouping($y);
            $val .= "$x ($y)[$knowns/$unknowns | $knownc/$unknownc] ";
            # Accumulate the counters!
            $count{knowns}   += $knowns;
            $count{unknowns} += $unknowns;
            $count{knownc}   += $knownc;
            $count{unknownc} += $unknownc;
        }
        $val .= "$count{knowns}/$count{unknowns} + $count{knownc}/$count{unknownc} => "
          . join( ', ', @{ reconstruct( $word, @$c ) } );

        push @{ $score->{$together} }, $val;
    }

    # 
    return $score;
}

=head2 grouping()

=cut

sub grouping {
    my $scored = shift;
    my @groups = $scored =~ /([ku]\d+)/g;
    my ( $knowns, $unknowns ) = ( 0, 0 );
    my ( $knownc, $unknownc ) = ( 0, 0 );
    for ( @groups ) {
        if ( /k(\d+)/ ) {
            $knowns++;
            $knownc += $1;
        }
        if ( /u(\d+)/ ) {
            $unknowns++;
            $unknownc += $1;
        }
    }
    return $knowns, $unknowns, $knownc, $unknownc;
}

=head2 rle()

=cut

sub rle {
    my $scored = shift;
    # Run-length encode an "un-digitized" string.
    $scored =~ s/1/k/g; # Undigitize
    $scored =~ s/0/u/g; # "
    # Count contiguous chars.
    $scored =~ s/(.)\1*/$1. length $&/ge;
    return $scored;
}

=head2 power()

=cut

sub power { # Find the "non-overlapping powerset."

    # List if bitmasks.
    my $masks = shift;

    # Bucket for our saved combinations.
    my $combos = [];

    # Get a new powerset generator.
    my $power = Data::PowerSet->new(sort keys %$masks);

    # Consider each member of the powerset.. to save or skip?
    while (my $collection = $power->next) {
#        warn "C: @$collection\n";

        # Compare each mask against the others.
        LOOP: for my $i (0 .. @$collection - 1) {

            # Set the comparison mask.
            my $compare = $collection->[$i];

            for my $j ($i + 1 .. @$collection - 1) {

                # Set the current mask.
                my $mask = $collection->[$j];
#                warn "\tP:$compare v $mask\n";

                # Skip this collection if an overlap is found.
                if (not does_not_overlap($compare, $mask)) {
#                    warn "\t\tO:$compare v $mask\n";
                    last LOOP;
                }

                # Save this collection if we made it to the last pair.
                if ($i == @$collection - 2 && $j == @$collection - 1) {
#                    warn "\t\tE:$compare v $mask\n";
                    push @$combos, $collection;
                }
            }
        }
    }

    # Hand back the "non-overlapping powerset."
    return $combos;
}

=head2 get_knowns()

=cut

sub get_knowns { # Fingerprint the known word parts.
    my ($word, $lex) = @_;

    # Find the known word-part positions.
    my $known = {};

    # Poor-man's relational integrity:
    my $id = 0;
    my $mask_id = {};

    for my $i (values %$lex) {
        while ($word =~ /$i->{re}/g) {
            # Match positions.
            my ($m, $n) = ($-[0], $+[0]);
            # Get matched word-part.
            my $part = substr $word, $m, $n - $m;

            # Create the part-of-word bitmask.
            my $mask = 0 x $m;                      # Before known
            $mask   .= 1 x (($n - $m) || 1);        # Known part
            $mask   .= 0 x ($WLEN - $n);    # After known

            # Output our progress.
#            warn sprintf "%s %s - %s, %s (%d %d), %s\n",
#                $mask,
#                $i->{re},
#                substr($word, 0, $m),
#                $part,
#                $m,
#                $n - 1,
#                substr($word, $n),
#            ;

            # Save the known as a member of a list keyed by starting position.
            $known->{$id} = {
                part => $part,
                span => [$m, $n - 1],
                defn => $i->{defn},
                mask => $mask,
            };
            # Save the relationship between mask and id.
            $mask_id->{$mask} = $id++;
        }
    }

    return $known, $mask_id;
}

=head2 does_not_overlap()

=cut

sub does_not_overlap { # Compute whether the given masks overlap.

    # Get our masks to check.
    my ($mask, $check) = @_;

    # Create the bitstrings to compare.
    my $bitmask  = Bit::Vector->new_Bin($WLEN, $mask);
    my $orclone  = Bit::Vector->new_Bin($WLEN, $check);
    my $xorclone = Bit::Vector->new_Bin($WLEN, $check);

    # Compute or and xor for the strings.
    $orclone->Or($bitmask, $orclone);
    $xorclone->Xor($bitmask, $xorclone);

    # Return the "or & xor equivalent sibling."
    return $xorclone->equal($orclone) ? $orclone->to_Bin : 0;
}

=head2 or_together()

=cut

sub or_together { # Combine a list of bitmasks.

    # Get our masks to score.
    my @masks = @_;

    # Initialize the bitmask to return, to zero.
    my $result = Bit::Vector->new_Bin($WLEN, (0 x $WLEN));

    for my $mask (@masks) {
        # Create the bitstrings to compare.
        my $bitmask = Bit::Vector->new_Bin($WLEN, $mask);

        # Get the union of the bit strings.
        $result->Or($result, $bitmask);
    }

    # Return the "or sum."
    return $result->to_Bin;
}

=head2 reconstruct()

=cut

sub reconstruct {
    my ( $word, @masks ) = @_;

    my $strings = [];

    for my $mask (reverse sort @masks) {
        my $i = 0;
        my $last = 0;
        my $string  = '';
        for my $m ( split //, $mask ) {
            if ( $m ) {
                $string .= '<' unless $last;
                $string .= substr( $word, $i, 1 );
                $last = 1;
            }
            else {
                $string .= '>' if $last;
                $string .= substr( $word, $i, 1 );
                $last = 0;
            }
            $i++;
        }
        $string .= '>' if $last;
        push @$strings, $string;
    }

    return $strings;
}

1;
__END__

=head1 SEE ALSO

L<Lingua::TokenParse>

L<http://en.wikipedia.org/wiki/Affix>

=cut
