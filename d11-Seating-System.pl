#! /usr/bin/env perl
# Advent of Code 2020 Day 11 - Seating System - complete solution
# Problem link: http://adventofcode.com/2020/day/11
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d11
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use Test::More tests=>2;
use Clone qw/clone/;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $Map;
my $state;
my $maxrow=0;
my $maxcol;
foreach my $line (@file_contents) {
    $maxcol = 0;
    foreach my $char (split(//,$line)) {
	$Map->{$maxrow}->{$maxcol} = $char;
	$state->{$maxrow}->{$maxcol} = $char ;
	$maxcol++;
    }
    $maxrow++;
		     
}
sub dump_state {
    my ( $m ) = @_;
    for (my $r =0 ;$r<$maxrow;$r++) {
	for (my $c=0;$c<$maxcol;$c++) {
	    print $m->{$r}->{$c} // '.'
	}
	print "\n";
    }
}
sub compare_states {
    my ( $A, $B ) = @_;
    my ( $count, $diff ) = (0,0);
    for (my $r =0 ;$r<$maxrow;$r++) {
	for (my $c=0;$c<$maxcol;$c++) {
	    next unless (defined $A->{$r}{$c} and defined $B->{$r}{$c});
	    $count++ if $A->{$r}{$c} eq '#';
	    if ($A->{$r}{$c} ne $B->{$r}{$c}) {
		$diff++
	    }
	}
    }
    if ($diff) {
	return undef
    } else {
	return $count;
    }
}    
# part 1

my $newstate;
my $diffs=0;
for (1..99) {
    for (my $row=0; $row<$maxrow; $row++) {
	for (my $col=0;$col<$maxcol;$col++) {
	    next unless $Map->{$row}{$col} eq 'L';
	    my $occupied = 0;
	    for my $dir ([ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
 			  [ 0, -1 ],          , [ 0, 1 ],
			 [ 1, -1 ], [ 1, 0 ] , [ 1, 1 ]) {
		my ( $r,$c)=($row+$dir->[0],$col+$dir->[1]);
		next unless defined $Map->{$r}{$c};
		if ($Map->{$r}{$c} eq 'L' and $state->{$r}{$c} eq '#') {
		    $occupied++
		}
	    }
	    my $prev = $newstate->{$row}{$col} // '*';
	    if ($state->{$row}{$col} eq '#' and $occupied >= 4) {
#		$diffs++ unless		  ($newstate->{$row}{$col} eq $state->{$row}{$col});
		$newstate->{$row}{$col} = 'L'
	    } elsif ($state->{$row}{$col} eq 'L' 
 and $occupied==0) {
#		$diffs++ unless		  ($newstate->{$row}{$col} eq $state->{$row}{$col});
		$newstate->{$row}{$col}= '#'
	    } else {
		$newstate->{$row}{$col} = $state->{$row}{$col}
	    }
	    $diffs++ unless ($prev eq $newstate->{$row}{$col});
	}
	
    }
#    say "$_";
    my $same = compare_states( $state, $newstate );
    if ($same) {
	is( $same, 2093 , "Part 1: ".$same);
	say "solution to part 1 found after $_ iterations";
	last;
    }
    $state = clone $newstate;

}
#exit 0;
# part 2
$state = clone $Map;
$newstate = undef;

foreach (1..99) {
    # scan the map and assign seats
    for (my $row=0;$row<$maxrow;$row++) {
	for (my $col=0;$col<$maxcol;$col++) {
	    next unless $Map->{$row}{$col} eq 'L';
	    my $occupied = 0;
	  DIRECTION:
	    for my $dir ([-1,0,'N'],[-1,1,'NE'],[0,1,'E'],[1,1,'SE'],[1,0,'S'],[1,-1,'SW'],[0,-1,'W'],[-1,-1,'NW']) {
		my ( $r,$c )= ($row + $dir->[0], $col + $dir->[1]);
		next DIRECTION unless defined $Map->{$r}{$c};
		while (defined $Map->{$r}{$c}) {
		    if ($Map->{$r}{$c} eq 'L') {
			if ($state->{$r}{$c} eq '#') {
			    $occupied++
			}
			next DIRECTION;
		    }
		    $r += $dir->[0];
		    $c += $dir->[1];
		}
	    }
	    if ($state->{$row}{$col} eq 'L' and $occupied == 0) {
		$newstate->{$row}{$col} = '#'
	    } elsif ($state->{$row}{$col} eq '#' and $occupied >=5 ) {
		$newstate->{$row}{$col} = 'L'
	    } else {
		$newstate->{$row}{$col} = $state->{$row}{$col}
	    }
	}
    }
#    say $_;
    my $same = compare_states( $state, $newstate);
    if ($same) {
	is($same, 1862,"Part 2: ".$same);
	say "solution to part 2 found after $_ iterations";
	last;
    }
    $state = clone $newstate;

}
say "Duration: ", tv_interval($start_time) * 1000, "ms";
