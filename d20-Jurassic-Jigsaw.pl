#! /usr/bin/env perl
# Advent of Code 2020 Day 20 - Jurassic Jigsaw - complete solution
# Problem link: http://adventofcode.com/2020/day/20
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2020.html#d20
#      License: http://gerikson.com/files/AoC2020/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dump qw/dump/;
use Test::More tests=>2;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
{
    local $/ = '';
    while (<$fh>) {
        chomp;
        push @file_contents, $_;
    }
}
### SUBS
sub transpose {    # https://perlmaven.com/transpose-a-matrix
    my ($M) = @_;
    my $T;
    for my $r ( 0 .. scalar @$M - 1 ) {
        for my $c ( 0 .. scalar @{ $M->[$r] } - 1 ) {
            $T->[$c][$r] = $M->[$r][$c];
        }
    }
    return $T;
}

sub rotate90 {     # https://stackoverflow.com/a/8664879
    my ($M) = @_;
    my $T = transpose($M);
    my $R;
    for my $r ( 0 .. scalar @$T - 1 ) {
        push @$R, [ reverse @{ $T->[$r] } ];
    }
    return $R;
}

sub flipH {        # flip around horisontal axis, up <-> down
    my ($M) = @_;
    my $F;
    my $maxr = scalar @$M - 1;
    for ( my $r = $maxr; $r >= 0; $r-- ) {
        push @$F, $M->[$r];
    }
    return $F;
}

sub flipV {        # flip around horisontal axis, left <-> right
    my ($M) = @_;
    my $F;
    for my $r ( 0 .. scalar @$M - 1 ) {
        push @$F, [ reverse @{ $M->[$r] } ];
    }
    return $F;
}

sub edges {
    my ($M) = @_;
    my $len = scalar @$M;    # implicitely square matrix
    my $res;

    # N, E, S, W
    $res->{N} = $M->[0];
#    push @$res, $M->[0];

    # E
    my $E;
    for my $r ( 0 .. $len - 1 ) {

        $E->[$r] = $M->[$r][ $len - 1 ];
    }
    #    push @$res, $E;
    $res->{E} = $E;

    # S
#    push @$res, $M->[ $len - 1 ];
    $res->{S} = $M->[ $len - 1 ];
    # W
    my $W;
    for my $r ( 0 .. $len - 1 ) {
        $W->[$r] = $M->[$r][0];
    }
    #    push @$res, $W;
    $res->{W} = $W;
    return $res;

}
my %rotate = ('100'=>sub{my ($m) = @_; return $m},
	      '101'=>sub{my ($m) = @_; return flipH($m)},
	      '102'=>sub{my ($m)=@_;return flipV($m)},
	      '200'=>sub{my ($m)=@_; return rotate90($m)},
	      '201'=>sub{my ($m)=@_; return flipH(rotate90($m))},
	      '202'=>sub{my ($m)=@_; return flipV(rotate90($m))},
	      '300'=>sub{my ($m)=@_; return rotate90(rotate90($m))},
	      '400'=>sub{my ($m)=@_; return rotate90(rotate90(rotate90($m)))},
	     );

sub all_edges {
    my ($M) = @_;
    my $all_edges;
    my $res;
    my $named;
    push @$all_edges, edges($M);
    push @$all_edges, edges( flipH($M) );
    push @$all_edges, edges( flipV($M) );

    my $T = rotate90($M);
    push @$all_edges, edges($T);
    push @$all_edges, edges( flipH($T) );
    push @$all_edges, edges( flipV($T) );

    push @$all_edges, edges( rotate90($T) );
    push @$all_edges, edges( rotate90( rotate90($T) ) );
    $named->{100} = edges($M) ;
    $named->{'101'} = edges( flipH($M) );
    $named->{'102'} = edges( flipV($M) );
    $T = rotate90($M);
    $named->{'200'}= edges($T);
    $named->{'201'} = edges( flipH($T) );
    $named->{'202'} = edges( flipV($T) );

    $named->{300} = edges( rotate90($T) );
    $named->{400} = edges( rotate90( rotate90($T) ) );

    for my $el (@$all_edges) {
	for my $k (keys %$el) {
	    my @edge = @{$el->{$k}};
	    my @rev = reverse @edge;
	    $res->{join('',@edge)}++;
	    $res->{join('',@rev)}++;
	}
    }
    return {canon=>$res, named=>$named};
}



sub dump_matrix {
    my ($M) = @_;
    for my $r (@$M) {
        say join( '', @$r );
    }
    say '';
      
}

sub dump_edges {
    my ($e) = @_;
    for (@$e) {
        say join( '', @{$_} );
    }
}

sub dump_string {
    my ($M) = @_;
    my $str;
    for (@$M) {
        $str .= join( '', @{$_} );
    }
    return $str;
}
my %tiles;
my %opposites = ( N=>'S',W=>'E',E=>'W',S=>'N');
sub find_neighbors_by_edge {
    my ($id, $image, $edge ) = @_;
    my $edges = edges( $image );
    my $sought = join('',@{$edges->{$edge}});
    my @results;
    my @neighbors= keys %{$tiles{$id}->{matches}};
    for my $nid (@neighbors) {
	my $n_edges = all_edges( $tiles{$nid}->{matrix})->{named};
	for my $or (sort keys %{$n_edges}) {
	    for my $d (qw/N E S W/) {
		next unless $d eq $opposites{$edge};
		my $target = join('',@{$n_edges->{$or}->{$d}});
		if ($target eq $sought) {
		    push @results, [$nid,$or];
	    }

	    }
	}
    }
    return \@results;
    
}

sub strip_edges {
    my ( $m ) = @_;
    my $res;
    shift @$m;
    pop @$m;
    for my $r (@$m) {
	shift @$r;
	pop @$r;
	push @$res, $r
    }
    return $res;
}
### CODE

for my $entry (@file_contents) {
    my @rows      = split( "\n", $entry );
    my $first_row = shift @rows;
    my ($id)      = ( $first_row =~ /(\d+)/ );


    my $matrix;
    for my $r (@rows) {
        push @$matrix, [ split //, $r ];


    }

    $tiles{$id}->{matrix} = $matrix;
    $tiles{$id}->{edges} = all_edges( $matrix )->{canon};
}


for my $id1 ( sort keys %tiles ) {
    my %edges1 = $tiles{$id1}->{edges}->%*;
    for my $id2 ( sort keys %tiles ) {
        next if ( $id1 == $id2 );
        my $matches = 0;

        for my $e1 ( keys %edges1 ) {
            if ( exists $tiles{$id2}->{edges}->{$e1} ) {
                $tiles{$id1}->{matches}->{$id2} = $e1;
		$tiles{$id2}->{matches}->{$id1} = $e1;
            }
        }

    }
}


my $part1 = 1;
for my $k ( sort keys %tiles ) {
    if ( scalar keys $tiles{$k}->{matches}->%* == 2 ) {
	$part1 *= $k;
		say "==> $k";
	my %top_left;
	my %edges1 = %{edges($tiles{$k}->{matrix})};
	for my $mid (sort keys $tiles{$k}->{matches}->%*) {

	    my %target_edges = %{all_edges( $tiles{$mid}->{matrix})->{named}};
	    for my $or (keys %target_edges) {
		my %edges2 = %{$target_edges{$or}};
		for my $d1 (qw/N E S W/) {
		    if (join('',@{$edges1{$d1}}) eq join('',@{$edges2{$opposites{$d1}}})) {
			say "match on edge $d1 for tile $mid orientation $or edge ",$opposites{$d1};
			$tiles{$k}->{neighbors}->{$d1} = {id=>$mid, or=>$or};
			$tiles{$mid}->{neighbors}->{$opposites{$d1}} = {id=>$k, or=>'000'};

		    }
		}
	    }
	}
    }	
}
if ($testing) {
    ok( $part1 == 20899048083289) ;
} else {
    is( $part1, 19955159604613, "Part 1: ".$part1);    
}



# build image map
my @Map;
my $top_left_id ;
for my $k (keys %tiles) {
    if (exists $tiles{$k}->{neighbors}->{E} and exists $tiles{$k}->{neighbors}->{S}) {

	say "==> starting to build image from top-left corner, tile ID $k";
	$top_left_id= $k;
	$Map[0][0] = {id=>$k, image => $tiles{$k}->{matrix}};
	my $n=$tiles{$k}->{neighbors}->{E};
       
	my $image = $rotate{$n->{or}}->($tiles{$n->{id}}->{matrix});
	$Map[0][1] = {id=> $n->{id}, image=>$image};
	last;
    } else {
	next;
    }
}

my $no_of_rows = sqrt( scalar keys %tiles );
if (int( $no_of_rows) != $no_of_rows ) {
    die "non-square number of tiles, algo won't work";
}
# build top row
for my $c (1..$no_of_rows-1) {
    my $curr= $Map[0][$c-1];
    my $candidates = find_neighbors_by_edge( $curr->{id}, $curr->{image}, 'E');
    die "can't find any candidates!" unless @$candidates;
    my $n = shift @$candidates;
    $Map[0][$c]->{id} = $n->[0];
    $Map[0][$c]->{image} = $rotate{$n->[1]}->($tiles{$n->[0]}->{matrix});
}
# build left edge (West side)
for my $r (1..$no_of_rows-1) {
    my $curr = $Map[$r-1][0];
    my $candidates = find_neighbors_by_edge( $curr->{id}, $curr->{image}, 'S');
    die "can't find any candidates!" unless @$candidates;
    my $n = shift @$candidates;
    $Map[$r][0]->{id} = $n->[0];
    $Map[$r][0]->{image} = $rotate{$n->[1]}->($tiles{$n->[0]}->{matrix});
}
# build rest of the map
for my $r (1..$no_of_rows-1) {
    for my $c (1..$no_of_rows-1) {
	my $curr = $Map[$r][$c-1];
	my $candidates = find_neighbors_by_edge( $curr->{id}, $curr->{image}, 'E');
	die "can't find any candidates!" unless @$candidates;
	my $n = shift @$candidates;
	$Map[$r][$c]->{id} = $n->[0];
	$Map[$r][$c]->{image} = $rotate{$n->[1]}->($tiles{$n->[0]}->{matrix});
	
    }
}

# build a giant matrix of the inner images, stripping "edges"
my $Img;
my $hashcount = 0;
for my $r (0..$no_of_rows-1) {
    for my $c (0..$no_of_rows-1) {
	my $inner = $Map[$r][$c]->{image};
#	dump_matrix( $inner ) if $r==0;
	for my $r_i (1..8) {
	    for my $c_i (1..8) {
		$hashcount++ if $inner->[$r_i][$c_i] eq '#';
		$Img->[$r*8+$r_i-1]->[$c*8+$c_i-1] = $inner->[$r_i][$c_i];
	    }
	}
    }
}

# find monsters
for my $rot (sort keys %rotate) {
    my    $choppiness = $hashcount;
  #  say "checking rotation $rot...";
    my $I = $rotate{$rot}->( $Img );
    #    dump_matrix ($I);
    for my $r (0..($no_of_rows*8-3)) {
	for my $c (0..($no_of_rows*8-20-1)) {
	    my @offset= ([0,18],
			 [1,0],[1,5],[1,6],[1,11],[1,12],[1,17],[1,18],[1,19],
			 [2,1],[2,4],[2,7],[2,10],[2,13],[2,16]);
	    if (all {$I->[$r+$_->[0]]->[$c+$_->[1]] eq '#'} @offset) {
#		say "found monster starting at [$r,$c]";
		$choppiness = $choppiness - 15;
	    }
	}
    }
    if ($choppiness != $hashcount) { # we've found part 2!
	if ($testing) {
	    	is($choppiness,273, "Part 2: ".$choppiness);
	} else {
	is($choppiness,1639, "Part 2: ".$choppiness);	    
	}

    }

}


say "Duration: ", tv_interval($start_time) * 1000, "ms";

__END__
    if (exists $top_left{'E'} and exists $top_left{'S'}) {
	$Map{0}->{0} = {id=>$k, E=>$top_left{'E'}->{tile}, S=>$top_left{'S'}->{tile}, image=> $tiles{$k}->{matrix}};
	
	$Map{0}->{1} = {id=>$top_left{'E'}->{tile}, W=>$k,
			image => $rotate{$top_left{'E'}->{orientation}}->($tiles{$top_left{'E'}}->{matrix})};
	
	$Map{1}->{0} = {id=>$top_left{'S'}->{tile}, N=>$k,
			image=>$rotate{$top_left{'S'}->{orientation}}->($tiles{$top_left{'S'}}->{matrix})};

    } else {
	die "can't find a good top left corner, rewrite your code!";
    }

#say dump \@Map;
# finish first row
my $has_neighbor = 1;
my $col= 1;
my $curr_tile =$Map[0][$col];

while ($has_neighbor) {
    say "==> $col";
    say dump $curr_tile;
    my $candidates = find_neighbors_by_edge( $curr_tile->{id}, $curr_tile->{image}, 'E');
    if (@{$candidates}) {
	my ($id, $or) = @{shift @$candidates};
	say "==> adding $id with $or as neighbor";
	$col += 1;
	my $new = {id=>$id, image => $rotate{$tiles{$id}}->{matrix}->($or)};
	$Map[0][$col] = $new;
	$curr_tile = $new;


    } else { # couldn't find a candidate, row ended
	$has_neighbor = 0;
    }
}
