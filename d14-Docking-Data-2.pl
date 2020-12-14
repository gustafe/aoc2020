#! /usr/bin/env perl
# Advent of Code 2020 Day 14 - Docking Data - part 2
# Problem link: http://adventofcode.com/2020/day/14
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d14
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';
no warnings qw(portable);

# useful modules
use List::AllUtils qw/sum all first_index/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

# solution inspired by /u/Loonis (https://www.reddit.com/r/adventofcode/comments/kcr1ct/2020_day_14_solutions/gfseyzj/)

### SUBS

sub apply_mask {
    my ( $mask, $bitstring ) = @_;
    my @mask = split( //, $mask );
    my @bits = split( //, $bitstring );
    for ( my $i = 0; $i <= $#mask; $i++ ) {
        $bits[$i] = $mask[$i] if $mask[$i] =~ /(1|X)/;
    }
    return join( '', @bits );

}

sub generate_mask {
    my ($str) = @_;
    my @list    = split( //, $str );
    my @result  = ();
    my $first_X = first_index { $_ eq 'X' } @list;
    if ( $first_X >= 0 ) {

        $list[$first_X] = 0;
        push @result, generate_mask( join( '', @list ) );
        $list[$first_X] = 1;
        push @result, generate_mask( join( '', @list ) );
    }
    else {
        push @result, $str;
    }
    return @result;
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

    if ( $addr and $val ) {

        # initiate the subsitution of the floating values by applying
        # the raw mask to the address

        my $new = apply_mask( $mask, sprintf( "%036b", $addr ) );

        my @masks = generate_mask($new);
        for my $m (@masks) {
            $memory{ oct( '0b' . $m ) } = $val;
        }
    }
}
my $part2 = sum( values %memory );
is( $part2, 4195339838136, "Part 2: " . $part2 );
done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";
