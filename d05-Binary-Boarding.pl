#! /usr/bin/env perl
# Advent of Code 2020 Day 5 - Binary Boarding - complete solution
# Problem link: http://adventofcode.com/2020/day/5
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d05
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/min max/;
use Test::More tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
sub half_range {
    my ( $lower, $upper, $choice ) = @_;
    my $mid = int( ( $upper - $lower ) / 2 );
    if ( $choice =~ m/F|L/ ) {    #lower half
        return [ $lower, $lower + $mid ];
    }
    elsif ( $choice =~ m/B|R/ ) {    #upper half
        return [ $lower + $mid + 1, $upper ];
    }
    else {
        die "can't work with these values! $lower $upper $choice";
    }
}
my %ids = ();
while (@file_contents) {
    my @string = split( //, shift @file_contents );
    my ( $lower, $upper ) = ( 0, 127 );
    my $pos = 0;
    while ( $pos < 7 ) {
        my $choice = shift @string;
        ( $lower, $upper ) = @{ half_range( $lower, $upper, $choice ) };
        $pos++;
    }
    my $row = $lower;
    ( $lower, $upper ) = ( 0, 7 );
    while (@string) {
        my $choice = shift @string;
        ( $lower, $upper ) = @{ half_range( $lower, $upper, $choice ) };
    }

    my $column = $lower;
    my $seat_id = $row * 8 + $column;
    $ids{$seat_id}++;

}
my $min_id = min keys %ids;
my $max_id = max keys %ids;
my $part1  = $max_id;
my $part2;
for ( $min_id .. $max_id ) {
    $part2 = $_ unless exists $ids{$_};
}
is( $part1, 850, "Part1: $part1" );
is( $part2, 599, "Part2: $part2" );
