#! /usr/bin/env perl
# Advent of Code 2020 Day 3 - Toboggan Trajectory - complete solution
# Problem link: http://adventofcode.com/2020/day/3
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d03
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More tests => 2;
#### INIT - load input data from file into the map we need
# We store the map by rows, and unpack it into columns when needed.
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

# coordinates: (row, column);
foreach my $move ( [ 1, 3 ],
		   [ 1, 1 ],
		   [ 1, 5 ],
		   [ 1, 7 ],
		   [ 2, 1 ] ) {
    my @pos = ( 0, 0 );
    my $hits = 0;

    while ($pos[0] < scalar @{$Map}) {
        # Check for tree.  We know we start in a clear space, so this
	# can be done before a move. Doing it this way avoids an
	# irritating check for definedness in the last row, at the
	# expense of this long commment

        my @treeline = split( //, $Map->[ $pos[0] ] );
        if ( $treeline[ $pos[1] ] eq '#' ) {
            $hits++;
        }
        $pos[0] += $move->[0];
	# The obvious way to account for the map extending to the
	# right is to use a modulus to "warp" back into the map we
	# have. So let's do that.
        $pos[1] = ( $pos[1] + $move->[1] ) % $maxcol;
    } 
    push @factors, $hits;
}

is( $factors[0], 223, "Part 1: $factors[0]" );
my $result = 1;
foreach my $f (@factors) {
    $result *= $f;
}
is( $result, 3517401300, "Part 2: $result" );
