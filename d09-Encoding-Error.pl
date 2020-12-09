#! /usr/bin/env perl
# Advent of Code 2020 Day 9 - Encoding Error - complete solution
# Problem link: http://adventofcode.com/2020/day/9
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d09
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max/;
use Data::Dumper;
use Test::More tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @stream;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @stream, $_; }

### CODE
# set up window
my $lower = 0;
my $upper = $testing ? 4 : 24;

my $target = $stream[ $upper + 1 ];
my %h;

for ( $lower .. $upper ) {
    $h{ $stream[$_] }++;
}

while ( $upper < scalar @stream ) {

    my $match = grep { exists $h{$_} }
        map { $target - $stream[$_] } ( $lower .. $upper );

    last unless $match;

    # move our window
    delete $h{ $stream[$lower] };
    $h{ $stream[ $upper + 1 ] }++;
    $target = $stream[ $upper + 2 ];
    $lower++;
    $upper++;
}
is( $target, 20874512, "Part 1: $target" );

# part 2
my $part2;

# let's go from the top
my $start = $#stream;
while ( $start > 0 ) {
    if ( $stream[$start] >= $target ) {
        $start--;
        next;
    }

    my $sum  = $stream[$start];
    my $next = $start - 1;
    while ( $sum < $target ) {
        $sum += $stream[$next];
        $next--;
    }

    if ( $sum == $target ) {    # this could probably be more elegant

        # find smallest and largest
        my @contig = map { $stream[$_] } ( $next + 1 .. $start );
        $part2 = sum( min(@contig), max(@contig) );
        last;
    }
    $start--;
}

is( $part2, 3012420, "Part 2: $part2" );
