#! /usr/bin/env perl
# Advent of Code 2020 Day 2 - Password Philosophy - complete solution
# Problem link: http://adventofcode.com/2020/day/2
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d02
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
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

    my @ary = split( //, $pwd );
    my %freq;
    map { $freq{$_}++ } @ary;

    # this assignment is just to supress errors in the numeric
    # comparison in case the key doesn't exist
    my $res = $freq{$req} ? $freq{$req} : 0;
    $counts{1}++ if ( ( $min <= $res ) and ( $res <= $max ) );

    # part 2

    my @pos = map { $ary[ $_ - 1 ] eq $req ? 1 : 0 } ( $min, $max );
    $counts{2}++ if ( $pos[0] ^ $pos[1] );

}
is( $counts{1}, 477, "Part 1: $counts{1}" );
is( $counts{2}, 686, "Part 2: $counts{2}" );

