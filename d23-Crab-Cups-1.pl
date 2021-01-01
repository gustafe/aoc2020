#! /usr/bin/env perl
# Advent of Code 2020 Day 23 - Crab Cups - part 1
# Problem link: http://adventofcode.com/2020/day/23
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d23
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::AllUtils qw/sum max min first_index/;
use Data::Dump qw/dump/;
use Test::More tests => 1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $debug   = 0;
my $testing = 0;
my @file_contents;

my $input = $testing ? '389125467' : '942387615';

### CODE
my @cups = split( //, $input );
my ( $minlabel, $maxlabel ) = ( min(@cups), max(@cups) );
my $no_of_cups = scalar @cups;
my $round      = 0;
my $currpos    = 0;
my $currlabel  = $cups[$currpos];
my ( $destlabel, $destpos ) = ( '', 0 );

while ( $round < 100 ) {
    if ($debug) {
        say "-- round $round --";
        say '    ' . join( ' ', ( 0 .. $#cups ) );
        say "L=> " . join( ',', @cups );

    }

    my @pickup;
    my %seen;
    for ( 1, 2, 3 ) {
        my $target = ( $currpos + 1 );
        if ( $target > $#cups ) {
            $target = 0;
        }
        my $val = splice( @cups, $target, 1 );
        push @pickup, $val;
        $seen{$val}++;
    }
    say "P=> " . join( ',', @pickup ) if $debug;

    $destlabel = $currlabel - 1;
    if ( $destlabel < $minlabel ) {
        $destlabel = $maxlabel;
    }
    while ( exists $seen{$destlabel} ) {
        $destlabel--;
        if ( $destlabel < $minlabel ) {
            $destlabel = $maxlabel;
        }
    }
    $currpos   = ( $currpos + 1 ) % $no_of_cups;
    $currlabel = $cups[$currpos];
    if ( !defined $currlabel ) {
        $currlabel = $cups[0];
    }

    say "    currpos: $currpos currlabel: $currlabel destlabel: $destlabel"
        if $debug;

    $destpos = first_index { $_ == $destlabel } @cups;
    say "    destlabel: $destlabel destpos: $destpos" if $debug;
    for ( 1, 2, 3 ) {
        my $target = ( $destpos + 1 ) % $no_of_cups;
        my $val    = pop @pickup;
        splice( @cups, $target, 0, $val );
    }

    # adjust the array around the current position
    my $index = first_index { $_ == $currlabel } (@cups);
    say "    index: $index currpos: $currpos" if $debug;
    if ( $index > $currpos ) {

        while ( $index > $currpos ) {
            my $offset = shift @cups;
            push @cups, $offset;
            say "    " . join( ' ', @cups ) if $debug;
            $index = first_index { $_ == $currlabel } @cups;
        }
    }
    elsif ( $index < $currpos ) {
        while ( $index < $currpos ) {
            my $offset = pop @cups;
            unshift @cups, $offset;
            say "    " . join( ' ', @cups ) if $debug;
            $index = first_index { $_ == $currlabel } @cups;
        }
    }
    say "R=> " . join( ',', @cups ) if $debug;
    $round++;

}
my $ptr = first_index { $_ == 1 } @cups;
$ptr++;
my $count = 0;
my $res   = '';
while ( $count < $#cups ) {
    $res .= $cups[$ptr];
    $ptr = ( $ptr + 1 ) % $no_of_cups;
    $count++;
}
is( $res, 36542897, "Part 1: " . $res );
say "Duration: ", tv_interval($start_time) * 1000, "ms";
