#! /usr/bin/env perl
# Advent of Code 2020 Day 18 - Operator Order -  complete solution
# Problem link: http://adventofcode.com/2020/day/18
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d18
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $part2 = shift//0;
my @file_contents;
my $file = 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
# shunting yard algo adapted from http://www.rosettacode.org/wiki/Parsing/RPN_calculator_algorithm#Perl
my %prec = ( '*' => 2, '+'=>2, '(' => 1 );
if ($part2) {
    $prec{'+'} = 3
}
my %assoc =( '*' => 'left', '+' => 'left' );

sub shunting_yard {
    my @inp = split(//, $_[0]);
    my @ops;
    my @res;
    my $report = sub {printf("%25s    %-7s %10s %s\n", "@res", "@ops", $_[0], "@inp")};
    
    my $shift = sub { #$report->("shift @_");
		      push @ops, @_ };
    my $reduce = sub { #$report->("reduce @_");
		       push @res, @_ };

    while (@inp) {
	
	my $token = shift @inp;
	next if $token =~ /\s+/;
	if ($token =~ /\d+/ ) { $reduce->( $token )}
	elsif ($token eq '(' ) { $shift->( $token ) }
	elsif ($token eq ')' ) {
	    while (@ops and "(" ne ( my $x = pop @ops)) { $reduce->( $x )}

	} else {
	    my $newprec = $prec{$token};
	    while (@ops) {
		my $oldprec = $prec{ $ops[-1] };
		last if $newprec > $oldprec;
		last if $newprec == $oldprec and $assoc{$token} eq 'right';
		$reduce->( pop @ops );
	    }
	    $shift->($token);
	}
    }
    $reduce->(pop @ops) while @ops;
    return join(' ',@res);
}

# RPN parser from http://www.rosettacode.org/wiki/Parsing/RPN_calculator_algorithm#Perl
sub evaluate {
  (my $a = "($+{left})$+{op}($+{right})") =~ s/\^/**/;
#  say $a;
  eval $a;
}
sub RPN {
    my @input =  $_[0];
    my $number='[+-]?(?:\.\d+|\d+(?:\.\d*)?)';
    my $operator='[-+*/^]';
    for (@input) {
	while (
	       s/ \s* ((?<left>$number))     # 1st operand
           \s+ ((?<right>$number))    # 2nd operand
           \s+ ((?<op>$operator))     # operator
           (?:\s+|$)                  # more to parse, or done?
         /
           ' '.evaluate().' '         # substitute results of evaluation
	       /ex
	      ) {}
	return $_;
    }
}
foreach (<DATA>) {
    my ( $expr,$test1,$test2) = split ':';
    my $res = shunting_yard($expr);
    my $val = RPN( $res );
    if ($part2) {
	ok( $val==$test2)
    } else {
	ok($val==$test1)
    }
}

my $sum =0;
foreach my $expr (@file_contents) {
    my $res= shunting_yard($expr);
    #    say join(' ',$expr, '==>', $res);
    my $val =RPN($res);
#    say $val;
    $sum+=$val;
}
if ($part2) {
    is( $sum, 388966573054664,"Part2: " .$sum)
} else {
    is( $sum, 18213007238947,"Part1: " .$sum)
}

done_testing();
say "Duration: ", tv_interval($start_time) * 1000, "ms";

__DATA__
1 + 2 * 3 + 4 * 5 + 6:71:231
1 + (2 * 3) + (4 * (5 + 6)):51:51
2 * 3 + (4 * 5):26:46
5 + (8 * 3 + 9 + 3 * 4 * 3):437:1445
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)):12240:669060
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2:13632:23340
