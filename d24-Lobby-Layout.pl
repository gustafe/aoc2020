#! /usr/bin/env perl
# Advent of Code 2020 Day 24 - Lobby Layout - complete solution
# Problem link: http://adventofcode.com/2020/day/24
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d24
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Clone qw/clone/;
use Test::More tests => 2;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }
### SUBS

my $Map;
my $newMap;

# x,y,z coordinates - see https://www.redblobgames.com/grids/hexagons/
# these hexes are "pointy", the flat sides are E and W
my %move = (
    e  => sub { [  1, -1,  0 ] },
    ne => sub { [  1,  0, -1 ] },
    se => sub { [  0, -1,  1 ] },
    w  => sub { [ -1,  1,  0 ] },
    sw => sub { [ -1,  0,  1 ] },
    nw => sub { [  0,  1, -1 ] },
);

sub count_map {
    my ($M) = @_;
    my $count = 0;
    for my $x ( keys %{$M} ) {
        for my $y ( keys %{ $M->{$x} } ) {
            for my $z ( keys %{ $M->{$x}->{$y} } ) {
                say "[$x,$y,$z] ", $M->{$x}{$y}{$z} if $debug;
                $count++ if $M->{$x}{$y}{$z} == 1;
            }
        }
    }
    return $count;
}

sub count_neighbors {
    my ( $x, $y, $z ) = @_;

    #    my $p = [$x,$y,$z];
    my $res;
    foreach my $d (qw/e w ne nw se sw/) {
        my $m = $move{$d}->();
        if ( !exists $Map->{ $x + $m->[0] }{ $y + $m->[1] }{ $z + $m->[2] } )
        {    # implicit white
            $res->{white}++;
        }
        elsif ( $Map->{ $x + $m->[0] }{ $y + $m->[1] }{ $z + $m->[2] } == 0 )
        {    # explicit white
            $res->{white}++;
        }
        elsif ( $Map->{ $x + $m->[0] }{ $y + $m->[1] }{ $z + $m->[2] } == 1 )
        {    # explicit black
            $res->{black}++;
        }
        else {    # wut
            die "can't read value at position ["
                . join( ',', $x + $m->[0], $y + $m->[1], $z + $m->[2] )
                . "]\n";
        }
    }
    return $res;
}

### CODE
foreach my $line (@file_contents) {

    #    say $line;
    my @dirs = $line =~ m/(e|w|ne|nw|se|sw)/g;
    my $pos = [ 0, 0, 0 ];
    foreach my $d (@dirs) {
        my $move = $move{$d}->();
        map { $pos->[$_] += $move->[$_] } ( 0 .. 2 );
    }
    if ( !exists $Map->{ $pos->[0] }{ $pos->[1] }{ $pos->[2] } )
    {    # never visited
        $Map->{ $pos->[0] }{ $pos->[1] }{ $pos->[2] } = 1;    # turn black
    }
    elsif ( $Map->{ $pos->[0] }{ $pos->[1] }{ $pos->[2] } == 1 )
    {                                                         # visited, black
        $Map->{ $pos->[0] }{ $pos->[1] }{ $pos->[2] } = 0;    # turn white
    }
    else {                                                    # visited, white
        $Map->{ $pos->[0] }{ $pos->[1] }{ $pos->[2] } = 1     # turn black
    }
}

my $count = count_map($Map);
is( $count, 307, "Part 1: " . $count );

# part 2

$newMap = clone($Map);

#say dump $Map;
my $day = 0;
while ( $day < 100 ) {
    printf( "day %2d: %4d\n", $day, count_map($Map) ) if $day % 10 == 0;
    for my $x ( keys %{$Map} ) {
        for my $y ( keys %{ $Map->{$x} } ) {
            for my $z ( keys %{ $Map->{$x}{$y} } ) {

                # cycle thru current position and neighbors
                no warnings 'uninitialized';
                my @points = ( [ $x, $y, $z ] );

                foreach my $d (qw/e w ne nw se sw/) {
                    my $point = [ $x, $y, $z ];
                    my $m = $move{$d}->();
                    map { $point->[$_] += $m->[$_] } ( 0 .. 2 );
                    push @points, $point;
                }
                foreach my $p (@points) {
                    my $r = count_neighbors(@$p);

                    if ( !defined $Map->{ $p->[0] }{ $p->[1] }{ $p->[2] }
                        or $Map->{ $p->[0] }{ $p->[1] }{ $p->[2] } == 0 )
                    {
                        if ( $r->{black} == 2 ) {
                            $newMap->{ $p->[0] }{ $p->[1] }{ $p->[2] } = 1;
                        }
                        else {
			    # this is a white tile, we don't need to keep it
                            delete $newMap->{ $p->[0] }{ $p->[1] }{ $p->[2] };
                        }
                    }
                    elsif ( $Map->{ $p->[0] }{ $p->[1] }{ $p->[2] } == 1 ) {
                        if ( $r->{black} == 0 or $r->{black} > 2 ) {
			    # turn white -> remove from the set of tiles
                            delete $newMap->{ $p->[0] }{ $p->[1] }{ $p->[2] };
                        }
                    }
                }
            }
        }
    }
    $Map = clone($newMap);

    $day++;
}
my $part2 = count_map($Map);
is( $part2, 3787, "Part 2: " . $part2 );
say "Duration: ", tv_interval($start_time) * 1000, "ms";
