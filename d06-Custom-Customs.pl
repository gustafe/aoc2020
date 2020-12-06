#! /usr/bin/env perl
# Advent of Code 2020 Day 6 - Custom Customs - complete solution
# Problem link: http://adventofcode.com/2020/day/6
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d06
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
{
    # set the local IFS to an empty string to treat the input as paragraphs
    local $/ = "";
    while (<$fh>) {
        chomp;
        push @file_contents, $_;
    }
}

### CODE
my $part1;
my $part2;
foreach (@file_contents) {
    my $respondents = 0;
    my %h;
    foreach ( split( "\n", $_ ) ) {
        foreach ( split( //, $_ ) ) {
            $h{$_}++;
        }
        $respondents++;
    }
    foreach my $k ( keys %h ) {
        $part1++;
        $part2++ if $h{$k} == $respondents;
    }
}
is( $part1, 6382, "Part1: $part1" );
is( $part2, 3197, "Part2: $part2" );
