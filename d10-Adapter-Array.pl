#! /usr/bin/env perl
# Advent of Code 2020 Day 10 - Adapter Array - complete solution
# Problem link: http://adventofcode.com/2020/day/10
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d10
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/max/;
use Test::More tests => 2;
use Time::HiRes qw/gettimeofday tv_interval/;
use Memoize ;
my $start_time = [gettimeofday];

#### INIT - load input data from file into array
my $testing = shift // 0;
my %adapters;
my $file = $testing ? 'test' . $testing . '.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) {
    chomp;
    s/\r//gm;
    $adapters{$_} = undef;
}

### CODE
my $device = max( keys %adapters ) + 3;
$adapters{$device} = undef;
my $joltage = 0;
my $count   = 0;
my %diffs   = ();
while ( $count < scalar keys %adapters ) {
STEPS:
    for my $step ( 1 .. 3 ) {
        my $sought = $joltage + $step;
        if ( exists $adapters{$sought} ) {
            $adapters{$sought} = $joltage;
            $diffs{$step}++;
            $joltage += $step;
            last STEPS;
        }
    }
    $count++;
}

my $part1 = $diffs{1} * $diffs{3};
is( $part1, 1917, "Part 1: " . $part1 );

# part 2
# This solution inspired by a solution by /u/Loonis
# https://www.reddit.com/r/adventofcode/comments/ka8z8x/2020_day_10_solutions/gf9bwuw/

my @sequence = sort { $a <=> $b } keys %adapters;
unshift @sequence, 0;

# build a graph
my @G;
for my $i ( 0 .. $#sequence ) {
    $G[$i]->{v} = $sequence[$i];
    for my $step (  1 .. 3 ) {
        last unless defined $sequence[$i+$step];
        push @{ $G[$i]->{e} }, $i+$step if $sequence[$i+$step] - $sequence[$i] <= 3;
    }
}

# this is part of a test of Memoize. It's the same sub are `traverse`
# but without the explicit memoization

sub slow_traverse {
    my $node  = $G[ $_[0] ];
    my $count = 0;
    return 1 unless defined $node->{e};
    foreach my $idx ( @{ $node->{e} } ) {
        $count += slow_traverse($idx);
    }
    return $count;

}
memoize ('slow_traverse');

sub traverse {
    my $node  = $G[ $_[0] ];
    my $count = 0;
    return 1 unless defined $node->{e};
    return $node->{m} if defined $node->{m};

    foreach my $idx ( @{ $node->{e} } ) {
        $count += traverse($idx);
    }
    $node->{m} = $count;
    return $count;
}
my $part2;
#$part2 = slow_traverse(0);
$part2 = traverse(0);

is( $part2, 113387824750592, "Part 2: " . $part2 );

say "Duration: ", tv_interval($start_time) * 1000, "ms";

