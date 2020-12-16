#! /usr/bin/env perl
# Advent of Code 2020 Day 16 - Ticket Translation - complete solution
# Problem link: http://adventofcode.com/2020/day/16
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d16
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum any/;
use Data::Dumper;
use Test::More;
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
    if ($line =~ m/^(.*): (\d+)-(\d+) or (\d+)-(\d+)$/) {
	$rules{$1}={r1=>{min=>$2,max=>$3},r2=>{min=>$4,max=>$5}};
	
    } elsif ($line =~ m/^\d+,.*,\d+$/) {
	push @tickets, $line
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
is ( $invalid_sums,21996 ,"Part 1: ".$invalid_sums);

# part 2
my %hits;
#my @rulecount = ();
my @target = split(',',$target_ticket);
foreach (my $i =0; $i< scalar( @target); $i++) {
 #   say "==> $i";
    foreach my $rule (keys %rules) {
#	say "~~> $rule";
	my $validrule = 0;
	foreach my $ticket (@valids) {
	    my @fields = split(',',$ticket);
	    my $field = $fields[$i];
	    if (($field >= $rules{$rule}->{r1}->{min} and $field <= $rules{$rule}->{r1}->{max}) or ($field >= $rules{$rule}->{r2}->{min} and $field <= $rules{$rule}->{r2}->{max})) {
		$validrule++;
#		$hits[$i]->{$rule}++;
	    }
	}
	
	if ($validrule == scalar @valids) {
#	    say "$rule valid for all tickets - $validrule";
#	    $rulecount[$i]++;
	    $hits{$i}->{$rule}++;
	}
    }
}
my %solution;
# this part cribbed from 2018D16
while (keys %hits) {
    foreach my $field (keys %hits) {
	if (scalar keys %{$hits{$field}} == 1) {
	    my $rule = (keys %{$hits{$field}})[0];
#	    say ">> found lone rule '$rule' at field $field";
	    $solution{$field} = $rule;
	    delete $hits{$field};
	}



	while (my ( $k, $rule ) = each %solution) {
	    foreach my $v  (keys %{$hits{$field}}) {
		if ($v eq $rule) {
		    delete $hits{$field}->{$v};
		}
	    }
	}
	if (scalar keys %{$hits{$field}} == 0) {
	    delete $hits{$field};
	}
    }
}
#print Dumper \%solution;
my $part2 = 1;
foreach my $field (keys %solution) {
    if ($solution{$field} =~ m/^departure/) {
	$part2 *= $target[$field];
	
    }
}
is($part2, 650080463519,"Part 2: ".$part2);
  
done_testing();
	    
say "Duration: ", tv_interval($start_time) * 1000, "ms";

__END__
foreach my $id (sort {$a<=>$b} keys %no_hits) {
    say "$id: ", join(' ', map {$no_hits{$id}->[$_] ? $no_hits{$id}->[$_]: ' '}   (0..19));
}
my %map;
while (keys %no_hits) {
    foreach my $j (keys %no_hits) {
	my $col;
	if (scalar keys $no_hits{$j} == 1 ) {
	    $col = (keys $no_hits{$j})[0];
	    say "column $col mapped to field $j";
	    $map{$j} = $col;
	    delete $no_hits{$j}->{$col};
	    delete $no_hits{$j};
	}
    }
}

my %no_hits;
my @hits;
foreach  (@valids) {

    my @ticket = split ',';
    my $matrix;
    # for each field, check if the number is valid
    for (my $i = 0 ; $i<= $#ticket; $i++) {
	for (my $j = 0; $j<=$#fields;$j++) {
	    my ($r1, $r2 ) = ($fields[$j]->[1]->{1}, $fields[$j]->[1]->{2});
	    if ($ticket[$i] >= $r1->{min} and $ticket[$i] <= $r1->{max}) {
		push @{$matrix->[$i]->[$j]}, 1;
		$hits[$j]->[$i]++;
	    }
	    if ($ticket[$i] >= $r2->{min} and $ticket[$i] <= $r2->{max}) {
		push @{$matrix->[$i]->[$j]}, 2;
		$hits[$j]->[$i]++;
	    }
	    
	}
	
    }
 #   say map {sprintf("%3d ", $_)} @ticket; 

    foreach my $j (0..$#fields) {
	#	printf("%d ",$j);
	foreach my $i (0..$#ticket) {
	    if (!defined $matrix->[$i]->[$j]) {
#		printf "%3s ",'X';
		#say join(' ', ($i, $fields[$j]->[0]));
		$no_hits{$j}->{$i}++;
#		say "$i $ticket[$i] $j ".$fields[$j]->[0];
	    } else {
#		printf("%3d ", join(' ',@{$matrix->[$i]->[$j]}));
	    }


	}
#	    print "\n";	
    }
    
}

#print Dumper \%no_hits;
my %map;
while (keys %no_hits) {
    foreach my $field ( keys %no_hits) {
	if (scalar keys %{$no_hits{$field}}==1) {
	    my $col = (keys %{$no_hits{$field}})[0];
	    say ">> field $field mapped to column $col";
	    $map{$field}= $col;
	    delete $no_hits{$field};
	}
	while (my ( $k, $i ) = each %map ) {
	    foreach my $v (keys %{$no_hits{$field}}) {
		if ($v == $i ) {
		    delete $no_hits{$field}->{$v}
		}
	    }
	}
	if (scalar keys %{$no_hits{$field}}==0) {
	    delete $no_hits{$field}
	}
    }
}
my @target = split(',', $target_ticket);
my $part2 = 1;
foreach my $idx (0..$#fields) {
    if ($fields[$idx]->[0] =~ m/^departure/) {
	say $fields[$idx]->[0], ' ', $idx, ' ', $map{$idx}, ' ', $target[$map{$idx}];
	$part2 *= $target[$map{$idx}];
	
    }
}
say $part2;
