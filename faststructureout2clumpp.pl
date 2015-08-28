#!/bin/perl
use warnings;
use strict;

my $popfile = $ARGV[0];
my $structure_out = "output_";
my $number_of_reps = "100"; #Number of times faststructure run
my $max_k = "10"; #Max K values used
my @namelist;
my @poplist;
open POP, $popfile;
while(<POP>){
	chomp;
	my @a = split(/\t/,$_);
	push(@poplist, $a[1]);
	push(@namelist, $a[0]);
}

close POP;
foreach my $k (1..$max_k){
	open OUT, ">", "summarized_$k.clumpp";
	foreach my $j (1..$number_of_reps){
		open IN, "$structure_out$j.$k.meanQ";
		my $linecount = 0;
		while (<IN>){
			chomp;
			my $current_line = $linecount+1;
			print OUT "$current_line\t$current_line\t(0)\t1\t:\t$_\n";
			#print OUT "$current_line\t$namelist[$linecount]\t(0)\t$poplist[$linecount]\t:\t$_\n";
			$linecount++;
		}
		close IN;
		print OUT "\n";
	}
	close OUT;
}
