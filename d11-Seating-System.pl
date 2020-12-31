#! /usr/bin/env perl
# Advent of Code 2020 Day 11 - Seating System - complete solution
# Problem link: http://adventofcode.com/2020/day/11
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d11
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use Test::More tests => 2;
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
my $maxrow = 0;
my $maxcol;
foreach my $line (@file_contents) {
    $maxcol = 0;
    foreach my $char ( split( //, $line ) ) {
        $Map->{$maxrow}{$maxcol}   = $char;
        $state->{$maxrow}{$maxcol} = $char;
        $maxcol++;
    }
    $maxrow++;
}
my $Neighbors;
for my $row ( 0 .. $maxrow - 1 ) {
    for my $col ( 0 .. $maxcol - 1 ) {

        # only consider points with chairs
        next unless $Map->{$row}{$col} eq 'L';
    DIRECTION:
        for my $dir ( [ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
		      [  0, -1 ],            [  0, 1 ],
		      [  1, -1 ], [  1, 0 ], [  1, 1 ] ) {
            my ( $r, $c ) = ( $row + $dir->[0], $col + $dir->[1] );
            my $layer = 1;
            next DIRECTION unless defined $Map->{$r}{$c};
            while ( defined $Map->{$r}{$c} ) {
                if ( $Map->{$r}{$c} eq 'L' ) {
                    push @{ $Neighbors->{$row}{$col}{$layer} }, [ $r, $c ];
                    next DIRECTION;
                }
                $r += $dir->[0];
                $c += $dir->[1];
                $layer++;
            }

        }
    }
}


sub count_seated {
    my ($s) = @_;
    my $count = 0;
    foreach my $r ( keys %$s ) {
        foreach my $c ( keys %{ $s->{$r} } ) {
            $count++ if $s->{$r}{$c} eq '#';
        }
    }
    return $count;
}

# part 1

my $newstate;

for ( 1 .. 99 ) {
    my $diffs = 0;
    for ( my $row = 0; $row < $maxrow; $row++ ) {
        for ( my $col = 0; $col < $maxcol; $col++ ) {

            next unless $Map->{$row}{$col} eq 'L';
            my $occupied = 0;
            foreach my $pos ( @{ $Neighbors->{$row}{$col}{1} } ) {
                $occupied++ if $state->{ $pos->[0] }{ $pos->[1] } eq '#';
            }
            my $prev = $newstate->{$row}{$col} // '*';
            if ( $state->{$row}{$col} eq '#' and $occupied >= 4 ) {
                $newstate->{$row}{$col} = 'L';
            }
            elsif ( $state->{$row}{$col} eq 'L' and $occupied == 0 ) {
                $newstate->{$row}{$col} = '#';
            }
            else {
                $newstate->{$row}{$col} = $state->{$row}{$col};
            }
            $diffs++ unless $prev eq $newstate->{$row}{$col};

        }

    }
    if ( $diffs == 0 ) {
        my $solution = count_seated($state);
        is( $solution, 2093, "Part 1: " . $solution );
        last;
    }
    $state = clone $newstate;
}

# part 2
$state    = clone $Map;
$newstate = undef;

foreach ( 1 .. 99 ) {
    my $diffs = 0;
    for ( my $row = 0; $row < $maxrow; $row++ ) {
        for ( my $col = 0; $col < $maxcol; $col++ ) {
            next unless $Map->{$row}{$col} eq 'L';
            my $occupied = 0;
            foreach my $layer ( keys %{ $Neighbors->{$row}{$col} } ) {
                foreach my $pos ( @{ $Neighbors->{$row}{$col}{$layer} } ) {
                    $occupied++ if $state->{ $pos->[0] }{ $pos->[1] } eq '#';
                }
            }
            my $prev = $newstate->{$row}{$col} // '*';
            if ( $state->{$row}{$col} eq 'L' and $occupied == 0 ) {
                $newstate->{$row}{$col} = '#';
            }
            elsif ( $state->{$row}{$col} eq '#' and $occupied >= 5 ) {
                $newstate->{$row}{$col} = 'L';
            }
            else {
                $newstate->{$row}{$col} = $state->{$row}{$col};
            }
            $diffs++ unless $prev eq $newstate->{$row}{$col};
        }
    }
    if ( $diffs == 0 ) {
        my $solution = count_seated($state);
        is( $solution, 1862, "Part 2: " . $solution );
        last;

    }
    $state = clone $newstate;

}
say "Duration: ", tv_interval($start_time) * 1000, "ms";
