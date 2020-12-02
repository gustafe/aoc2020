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

### CODE
my @invoice = @file_contents;
my %ans     = ();

OUTER:
for my $i ( 0 .. $#invoice ) {
    my $candidate = $invoice[$i];
    for my $j ( $i + 1 .. $#invoice ) {
        if ( $candidate + $invoice[$j] == 2020 ) {
            $ans{1} = $candidate * $invoice[$j];
        }
        next if ( $invoice[$j] > 2020 - $candidate );
        my $target = 2020 - ( $candidate + $invoice[$j] );
        if ( exists $index{$target} ) {
            my $part2 = $candidate * $invoice[$j] * $target;
            $ans{2} = $part2;
            last OUTER if scalar keys %ans == 2;
        }
    }
}
is( $ans{1}, 870331,    "Part 1: $ans{1}");
is( $ans{2}, 283025088, "Part 2: $ans{2}" );

