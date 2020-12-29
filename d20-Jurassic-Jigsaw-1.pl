#! /usr/bin/env perl
# Advent of Code 2020 Day 20 - Jurassic Jigsaw - part 1
# Problem link: http://adventofcode.com/2020/day/20
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d20
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
{
    local $/ = '';
    while (<$fh>) {
        chomp;
        push @file_contents, $_;
    }
}
### SUBS
sub transpose {    # https://perlmaven.com/transpose-a-matrix
    my ($M) = @_;
    my $T;
    for my $r ( 0 .. scalar @$M - 1 ) {
        for my $c ( 0 .. scalar @{ $M->[$r] } - 1 ) {
            $T->[$c][$r] = $M->[$r][$c];
        }
    }
    return $T;
}

sub rotate90 {     # https://stackoverflow.com/a/8664879
    my ($M) = @_;
    my $T = transpose($M);
    my $R;
    for my $r ( 0 .. scalar @$T - 1 ) {
        push @$R, [ reverse @{ $T->[$r] } ];
    }
    return $R;
}

sub flipH {        # flip around horisontal axis, up <-> down
    my ($M) = @_;
    my $F;
    my $maxr = scalar @$M - 1;
    for ( my $r = $maxr; $r >= 0; $r-- ) {
        push @$F, $M->[$r];
    }
    return $F;
}

sub flipV {        # flip around horisontal axis, left <-> right
    my ($M) = @_;
    my $F;
    for my $r ( 0 .. scalar @$M - 1 ) {
        push @$F, [ reverse @{ $M->[$r] } ];
    }
    return $F;
}

sub edges {
    my ($M) = @_;
    my $len = scalar @$M;    # implicitely square matrix
    my $res;

    # N, E, S, W
    push @$res, $M->[0];

    # E
    my $E;
    for my $r ( 0 .. $len - 1 ) {

        $E->[$r] = $M->[$r][ $len - 1 ];
    }
    push @$res, $E;

    # S
    push @$res, $M->[ $len - 1 ];

    # W
    my $W;
    for my $r ( 0 .. $len - 1 ) {
        $W->[$r] = $M->[$r][0];
    }
    push @$res, $W;
    return $res;

}
sub all_edges {
    my ($M) = @_;
    my $all_edges;
    my $res;
    push @$all_edges, edges($M);
    push @$all_edges, edges( flipH($M) );
    push @$all_edges, edges( flipV($M) );

    my $T = rotate90($M);
    push @$all_edges, edges($T);
    push @$all_edges, edges( flipH($T) );
    push @$all_edges, edges( flipV($T) );

    push @$all_edges, edges( rotate90($T) );
    push @$all_edges, edges( rotate90( rotate90($T) ) );

    foreach my $el (@$all_edges) {
	foreach my $e (@$el) {
	    my @edge = @$e;
	    my @rev = reverse @edge;
	    $res->{join('',@edge)}++;
	    $res->{join('',@rev)}++;
	}
    }
    return $res;
}


sub dump_matrix {
    my ($M) = @_;
    for my $r (@$M) {
        say join( ' ', @$r );
    }
    say '';
}

sub dump_edges {
    my ($e) = @_;
    foreach (@$e) {
        say join( '', @{$_} );
    }
    say '';
}

sub dump_string {
    my ($M) = @_;
    my $str;
    foreach (@$M) {
        $str .= join( '', @{$_} );
    }
    return $str;
}

### CODE
my %tiles;
foreach my $entry (@file_contents) {
    my @rows      = split( "\n", $entry );
    my $first_row = shift @rows;
    my ($id)      = ( $first_row =~ /(\d+)/ );


    my $matrix;
    foreach my $r (@rows) {
        push @$matrix, [ split //, $r ];


    }

    $tiles{$id}->{matrix} = $matrix;
    $tiles{$id}->{edges} = all_edges( $matrix );
}


foreach my $id1 ( sort keys %tiles ) {
    my %edges1 = $tiles{$id1}->{edges}->%*;
    foreach my $id2 ( sort keys %tiles ) {
        next if ( $id1 == $id2 );
        my $matches = 0;

        foreach my $e1 ( keys %edges1 ) {
            if ( exists $tiles{$id2}->{edges}->{$e1} ) {
                $tiles{$id1}->{matches}->{$id2} = $e1;
		$tiles{$id2}->{matches}->{$id1} = $e1;
            }
        }

    }
}

my $part1 = 1;
foreach my $k ( keys %tiles ) {
#    say "$k ",scalar keys $tiles{$k}->{matches}->%*;
    if ( scalar keys $tiles{$k}->{matches}->%* == 2 ) {        $part1 *= $k;    }
}
is( $part1, 19955159604613, "Part 1: ".$part1);
done_testing();

say "Duration: ", tv_interval($start_time) * 1000, "ms";

