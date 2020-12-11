#! /usr/bin/env perl
# Advent of Code 2020 Day 11 - Seating System - part 1 
# Problem link: http://adventofcode.com/2020/day/11
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d11
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use Test::More tests=>1;
use Time::HiRes qw/gettimeofday tv_interval/;
use Clone qw/clone/;
my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### SUBS

sub dump_state {
    my ($S) = @_;
    foreach ( @{$S} ) {
        foreach my $c ( @{$_} ) {
            print $c // ' ';
        }
        print "\n";
    }
}

sub compare_states {
    my ( $in, $out ) = @_;
    my $count = 0;
    my $diff  = 0;
    for ( my $r = 0; $r < scalar @$in; $r++ ) {
        for ( my $c = 0; $c < scalar $in->[$r]->@*; $c++ ) {
            $count++ if $in->[$r][$c] eq '#';
            if ( $in->[$r][$c] ne $out->[$r][$c] ) {
                $diff++;
            }
        }
    }
    if ($diff) {
        return undef;
    }
    else {
        return $count;
    }
}
### CODE
my $Map;
my $state;
my $row = 0;
foreach (@file_contents) {
    my $line = [ split( //, $_ ) ];
    push @$Map,   $line;
    push @$state, $line;
}
my $maxcol = scalar $Map->[0]->@*;
say $maxcol;

for ( 1 .. 999 ) {

    my $newstate;
    for ( my $row = 0; $row < scalar @$Map; $row++ ) {
        for ( my $col = 0; $col < scalar $Map->[$row]->@*; $col++ ) {

            next unless $Map->[$row][$col] eq 'L';

            my $occupied = 0;
            for my $dir (
			 [ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
 			  [ 0, -1 ],          , [ 0, 1 ],
			  [ 1, -1 ], [ 1, 0 ] , [ 1, 1 ]
                )
            {
                my ( $r, $c ) = ( $row + $dir->[0], $col + $dir->[1] );
                next
                    if ( $r < 0
                    or $c < 0
                    or $r > scalar @$Map
			 or $c > $maxcol );
#		my $mapval = $Map->[$r]->[$c]?$Map->[$r]->[$c] : '/';
                if ( $Map->[$r]->[$c] eq 'L' and $state->[$r]->[$c] eq '#' ) {
                    $occupied++;
                }

            }
            if ( $state->[$row]->[$col] eq '#' and $occupied >= 4 ) {
                $newstate->[$row]->[$col] = 'X';
            }
            elsif (
                (      $state->[$row]->[$col] eq 'L'
                    or $state->[$row]->[$col] eq 'X'
                )
                and $occupied == 0
                )
            {
                $newstate->[$row]->[$col] = '#';
            }
            else {
                $newstate->[$row]->[$col] = $state->[$row]->[$col];
            }

        }
    }
    say $_;

    my $same = compare_states( $state, $newstate );
    if ($same) {
	is( $same, 2093 , "Part 1: ".$same);
        last;
    }
    $state = clone $newstate;
}

say "Duration: ", tv_interval($start_time) * 1000, "ms";
