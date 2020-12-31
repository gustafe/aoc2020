#! /usr/bin/env perl
# Advent of Code 2020 Day 4 - Passport Processing - complete solution
# Problem link: http://adventofcode.com/2020/day/4
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d04
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use Test::More tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'invalid.txt' : 'input.txt';
open( my $fh, '<', "$file" );
{
    # set the local IFS to an empty string to treat the input as paragraphs
    local $/ = "";
    while (<$fh>) {
        chomp;
        push @file_contents, $_;
    }
}
### CODE

my %rules = (
    byr => sub {
        return undef unless $_[0] =~ m/\d{4}/;
        return undef unless ( $_[0] >= 1920 and $_[0] <= 2002 );
    },
    iyr => sub {
        return undef unless $_[0] =~ m/\d{4}/;
        return undef unless ( $_[0] >= 2010 and $_[0] <= 2020 );
    },
    eyr => sub {
        return undef unless $_[0] =~ m/\d{4}/;
        return undef unless ( $_[0] >= 2020 and $_[0] <= 2030 );
    },
    hgt => sub {
        return undef unless $_[0] =~ m/(\d+)(..)/;
        if ( $2 eq 'cm' ) {
            return undef unless ( $1 >= 150 and $1 <= 193 );
        }
        elsif ( $2 eq 'in' ) {
            return undef unless ( $1 >= 59 and $1 <= 76 );
        }
        else {
            return undef;
        }

    },
    hcl => sub {
        return undef unless $_[0] =~ m/\#[0-9a-f]{6}/;

    },
    ecl => sub {
        return undef unless $_[0] =~ m/amb|blu|brn|gry|grn|hzl|oth/;

    },
    pid => sub {
        return undef unless $_[0] =~ m/^\d{9}$/;

    },
);

sub validate {

    my ($rec) = @_;

    foreach my $key ( keys %rules ) {
        return undef unless exists $rec->{$key};
        return undef unless ( $rules{$key}->( $rec->{$key} ) );
    }
    return 1;
}

sub dump_record {
    my ($rec) = @_;
    foreach my $key ( sort { $a cmp $b } keys %rules ) {
        print $key, ": ", $rec->{$key} // "n/a", ' ';
    }
    print "\n";
}

# massage data into a form we can use
my @records;
foreach (@file_contents) {
    my @r = split( /\n/, $_ );

    my %data;
    while (@r) {
        my $line = shift @r;
        my @c = split( /:| /, $line );
        while (@c) {
            my $key = shift @c;
            my $val = shift @c;
            $data{$key} = $val;
        }
    }

    push @records, \%data;
}

# count the valid passports!
my %valids = ( 1=> 0, 2=>0 );
foreach my $record (@records) {
    if ( scalar keys %{$record} == 8 ) {
        $valids{1}++;
    }
    elsif ( scalar keys %{$record} == 7 and !exists $record->{cid} ) {
        $valids{1}++;
    }
    if ( validate($record) ) {

        $valids{2}++;

    }

}
is( $valids{1}, 239, "Part1: $valids{1}" );
is( $valids{2}, 188, "Part2: $valids{2}" );

