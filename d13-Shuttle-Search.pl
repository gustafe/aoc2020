#! /usr/bin/env perl
# Advent of Code 2020 Day 13 - Shuttle Search - complete solution
# Problem link: http://adventofcode.com/2020/day/13
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d13
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/all max product/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my $run_unit_tests = shift // 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

#### SUBS
sub part1 {
    my ( $dep_time, $string ) = @_;
    my %possibles;
    foreach ( split( ',', $string ) ) {
        next unless $_ =~ /\d+/;
        my $no_of_times = int( $dep_time / $_ );
        my $next        = $no_of_times * $_ + $_;
        $possibles{$next} = $_;

    }
    my $next_dep = ( sort { $a <=> $b } keys %possibles )[0];
    return ( $next_dep - $dep_time ) * $possibles{$next_dep};
}

sub run {
    my ($string) = @_;
    my @targets  = ();
    my @offsets  = ();
    my $idx      = 0;
    for ( split( ',', $string ) ) {
        if ( $_ ne 'x' ) {
            push @targets, $_;
            push @offsets, $idx;
        }
        $idx++;
    }
    my $pos  = 1;
    my $t    = $offsets[0];
    my $step = $targets[0];

    # Solution inspired by
    # https://www.reddit.com/r/adventofcode/comments/kc60ri/2020_day_13_can_anyone_give_me_a_hint_for_part_2/gfnnfm3/

    while ( $pos <= $#targets ) {

        # Iteratively search for the next $t that satisfies all
        # previous conditions.

        do {
            $t += $step;
            } until (
            all { ( $t + $offsets[$_] ) % $targets[$_] == 0 } ( 0 .. $pos ) );

        # The new $step is the product of the previous factors, and we
        # start from where we left off when the loop finished
	# This works because all bus ids are prime

        $step = product( map { $targets[$_] } ( 0 .. $pos ) );
        $pos++;
    }

    return $t;
}
### CODE

#my $departure_time = $file_contents[0];
my $part1 = part1( $file_contents[0], $file_contents[1] );
is( $part1, 2845, "Part 1: " . $part1 );

# part 2
if ($run_unit_tests) {
    say "==> running unit tests for part 2";
    while (<DATA>) {
        chomp;
        my ( $string, $starting, $expected ) = split;
        my $res = run($string);
	if (!defined $expected) {
	    say $res;
	    next;
	}
#	say $res if !defined expecting;
        is( $res, $expected );

    }
    say "==> tests done";
}
my $part2 = run( $file_contents[1] );
is( $part2, 487905974205117, "Part 2: " . $part2 );
done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";

__DATA__
7,13,x,x,59,x,31,19 1000000 1068781
17,x,13,19 3000 3417
67,7,59,61 750000  754018
67,x,7,59,61 750000 779210
67,7,x,59,61 1260000 1261476
1789,37,47,1889 1202160000 1202161486
41,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,431,x,x,x,x,x,x,x,23,x,x,x,x,13,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,x,x,863,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,29 from_wink
