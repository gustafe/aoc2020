#! /usr/bin/env perl
# Advent of Code 2020 Day 8 - Handheld Halting - complete solution

    # Problem link: http://adventofcode.com/2020/day/8
    #   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d08
    #      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
    use Modern::Perl '2015';

# useful modules
use Test::More tests => 2;
use Clone qw/clone/;
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my @original;
my %ops;
my $line_no = 0;
foreach (@file_contents) {
    my ( $op, $val ) = split ' ', $_;

    # gather the line numbers of all operations
    push @{ $ops{$op} }, $line_no;

    push @original, [ $op, $val ];
    $line_no++;
}

my %parts = ( 1=>undef , 2=>undef );
# part 1
my $ret = run_program( \@original );
if (defined $ret->[0]) {
    die "this shouldn't be possible here!"
} else {
    $parts{1} = $ret->[1];

}

# part 2
# start with jmp->nop as that's the largest set

foreach my $line_no (@{$ops{'jmp'}}) {
    # we need to use Clone::clone here because just assigning will
    # modify the original
    my $code = clone(\@original);
    # sanity check
    if ($original[$line_no]->[0] eq 'jmp') {
	$code->[$line_no]->[0] = 'nop'
    }
    my $ret = run_program($code);
    if (defined $ret->[0]) {
	$parts{2} = $ret->[1];
	last;
    }
}

is($parts{1}, 1200, "Part1: ".$parts{1});
is($parts{2}, 1023, "Part2: ".$parts{2});

sub run_program {
    my ($program) = @_;

    my %seen  = ();
    my $accum = 0;
    my $pos   = 0;
    while ( $pos < $line_no ) {
        my ( $op, $val ) = @{ $program->[$pos] };
        if ( $op eq 'acc' ) {
            $accum += $val;
            $pos++;
        }
        elsif ( $op eq 'jmp' ) {
            $pos += $val;
        }
        elsif ( $op eq 'nop' ) {
            $pos++;
        }
        if ( $seen{$pos} ) {
            return [ undef, $accum ];
        }
        else {
            $seen{$pos}++;
        }

    }
    return [ $pos, $accum ];
}
