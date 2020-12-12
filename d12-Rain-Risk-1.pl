#! /usr/bin/env perl
# Advent of Code 2020 Day 12 - Rain Risk - part 1
# Problem link: http://adventofcode.com/2020/day/12
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d12
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More tests=>1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }
### SUBS

### CODE
my @instr;
for (@file_contents) {
    if (m/([NSEWLRF])(\d+)/) {
#	say "$1 $2";
	push @instr, [$1,$2];

    } else {
	die "can't parse: $_";
    }
}
my %L90 = (N=>'W',E=>'N',S=>'E',W=>'S');
my %L180= (N=>'S',E=>'W',S=>'N',W=>'E');
my %L270= (N=>'E',E=>'S',S=>'W',W=>'N');
my %move = (N=> sub {
		my ($d,$p)=@_;
		$p->[0][0] += $d;
		return $p;
	    },
	    S=>sub{
		my ($d,$p)=@_;
		$p->[0][0] -= $d;
		return $p;
	    },
	    E=>sub {
		my ( $d, $p )  = @_;
		$p->[0][1] += $d;
		return $p;
	    },
	    W => sub {
		my ($d, $p) = @_;
		$p->[0][1] -= $d;
		return $p;
	    },
	    F => sub {
		my ( $d, $p) =@_;
		my $dir = $p->[1];
		if ($dir eq 'N') { $p->[0][0]+=$d; return $p}
		elsif ($dir eq 'S') { $p->[0][0]-=$d; return $p}
		elsif ($dir eq 'E') { $p->[0][1]+=$d; return $p}
		else { $p->[0][1]-=$d;return $p}
	    },
	    L =>sub {my($th,$p)=@_;
		 my $dir = $p->[1];
		 if ($th == 90) {
		     $p->[1] = $L90{$dir};
		     return $p;
		 } elsif ($th == 180) {
		     $p->[1] = $L180{$dir};
		     return $p;
		 } else {
		     $p->[1] = $L270{$dir};
		     return $p;
		 }
		},
	    R => sub {my ($th, $p) =@_; my $dir = $p->[1];
		  if ($th==90) {
		      $p->[1] = $L270{$dir}; return $p;
		  } elsif ($th==180) {
		      $p->[1] = $L180{$dir}; return $p;
		  } else {
		      $p->[1] = $L90{$dir}; return $p;
		  }
		 },

	   );
my $pos = [[0,0],'E'];
foreach my $ins (@instr) {

#    next unless $ins->[0] =~ m/[NESWF]/;
#    print Dumper $ins;
    $pos = $move{$ins->[0]}->($ins->[1], $pos);
#    printf("%s,%d -> (%d,%d) %s\n", $ins->@*,$pos->[0]->@*, $pos->[1]);
}
#print Dumper $pos;
my $part1 =  sum(map {abs($_)} @{$pos->[0]});
is( $part1, 938, "Part 1: ".$part1);
say "Duration: ", tv_interval($start_time) * 1000, "ms";
