#! /usr/bin/env perl
# Advent of Code 2020 Day 10 - Adapter Array - complete solution
# Problem link: http://adventofcode.com/2020/day/10
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d10
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum max/;
use Data::Dumper;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [ gettimeofday ];

#### INIT - load input data from file into array
my $testing = shift//0;
my %adapters;
my $file = $testing ? 'test'.$testing.'.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) {
    chomp;
    s/\r//gm;
    $adapters{$_} = undef;
}

### CODE
my $device = max( keys %adapters) + 3;
$adapters{$device} = undef;
my $joltage = 0;
my $count = 0;
my %diffs = ();
while ($count< scalar keys %adapters) {
  STEPS:
    for my $step (1..3) {
	my $sought = $joltage + $step;
	if (exists $adapters{$sought}) {
	    $adapters{$sought} = $joltage;
	    $diffs{$step}++;
	    $joltage += $step;
	    last STEPS;
	}
    }
    $count++;
}
#print Dumper \%adapters;
say "Part 1: " ,$diffs{1}*$diffs{3};

# part 2
my @sequence = sort {$a<=>$b} keys %adapters;
unshift @sequence,0;

# build a graph
my @G;
for my $i (0..$#sequence) {
    $G[$i]->{v} = $sequence[$i];
    for my $step ($i+1..$i+3) {
	last unless defined $sequence[$step];
#	say $sequence[$step] - $sequence[$i];
	push @{$G[$i]->{e}}, $step if $sequence[$step] - $sequence[$i] <= 3;
    }
#    push @{$G[$i]->{e}}, $sequence[$i]+1 if exists $adapters{$sequence
}
# print Dumper \@G;
# my $line_no=0;
# foreach my $el (@G) {
# #    print Dumper $el;
#     say "$line_no vertix: ", $el->{v} , " edges: ", join(',', @{$el->{e}}) ;
#     $line_no++;
# }
 sub traverse {
    my $node = $G[$_[0]];
    my $count = 0;
    return 1 unless defined $node->{e};
    return $node->{m} if defined $node->{m};

    foreach my $idx (@{$node->{e}}) {
	$count += traverse( $idx )
    }
    $node->{m} =$count;
    return $count;
}
say "Part 2: ", traverse(0);
say "Duration: ", tv_interval($start_time) * 1000, "ms";
__END__
my @list = sort {$a<=>$b} keys %adapters;
my $first = shift @list;
my $next;
while (@list) {
    $next = shift @list;
    say "$next - $first = ",$next-$first;
    $first = $next;
}

for my $k (keys %adapters) { $adapters{$k} = undef }
my @stack = (0);
$count = 0;
while (@stack) {
    my $v = pop @stack;
#    say $v;
    $adapters{$v}++ unless defined $adapters{$v};
    for my $step (1..3) {
	if (exists $adapters{$v+$step}) {
	    push @stack, $v+$step
	}
	if ($v+$step == max keys %adapters) {
	    $count++;
	}
    }
}

say $count;

my @orig = sort {$a<=>$b} keys %adapters;
unshift @orig, 0;
push @orig, max(keys %adapters);
# split the original array
my @sequences;
my @diffs;
# https://www.reddit.com/user/phrodide - https://www.reddit.com/r/adventofcode/comments/ka9pc3/2020_day_10_part_2_suspicious_factorisation/gf94sxy/
my $pow7 =0;
my $pow2 =0;
for (my $i=0;$i<$#orig;$i++) {
    push @diffs, $orig[$i+1]-$orig[$i];
    my $neg3 = ( $i >= 3 ) ? $orig[$i-3]:-9999;
    if ($orig[$i+1] - $neg3 == 4) {
	$pow7 += 1;
	$pow2 -= 2;
    } elsif ($orig[$i+1]-$orig[$i-1]==2) {
	$pow2 +=1;
    }
      
}
say "pow2: $pow2, pow7: $pow7";
say 2**$pow2 * 7**$pow7;
say join(' ', @diffs);

