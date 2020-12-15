#! /usr/bin/env perl
# Advent of Code 2020 Day 15 - Rambunctious Recitation - part 1
# Problem link: http://adventofcode.com/2020/day/15
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d15
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

### CODE
my $start_time = [gettimeofday];
my $testing    = 0;
my $debug      = 0;


my @results    = ( 870, 436, 1, 10, 27, 78, 438, 1836 );
my $limit      = 2020;

my $case       = 1;
while (<DATA>) {

    chomp;
    my @start = split( ',', $_ );
    my %history;
    my $lastnum;
    my $turn = 1;
    foreach my $num (@start) {
        push @{ $history{$num} }, $turn;
        $lastnum = $num;
        print "$lastnum ";
        $turn++;
    }
    print ": ";
TURNS:
    while ( $turn <= $limit ) { 
        say "==> $turn " if $turn % 500_000 == 0;
        if ( exists $history{$lastnum}
            and scalar $history{$lastnum}->@* == 1 )
        {
            push $history{0}->@*, $turn;
            $lastnum = 0;
        }
        elsif ( !exists $history{$lastnum} ) {
            push $history{$lastnum}->@*, $turn;
            shift $history{$lastnum}->@*;

        }
        else {
            $lastnum = $history{$lastnum}->[-1] - $history{$lastnum}->[-2];
            push @{ $history{$lastnum} }, $turn;
        }
        if ( $turn == $limit ) {
            my $res = $lastnum;
            is( $res, $results[$case-1], "Case $case: $res" );
            last TURNS;
        }
        if ($debug) {

            foreach my $k ( sort { $a <=> $b } keys %history ) {
                print "$turn ==> $k [ ";
                say join( ' ', map { $_ ? $_ : '_' } @{ $history{$k} }, ']' );

            }
        }
        $turn++;
    }
    $case++;
}

done_testing();

say "Duration: ", tv_interval($start_time) * 1000, "ms";
__DATA__
11,0,1,10,5,19
0,3,6
1,3,2
2,1,3
1,2,3
2,3,1
3,2,1
3,1,2
