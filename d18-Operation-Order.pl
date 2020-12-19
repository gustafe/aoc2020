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
my $part2 = shift // 0;
my @file_contents;
my $file = 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
# shunting yard algo adapted from http://www.rosettacode.org/wiki/Parsing/Shunting-yard_algorithm#Perl

my %prec = ( '*' => 2, '+' => 2, '(' => 1 );
if ($part2) {
    $prec{'+'} = 3;
}
my %assoc = ( '*' => 'left', '+' => 'left' );

sub shunting_yard {
    my @inp = split( //, $_[0] );
    my @ops;
    my @res;
    my $shift  = sub { push @ops, @_ };
    my $reduce = sub { push @res, @_ };

    while (@inp) {
        my $token = shift @inp;
        next if $token =~ /\s+/;
        if    ( $token =~ /\d+/ ) { $reduce->($token) }
        elsif ( $token eq '(' )   { $shift->($token) }
        elsif ( $token eq ')' ) {
            while ( @ops and "(" ne ( my $x = pop @ops ) ) { $reduce->($x) }

        }
        else {
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
    $reduce->( pop @ops ) while @ops;
    return join( ' ', @res );
}

# RPN solution from https://www.perlmonks.org/?node_id=520826
sub RPN {
    my ($in) = @_;
    my @stack;
    for my $tok ( split( ' ', $in ) ) {
        if ( $tok =~ /\d+/ ) {
            push @stack, $tok;
            next;
        }
        my $x = pop @stack;
        my $y = pop @stack;
        if ( $tok eq '+' ) {
            push @stack, $y + $x;
        }
        elsif ( $tok eq '*' ) {
            push @stack, $y * $x;
        }
        else {
            die "invalid token:\"$tok\"\n";
        }
    }
    @stack == 1 or die "invalid stack: [@stack]\n";
    return $stack[0];
}

foreach (<DATA>) {
    my ( $expr, $test1, $test2 ) = split ':';
    my $res = shunting_yard($expr);
    my $val = RPN($res);
    if ($part2) { ok( $val == $test2 ) }
    else { ok( $val == $test1 ) }
}

my $sum = 0;
foreach my $expr (@file_contents) {
    my $res = shunting_yard($expr);
    my $val = RPN($res);
    $sum += $val;
}
if ($part2) {
    is( $sum, 388966573054664, "Part2: " . $sum );
}
else {
    is( $sum,  18213007238947, "Part1: " . $sum );
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
