#! /usr/bin/env perl
# Advent of Code 2020 Day 1 - Report Repair - complete solution
# Problem link: http://adventofcode.com/2020/day/1
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d01
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

# in this case, we also load a hash where the values in the list are the keys

my $pos = 0;
my %index;
while (<$fh>) {
    chomp;
    s/\r//gm;

    # Add the list positions as an arrayref, in case there are doubles
    # and the order counts. It turns out it doesn't in my input, each
    # value is unique

    push @{ $index{$_} }, $pos;
    push @file_contents, $_;
    $pos++;
}
my @invoice = @file_contents;

### CODE

# part 1

while (@invoice) {
    my $candidate = shift @invoice;
    my $target    = 2020 - $candidate;
    if ( exists $index{$target} ) {
        my $part1 = $candidate * $target;
        is( $part1, 870331, "Part 1: $part1" );
        last;
    }
}

# part 2

# reload the data we shift()ed out in part 1
@invoice = @file_contents;

# just select a candidate and search through the rest
OUTER:
for my $i ( 0 .. $#invoice ) {
    my $candidate1 = $invoice[$i];
    for my $j ( $i + 1 .. $#invoice ) {
        next if ( $invoice[$j] > 2020 - $candidate1 );
        my $target = 2020 - ( $candidate1 + $invoice[$j] );
        if ( exists $index{$target} ) {
            my $part2 = $candidate1 * $invoice[$j] * $target;
            is( $part2, 283025088, "Part 2: $part2" );

            last OUTER;
        }
    }
}

