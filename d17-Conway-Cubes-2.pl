#! /usr/bin/env perl
# Advent of Code 2020 Day 17 - Conway Cubes - part 2
# Problem link: http://adventofcode.com/2020/day/17
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d17
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More tests=>1;
use Clone 'clone';
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

sub dump_state {
    my ($st) = @_;
    my $sum = 0;
    for my $x ( keys %$st ) {
        for my $y ( keys $st->{$x}->%* ) {
            for my $z ( keys $st->{$x}{$y}->%* ) {
                for my $w ( keys $st->{$x}{$y}{$z}->%* ) {
                    $sum++
                        if ( exists $st->{$x}{$y}{$z}{$w}
                        and $st->{$x}{$y}{$z}{$w} eq '#' );
                }
            }
        }
    }
    return $sum;
}

my $state;

sub count_neighbors {
    no warnings 'uninitialized';
    my ( $x, $y, $z, $w ) = @_;

    #    say "==> $x,$y,$z:";
    my $count = 0;
    for my $dx ( $x - 1, $x, $x + 1 ) {
        for my $dy ( $y - 1, $y, $y + 1 ) {
            for my $dz ( $z - 1, $z, $z + 1 ) {
                for my $dw ( $w - 1, $w, $w + 1 ) {

                    next
                        if ($x == $dx
                        and $y == $dy
                        and $z == $dz
                        and $w == $dw );

                    if ( $state->{$dx}{$dy}{$dz}{$dw} eq '#' ) {

                        $count++;
                    }
                }
            }
        }
    }
    return $count;
}
my $y = 0;
foreach (@file_contents) {
    my $x = 0;
    foreach ( split( //, $_ ) ) {
        $state->{$x}{$y}{0}{0} = '#' if $_ eq '#';
        $x++;
    }
    $y++;
}
my $cycle = 1;

my $newstate = clone($state);

while ( $cycle <= 6 ) {
    print "Cycle $cycle ... ";
    my $cubes=0;
    for my $x ( keys %{$state} ) {
        for my $y ( keys $state->{$x}->%* ) {
            for my $z ( keys $state->{$x}{$y}->%* ) {
                for my $w ( keys $state->{$x}{$y}{$z}->%* ) {

                    # we now have an active cell, let's check its neighbors
                    for my $dx ( $x - 1, $x, $x + 1 ) {
                        for my $dy ( $y - 1, $y, $y + 1 ) {
                            for my $dz ( $z - 1, $z, $z + 1 ) {
                                for my $dw ( $w - 1, $w, $w + 1 ) {
				    $cubes++;
                                    no warnings 'uninitialized';
                                    my $n = count_neighbors( $dx, $dy, $dz,
                                        $dw );
                                    if ( $state->{$dx}{$dy}{$dz}{$dw} eq '#' )
                                    {
                                        if ( $n == 2 or $n == 3 ) {
                                            $newstate->{$dx}{$dy}{$dz}{$dw}
                                                = '#';
                                        }
                                        else {
                                            delete $newstate->{$dx}{$dy}{$dz}
                                                {$dw};
                                        }
                                    }
                                    else {
                                        if ( $n == 3 ) {
                                            $newstate->{$dx}{$dy}{$dz}{$dw}
                                                = '#';
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    say "$cubes cubes visited";
    $state = clone $newstate;
    $cycle++;
}

# count active
my $part2=  dump_state( $state );
is($part2,1392, "Part 2: ".$part2);
say "Duration: ", tv_interval($start_time) * 1000, "ms";

