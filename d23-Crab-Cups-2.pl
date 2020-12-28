#! /usr/bin/env perl
# Advent of Code 2020 Day 23 - Crab Cups - part 2
# Problem link: http://adventofcode.com/2020/day/23
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d23
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More tests=>1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my $input = $testing ? '389125467' : '942387615';
### CODE
my @circle;
my @input_ary = split( //, $input );

my $first = $input_ary[0];
my $last  = $input_ary[-1];
my $prev  = $first;
for my $i ( 1 .. $#input_ary ) {

    $circle[$prev] = $input_ary[$i];
    $prev = $input_ary[$i];
}
for my $j ( 10 .. 1_000_000 ) {
    $circle[$prev] = $j;
    $prev = $j;
}
$circle[1_000_000] = $first;
printf(
    "1: %d val1: %d 50: %d 500_000: %d 999999: %d\n",
    $circle[1], $circle[ $circle[1] ],
    $circle[50], $circle[500000], $circle[999999]
);


for my $turn ( 1 .. 10_000_000 ) {
    say "==> $turn" if $turn % 500_000 == 0;
    my $pointer = $first;
    my %pickup = ( 0 => 1 );
    for ( 1 .. 3 ) {
        $pointer = $circle[$pointer];
        $pickup{$pointer} = 1;
    }

    my $dest = $first - 1;
    while ( exists $pickup{$dest} ) {
        $dest = ( $dest - 1 ) % 1_000_001;
    }

    my $new_first   = $circle[$pointer];
    my $new_pointer = $circle[$dest];
    my $new_dest    = $circle[$first];
    $circle[$first]   = $new_first;
    $circle[$pointer] = $new_pointer;
    $circle[$dest]    = $new_dest;

    $first = $circle[$first];
}
printf(
    "1: %d val1: %d 50: %d 500_000: %d 999999: %d\n",
    $circle[1], $circle[ $circle[1] ],
    $circle[50], $circle[500000], $circle[999999]
);

my $part2 = $circle[1] * ( $circle[ $circle[1] ] );

is( $part2, 562136730660, "Part 2: ".$part2);
say "Duration: ", tv_interval($start_time) * 1000, "ms";
