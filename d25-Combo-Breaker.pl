#! /usr/bin/env perl
# Advent of Code 2020 Day 25 - Combo Breaker - complete solution
# Problem link: http://adventofcode.com/2020/day/25
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d25
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More tests => 1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my ( $cardkey, $doorkey ) = @file_contents;
my ( $cardval, $doorval ) = ( 1, 1 );
my $subject_nr = 7;
my ( $cardloop, $doorloop ) = ( undef, undef );
my $loop = 1;
while ( !$cardloop and !$doorloop ) {
    if ( !$cardloop ) {
        $cardval = $cardval * $subject_nr;
        $cardval = $cardval % 20201227;

        if ( $cardval == $cardkey ) {
            $cardloop = $loop;
        }
    }
    if ( !$doorloop ) {
        $doorval = $doorval * $subject_nr;
        $doorval = $doorval % 20201227;
        if ( $doorval == $doorkey ) {
            $doorloop = $loop;
        }
    }
    $loop++;
}

$loop       = 1;
$subject_nr = $doorkey;
$cardval    = 1;
while ( $loop <= $cardloop ) {
    $cardval = $cardval * $subject_nr;
    $cardval = $cardval % 20201227;
    $loop++;
}
is( $cardval, 290487, "Answer is: " . $cardval );
done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";
