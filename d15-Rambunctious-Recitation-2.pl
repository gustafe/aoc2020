#! /usr/bin/env perl
# Advent of Code 2020 Day 15 - Rambunctious Recitation - part 2
# Problem link: http://adventofcode.com/2020/day/15
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d15
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
### CODE
# solution cribbed from /u/musifter, https://www.reddit.com/r/adventofcode/comments/kdf85p/2020_day_15_solutions/gfwky22/
my @results = ( 9136, 175594, 2578, 3544142, 261214, 6895259, 18, 362 );
my $limit   = 30_000_000;
my $case    = 0;

while (<DATA>) {

    #    next if $case>0;
    chomp;

    my @list = split( ',', $_ );
    my @history;

    foreach my $t ( 0 .. $#list - 1 ) {
        $history[ $list[$t] ] = $t + 1;
    }
    my ( $next, $curr ) = ( $list[-1], 0 );
    foreach my $t ( $#list + 1 .. $limit - 1 ) {
        $curr = $next;
        $next = ( defined $history[$curr] ) ? $t - $history[$curr] : 0;
        $history[$curr] = $t;

    }
    is( $next, $results[$case], "Case $case: $next" );

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
