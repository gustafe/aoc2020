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
my @answers;
my $part1;
my $part2;
foreach (@file_contents) {
    my $per_group;
    my $ary;
    foreach ( split( "\n", $_ ) ) {
        my $h;
        foreach ( split( //, $_ ) ) {
            $per_group->{$_}++;
            $h->{$_}++;
        }
        push @{$ary}, $h;

    }
    $part1 += scalar keys %{$per_group};
    push @answers, $ary;
}

foreach my $group (@answers) {
    my %collate;
    foreach my $person ( @{$group} ) {
        foreach my $c ( 'a' .. 'z' ) {
            $collate{$c}++ if exists $person->{$c};
        }
    }
    foreach my $k ( keys %collate ) {
        $part2++ if $collate{$k} == scalar @{$group};
    }
}
is( $part1, 6382, "Part1: $part1" );
is( $part2, 3197, "Part2: $part2" );

