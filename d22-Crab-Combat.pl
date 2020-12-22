#! /usr/bin/env perl
# Advent of Code 2020 Day 22 - Crab Combat -  complete solution
# Problem link: http://adventofcode.com/2020/day/22
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d22
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/max/;
use Test::More tests => 2;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $game_no = 0;
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
{
    local $/ = '';
    while (<$fh>) {
        chomp;
        push @file_contents, $_;
    }
}
### SUBS

sub score {
    my ($d) = @_;
    return 0 unless @$d;
    my $score  = 0;
    my $factor = 1;
    while (@$d) {
        $score += $factor * pop @$d;
        $factor++;
    }
    return $score;
}

sub make_state {
    my ( $d0, $d1 ) = @_;
    return join( ',', @$d0 ) . ':' . join( ',', @$d1 );
}

# this code courtesy of /u/musifter at https://www.reddit.com/r/adventofcode/comments/khyjgv/2020_day_22_solutions/ggo7v7a/
sub recurse_game {
    my ( $depth, $d0, $d1 ) = @_;
    my %states;
    $game_no++;
    print "Starting game $game_no at depth $depth\r"
        if ( $game_no % 100 == 0 );

    while ( @$d0 and @$d1 ) {
        my $curr_state = make_state( $d0, $d1 );
        if ( exists $states{$curr_state} ) {
            return ( ( $depth > 0 ) ? 0 : score(@$d0) );
        }
        $states{$curr_state}++;

        my $c0 = shift @$d0;
        my $c1 = shift @$d1;

        my $winner;
        if ( ( $c0 <= scalar @$d0 ) and $c1 <= scalar @$d1 ) {
            my $new_d0 = [ map { $d0->[$_] } ( 0 .. $c0 - 1 ) ];
            my $new_d1 = [ map { $d1->[$_] } ( 0 .. $c1 - 1 ) ];
            $winner = recurse_game( $depth + 1, $new_d0, $new_d1 );
        }
        elsif ( $c0 > $c1 ) {
            $winner = 0;
        }
        else {
            $winner = 1;
        }
        if ( $winner == 0 ) {
            push @$d0, ( $c0, $c1 );
        }
        else {
            push @$d1, ( $c1, $c0 );
        }
    }
    if ( $depth > 0 ) {
        return ( @$d0 ? 0 : 1 );
    }
    else {
        return max( score( $d0, $d1 ) );
    }

}

### CODE
# part 1
my @decks;
foreach (@file_contents) {
    my @data = split( "\n", $_ );
    shift @data;
    push @decks, [@data];
}

foreach (@decks) {
    say join( ',', map { sprintf( "%2d", $_ ) } ( $_->@* ) );
}
while ( $decks[0]->@* and $decks[1]->@* ) {
    my $c0 = shift $decks[0]->@*;
    my $c1 = shift $decks[1]->@*;

    if ( $c0 > $c1 ) {
        push $decks[0]->@*, ( $c0, $c1 );
    }
    else {
        push $decks[1]->@*, ( $c1, $c0 );
    }
}
my $part1 = max( map { score($_) } @decks );
is( $part1, 33561, "Part 1: " . $part1 );

# part2
# reload decks
@decks = ();
foreach (@file_contents) {
    my @data = split( "\n", $_ );
    shift @data;
    push @decks, [@data];
}
my $part2 = recurse_game( 0, $decks[0], $decks[1] );
print "\n";
is( $part2, 34594, "Part 2: " . $part2 );

say "Duration: ", tv_interval($start_time) * 1000, "ms";
