#! /usr/bin/env perl
# Advent of Code 2020 Day 7 - Handy Haversacks - complete solution
# Problem link: http://adventofcode.com/2020/day/7
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d07
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More tests=>2;
#### INIT - load input data from file into array
my $testing =0;
my $opt = shift//0;
my @file_contents;
my $testfile;
if ($opt) { $testfile='test2.txt'
	} else {
	    $testfile='test.txt'
	}
my $file = $testing ? $testfile : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $hash;
while (@file_contents) {
    my $line = shift @file_contents;
#    say "$line";
    my ($container, $contents) = $line =~ m/^(.*) bags contain (.*)$/;
#    say "==> $container";
    if ($contents =~ /no other bags/) {
	$hash->{$container} = {};
	next;
    }
    my @contents = split(/,/, $contents);
    foreach my $content (@contents) {
	my ( $amount, $kind) = $content =~ m/(\d+) (.*) bag/;
#	say "    $amount $kind";
	$hash->{$container}->{$kind} = $amount;
    }
}
#print Dumper $hash;
my %results;
my @queue = ('shiny gold');
while (@queue) {
    my $target = shift @queue;
    foreach my $bag (keys %$hash) {
	if (exists $hash->{$bag}->{$target}) {
	    $results{$bag}++;
	    push @queue, $bag;
	}
    }
}

#print Dumper \%results;
my  $part1 = scalar keys %results;
is( $part1 , 268, "Part1: $part1");

# part 2
@queue = (['shiny gold',1]);
my $count = 0;
#my %tree;
#my %seen = ('shiny gold'=>1);
while (@queue) {
    my $target = shift @queue;
    foreach my $bag (keys %{$hash->{$target->[0]}}) {
	my $send_on = $target->[1] * $hash->{$target->[0]}->{$bag};
	$count += $send_on;
	push @queue, [$bag, $send_on];
#	push @{$tree{$target->[0]}},[$bag, $hash->{$target->[0]}->{$bag} ]
    }
}
is ( $count, 7867, "Part2: $count");
__END__
#print Dumper \%tree;

@queue = (['shiny gold',1]);
my $count=0;
while (@queue) {

    my $cur = shift @queue;
    say "~~", join(',',@$cur);
#    $count += $cur->[1];
    foreach my $node (@{$tree{$cur->[0]}}) {
	#	say join(',',@$node);

	my $send_on = $cur->[1]* $node->[1];
	say "  $send_on";
	$count += $send_on;
	push @queue, [$node->[0], $send_on ];
    }

#    say join(',',map{"[$_->[0],$_->[1]]"} @queue);
    say "==> $count";		
}
say $count;
