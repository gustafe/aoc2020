#! /usr/bin/env perl
# Advent of Code 2020 Day 16 - Ticket Translation - complete solution
# Problem link: http://adventofcode.com/2020/day/16
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d16
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/any/;
use Test::More tests => 2;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my %rules;
my @tickets;
my @valids;
foreach my $line (@file_contents) {
    if ( $line =~ m/^(.*): (\d+)-(\d+) or (\d+)-(\d+)$/ ) {
        $rules{$1} = {
            r1 => { min => $2, max => $3 },
            r2 => { min => $4, max => $5 }
        };

    }
    elsif ( $line =~ m/^\d+,.*,\d+$/ ) {
        push @tickets, $line;
    }
}
my $target_ticket = shift @tickets;

my $invalid_sums = 0;
foreach (@tickets) {

    my @vals = split( ',', $_ );
    my $invalids = 0;
    my @oks;
    my $val_id = 0;
    foreach my $v (@vals) {
        my $field_row = 0;
        foreach my $rule ( keys %rules ) {
            if ((       $v >= $rules{$rule}->{r1}->{min}
                    and $v <= $rules{$rule}->{r1}->{max}
                )
                or (    $v >= $rules{$rule}->{r2}->{min}
                    and $v <= $rules{$rule}->{r2}->{max} )
                )
            {

                $oks[$field_row] = 1;

            }
            else {
                $oks[$field_row] = 0;

            }
            $field_row++;
        }
        if ( any { $_ == 1 } @oks ) {

            # valid

        }
        else {
            $invalid_sums += $v;
            $invalids++;
        }
        $val_id++;
    }

    push @valids, $_ unless $invalids++;

}
is( $invalid_sums, 21996, "Part 1: " . $invalid_sums );

# part 2
my %hits;

my @target = split( ',', $target_ticket );
foreach ( my $i = 0; $i < scalar(@target); $i++ ) {

    foreach my $rule ( keys %rules ) {

        my $validrule = 0;
        foreach my $ticket (@valids) {
            my @fields = split( ',', $ticket );
            my $field = $fields[$i];
            if ((       $field >= $rules{$rule}->{r1}->{min}
                    and $field <= $rules{$rule}->{r1}->{max}
                )
                or (    $field >= $rules{$rule}->{r2}->{min}
                    and $field <= $rules{$rule}->{r2}->{max} )
                ) { $validrule++; }
        }

        if ( $validrule == scalar @valids ) {
            $hits{$i}->{$rule}++;
        }
    }
}
my %solution;

# this part cribbed from 2018D16
while ( keys %hits ) {
    foreach my $field ( keys %hits ) {
        if ( scalar keys %{ $hits{$field} } == 1 ) {
            my $rule = ( keys %{ $hits{$field} } )[0];
            $solution{$field} = $rule;
            delete $hits{$field};
        }

        while ( my ( $k, $rule ) = each %solution ) {
            foreach my $v ( keys %{ $hits{$field} } ) {
                if ( $v eq $rule ) {
                    delete $hits{$field}->{$v};
                }
            }
        }
        if ( scalar keys %{ $hits{$field} } == 0 ) {
            delete $hits{$field};
        }
    }
}

my $part2 = 1;
foreach my $field ( keys %solution ) {
    if ( $solution{$field} =~ m/^departure/ ) {
        $part2 *= $target[$field];

    }
}
is( $part2, 650080463519, "Part 2: " . $part2 );
say "Duration: ", tv_interval($start_time) * 1000, "ms";

