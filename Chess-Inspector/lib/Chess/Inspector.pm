package Chess::Inspector;
use strict;
use warnings FATAL => 'all';
use parent qw(Chameleon5::Site::Base);

use lib '/Users/gene/sandbox/github/ology/Chess-Rep-Coverage/lib';
use Chess::Rep::Coverage;
use Data::Dumper;

our $VERSION = '0.01';

=head1 NAME

Chess::Inspector - Inspect a chess game

=head1 SYNOPSIS

    use Chess::Inspector;
    my $foo = Chess::Inspector->new();

=head1 METHODS

=cut

sub board
{
    my ($self, %args) = @_;
    for my $row (1 .. 8)
    {
        my $parent = $self->fast_append( tag => 'board', data => { row => $row } );
        for my $col ('A' .. 'H')
        {
            $self->fast_append(
                parent => $parent,
                tag    => 'cell',
                data   => {
                    col => $col
                },
            );
        }
    }
    return;
}

sub coverage
{
    my ($self, %args) = @_;
    my $g = Chess::Rep::Coverage->new;
$self->logger->debug(Dumper $g);
    return;
}

1;
