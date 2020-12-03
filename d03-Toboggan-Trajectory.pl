#! /usr/bin/env perl
use Modern::Perl '2015';
# useful modules
use Test::More tests=>2;
#### INIT - load input data from file into array
my $testing = 0;
my $Map;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @{$Map}, $_; }

### CODE
my $maxcol = scalar(split(//,$Map->[0]));
my @res;
# coordinates: (row, column);
foreach my $move ([1,3],[1,1],[1,5],[1,7],[2,1]) {

my @pos = (0,0);

my $hits = 0;
while ($pos[0]<scalar @{$Map}) {
    $pos[0] += $move->[0];
    $pos[1] = ($pos[1] + $move->[1]) % $maxcol;
    # check for tree

    my @treeline = split(//, $Map->[$pos[0]]);
    if ($treeline[$pos[1]] eq '#') {
	$hits++
    }
			 
    
}

push @res, $hits;
}
is($res[0], 223, "Part 1: $res[0]");
my $ans=1;
foreach my $el (@res) {
    $ans *= $el;
}
is( $ans, 3517401300, "Part 2: $ans");
