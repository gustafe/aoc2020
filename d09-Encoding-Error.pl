#! /usr/bin/env perl
# Advent of Code 2020 Day 9 - Encoding Error - complete solution
# Problem link: http://adventofcode.com/2020/day/9
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d09
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min max/;
use Data::Dumper;
use Test::More tests=>2;
#### INIT - load input data from file into array
my $testing = 0;
my @stream;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @stream, $_; }

### CODE
# set up window
my $lower = 0;
my $upper = $testing? 4 : 24;

my $target = $stream[$upper+1];
my %h;

for ($lower..$upper) {
    $h{$stream[$_]}++
}

OUTER:
while ($upper < scalar @stream) {

#    say join(" ", map {$stream[$_]} ($lower..$upper));
#    say "target: $target";
    my @tests;
    for my $i ($lower..$upper) {
	push @tests, $target-$stream[$i];
    }
#    say join(" ",@tests);
    my $found = 0;
    foreach (@tests) {
	$found++ if exists $h{$_};
    }
#    say $found;
    if (!$found) { # test for equality here
#	say "==> $target";
	last OUTER;
    } 
	delete $h{$stream[$lower]};
	$h{$stream[$upper+1]}++;
	$target = $stream[$upper+2];
	$lower++;
	$upper++;

}
is( $target,20874512 ,"Part 1: $target");
# part 2
my $part2;
# let's go from the top
my $start = $#stream;
while ($start>0) {
 #   say "$start";
    if ($stream[$start]>=$target) {
	$start--;
	next;
    }
#    next if $stream[$start]>=$target;
    my $sum = $stream[$start];
    my $next = $start-1;
    while ($sum<$target) {
#	say "$next $sum";
	$sum +=$stream[$next];
	$next--;
	
    }
  #  say "   $sum";
    if ($sum==$target) {
	# find smallest and largest
	my  $min = 2 * $stream[$#stream];
	my $max = -1;
	for ($next+1..$start) {
	    if ($stream[$_]<$min ) { $min=$stream[$_]}
	    if ($stream[$_]>$max) { $max= $stream[$_]}
	}
#	say "$min $max ", sum($min,$max);
#	say "==> ", join(' ', $start, $next+1, $stream[$start], $stream[$next+1]); 
	#	say "==> $start $next ",$stream[$start-1]+$stream[$next];
	$part2 = sum($min,$max);
	last;
    }
    $start--;
}

is($part2, 3012420, "Part 2: $part2");
