#! /usr/bin/env perl
# Advent of Code 2020 Day 2 - Password Philosophy - complete solution
# Problem link: http://adventofcode.com/2020/day/2
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d02
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my %counts = ( 1 => 0, 2 => 0 );
foreach my $line (@file_contents) {
    my ( $min, $max, $req, $pwd ) = $line =~ m/^(\d+)-(\d+) (.): (.*)$/;

    my %freq;
    my @ary = split( //, $pwd );
    foreach my $c (@ary) {
        $freq{$c}++;
    }

    # this assignment is just to supress errors in the numeric
    # comparison in case the key doesn't exist
    my $res = $freq{$req} ? $freq{$req} : 0;
    if ( ( $min <= $res ) and ( $res <= $max ) ) {
        $counts{1}++;
    }

    # part 2
    my @pos = ( 0, 0 );
    if ( $ary[ $min - 1 ] eq $req ) {
        $pos[0] = 1;
    }
    if ( $ary[ $max - 1 ] eq $req ) {
        $pos[1] = 1;
    }
    if ( sum(@pos) == 1 ) {
        $counts{2}++;
    }
}
is( $counts{1}, 477, "Part 1: $counts{1}" );
is( $counts{2}, 686, "Part 2: $counts{2}" );

