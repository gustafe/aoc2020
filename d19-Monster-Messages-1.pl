#! /usr/bin/env perl
# Advent of Code 2020 Day 19 - Monster Messages - part 1
# Problem link: http://adventofcode.com/2020/day/19
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d19
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More tests => 1;
use Time::HiRes qw/gettimeofday tv_interval/;
use Parse::RecDescent;
my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my %rules;
my @messages;
foreach (@file_contents) {
    if (m/(\d+): (.*)/) {
        $rules{$1} = $2;
    }
    elsif (m/^[a|b]/) {
        push @messages, $_;
    }
}
say "messages: ", scalar @messages;
my $grammar = "startrule: r0\n";
foreach my $rule ( sort { $a <=> $b } keys %rules ) {

    # ensure only matches once
    my ($subrules) = $rules{$rule} =~ s/(\d+)/r$1\(1\)/g;
    $grammar .= 'r' . "$rule: $rules{$rule}\n";
}
say $grammar;

my $parser = new Parse::RecDescent($grammar) or die "bad grammar!\n";

# kludge to avoid excessive matches
my $maxlen = length('abbbaabbababbaaabaaaaaba');
my $count  = 0;
my @matches;
foreach my $msg (@messages) {
    if ( defined $parser->startrule($msg) ) {
        next if length($msg) > $maxlen;
        $count++;
        push @matches, $msg;
    }
}
say $count;
say "Duration: ", tv_interval($start_time) * 1000, "ms";
