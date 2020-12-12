#! /usr/bin/env perl
# Advent of Code 2020 Day 12 - Rain Risk - part 2
# Problem link: http://adventofcode.com/2020/day/12
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d12
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Test::More tests => 1;
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
        push @instr, [ $1, $2 ];

    }
    else {
        die "can't parse: $_";
    }
}

my %move = (

    N => sub { my ( $d, $p ) = @_; $p->[0] += $d; return $p; },
    S => sub { my ( $d, $p ) = @_; $p->[0] -= $d; return $p; },
    E => sub { my ( $d, $p ) = @_; $p->[1] += $d; return $p; },
    W => sub { my ( $d, $p ) = @_; $p->[1] -= $d; return $p; },

);
my %rotate = (

	      # these rules are essentially from
	      # https://askinglot.com/what-is-the-rule-for-rotating-90-degrees-counterclockwise,
	      # but I had to tweak them to get the correct values
	      
    L => sub {
        my ( $th, $p ) = @_;
        if    ( $th ==  90 ) { return [  $p->[1], -$p->[0] ] }
        elsif ( $th == 180 ) { return [ -$p->[0], -$p->[1] ] }
        else                 { return [ -$p->[1],  $p->[0] ] }
    },

    R => sub {
        my ( $th, $p ) = @_;
        if ( $th ==    270 ) { return [  $p->[1], -$p->[0] ] }
        elsif ( $th == 180 ) { return [ -$p->[0], -$p->[1] ] }
        else                 { return [ -$p->[1],  $p->[0] ] }

    },
);

my $ship = [ 0, 0 ];
my $wp   = [ 1, 10 ];
foreach my $ins (@instr) {

    if ( $ins->[0] eq 'F' ) {
#	@$ship = map { $_ * $ins->[1] } @$wp;
        $ship->[0] += $wp->[0] * $ins->[1];
        $ship->[1] += $wp->[1] * $ins->[1];
    }
    elsif ( $ins->[0] eq 'L' or $ins->[0] eq 'R' ) {
        $wp = $rotate{ $ins->[0] }->( $ins->[1], $wp );
    }
    else {
        $wp = $move{ $ins->[0] }->( $ins->[1], $wp );
    }

}
my $part2 = sum( map { abs($_) } @{$ship} );
is( $part2, 54404, "Part 2: " . $part2 );
say "Duration: ", tv_interval($start_time) * 1000, "ms";
