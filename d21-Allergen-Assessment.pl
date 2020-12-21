#! /usr/bin/env perl
# Advent of Code 2020 Day 21 - Allergen Assessment - complete solution
# Problem link: http://adventofcode.com/2020/day/21
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d21
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use Test::More tests=>2; 
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my %ingredients;
my %allergens;
foreach my $line (@file_contents) {
    my @ins; my @alls;
    if ($line =~ m/^(.*) \(contains (.*)\)$/) {
	@ins = split(/ /, $1);
	@alls = split(',', $2);
	map { s/^\s+|\s+$//g } @alls;

	foreach my $in (@ins) {
	    $ingredients{$in}->{num}++;
	}
	foreach my $al (@alls) {
	    $allergens{$al}->{num}++;
	    foreach my $i (@ins) {
		$allergens{$al}->{counts}->{$i}++
	    }
	}
    } else {
	die "can't parse: $line\n";
    }
}
my %possibles;
foreach my $al (keys %allergens) {
    foreach my $in (keys %{$allergens{$al}->{counts}}) {
	if ($allergens{$al}->{counts}->{$in} == $allergens{$al}->{num}) {
	    $possibles{$in}->{$al}++
	}
    }
}

my $part1 = 0;
foreach my $in (keys %ingredients) {
    $part1 += $ingredients{$in}->{num} unless exists $possibles{$in}
}
is ($part1, 2461,"Part 1: ". $part1);

# part 2

my %solution;
# this part cribbed from 2018D16 and 2020D16
while ( keys %possibles ) {
    foreach my $ing ( keys %possibles ) {
        if ( scalar keys %{ $possibles{$ing} } == 1 ) {
            my $al = ( keys %{ $possibles{$ing} } )[0];
            $solution{$ing} = $al;
            delete $possibles{$ing};
        }

        while ( my ( $k, $al ) = each %solution ) {
            foreach my $v ( keys %{ $possibles{$ing} } ) {
                if ( $v eq $al ) {
                    delete $possibles{$ing}->{$v};
                }
            }
        }
        if ( scalar keys %{ $possibles{$ing} } == 0 ) {
            delete $possibles{$ing};
        }
    }
}
my @part2 =();
foreach my $in (sort {$solution{$a} cmp $solution{$b}} keys %solution) {
    push @part2, $in
}
my $answer_str = join(',',@part2);
is ( $answer_str, 'ltbj,nrfmm,pvhcsn,jxbnb,chpdjkf,jtqt,zzkq,jqnhd', "Part 2: ok");
say "Duration: ", tv_interval($start_time) * 1000, "ms";
