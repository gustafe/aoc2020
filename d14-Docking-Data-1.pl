#! /usr/bin/env perl
#! /usr/bin/env perl
# Advent of Code 2020 Day 14 - Docking Data - part 1
# Problem link: http://adventofcode.com/2020/day/14
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d14
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';
no warnings qw(portable);

# useful modules
use List::Util qw/sum all/;
use Test::More;
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

sub apply_mask {
    my ( $mask, $bitstring ) = @_;
    my @mask = split( //, $mask );
    my @bits = split( //, $bitstring );
    for ( my $i = 0; $i <= $#mask; $i++ ) {
        $bits[$i] = $mask[$i] unless $mask[$i] eq 'X';
    }
    return join( '', @bits );

}
### CODE
my $mask;
my $addr;
my $val;
my %memory;
foreach my $line (@file_contents) {

    if ( $line =~ m/^mask = ([01X]{36})$/ ) {
        $mask = $1;
        $addr = '';
        $val  = '';
    }
    elsif ( $line =~ m/mem\[(\d+)\] = (\d+)/ ) {
        $addr = $1;
        $val  = $2;
    }
    else {
        die "can't parse: $line !";
    }

    #    say "$mask $addr $val";
    if ( $addr and $val ) {
        my $new = apply_mask( $mask, sprintf( "%036b", $val ) );
        if ($debug) {
            say "addr: [$addr]";
            printf( "in   %036b %d\n", $val, $val );
            say "mask $mask";
            say "out  $new " . oct( '0b' . $new );
        }
        $memory{$addr} = oct( '0b' . $new );
    }
}
my $part1 = sum( values %memory );
is( $part1, 13865835758282, "Part 1: " . $part1 );
done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";
