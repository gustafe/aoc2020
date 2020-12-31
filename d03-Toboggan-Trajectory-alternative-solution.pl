#! /usr/bin/env perl
# Advent of Code 2020 Day 3 - Toboggan Trajectory - alternative solution
# Problem link: http://adventofcode.com/2020/day/3
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d03
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/any product/;
use Test::More tests => 2;
#### INIT - load input data from file into the map we need
my $testing = 0;
my $Map;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) {
    chomp;
    s/\r//gm;
    push @{$Map}, $_;
}

### CODE
my $maxcol = scalar( split( //, $Map->[0] ) );
my @factors;

# this string is to avoid definedness errors when we venture outside the map
my $empty = ('.') x $maxcol;

# slope => [right , down]
my @toboggans = ({slope=>[3,1]},{slope=>[1,1]},{slope=>[5,1]},
		 {slope=>[7,1]},{slope=>[1,2]},);

# initialize each toboggan
map { $_->{r} = 0; $_->{c} = 0; $_->{hits} = 0 } @toboggans;

# as long as there's a toboggan on the course...
while ( any { $_->{r} < scalar @$Map } @toboggans ) {

    # did anyone hit a tree?
    map {$_->{hits}+=substr($Map->[$_->{r}]//$empty, $_->{c}, 1) eq '#'?1:0
    } @toboggans;

    # move the toboggans
    map {$_->{r}+=$_->{slope}[1];
         $_->{c}=($_->{c}+$_->{slope}[0]) % $maxcol
    } @toboggans;

}
my $part1 = $toboggans[0]->{hits};
my $part2 = product( map { $_->{hits} } @toboggans );
is( $part1, 223,        "Part 1: $part1" );
is( $part2, 3517401300, "Part 2: $part2" );

