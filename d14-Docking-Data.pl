#! /usr/bin/env perl
# Advent of Code 2020 Day 14 - Docking Data - complete solution
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

# solution for part 2 inspired by /u/Loonis (https://www.reddit.com/r/adventofcode/comments/kcr1ct/2020_day_14_solutions/gfseyzj/)

### SUBS
sub apply_mask_1 {
    my ( $mask, $bitstring ) = @_;
    my @mask = split( //, $mask );
    my @bits = split( //, $bitstring );
    for ( my $i = 0; $i <= $#mask; $i++ ) {
	# here we let the mask overwrite both 0 and 1, but ignore 'X'
        $bits[$i] = $mask[$i] unless $mask[$i] eq 'X';
    }
    return join( '', @bits );

}

sub apply_mask_2 {
    my ( $mask, $bitstring ) = @_;
    my @mask = split( //, $mask );
    my @bits = split( //, $bitstring );
    for ( my $i = 0; $i <= $#mask; $i++ ) {
	# this mask acts as an 'and' mask, but we need to take 'X' ("floating") into account
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
my %memory =(1=>undef,2=>undef);
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
	# part 1

	my $newval = apply_mask_1 ( $mask, sprintf( "%036b", $val ));
	$memory{1}->{$addr} = oct( '0b' . $newval );
	
	# part 2 
        # initiate the subsitution of the floating values by applying
        # the raw mask to the address

        my $new = apply_mask_2( $mask, sprintf( "%036b", $addr ) );

	# now we can generate all our masks
        my @masks = generate_mask($new);

        for my $m (@masks) {
            $memory{2}->{ oct( '0b' . $m ) } = $val;
        }
    }
}
my $part1 = sum( values %{$memory{1}} );
is( $part1, 13865835758282, "Part 1: " . $part1 );

my $part2 = sum( values %{$memory{2}} );
is( $part2, 4195339838136, "Part 2: " . $part2 );
done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";
