#!/bin/perl
use warnings;
use strict;

#This script takes a fasta input of all genes, as well as a windows file and classifies genes as in a selected window type or not.

my $fasta = $ARGV[0];
my $windows = $ARGV[1];

my $parent = "P1"; #Pick the parent you want to use
my $w_size = 1000000;
my %hash;
open WIN, $windows;
while (<WIN>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. ==1){
	
	}else{
		my $chr = $a[0];
		my $start = $a[1];
		my $result = $a[5];
		$hash{$chr}{$start} = $result;
		print "$result\n";
	}
}
close WIN;

print "ID\tScore.$parent";

open FAS, $fasta;
while (<FAS>){
	chomp;
	if($_=~m/^>/){
		my @a = split(/\s/,$_);
		my $name = $a[0];
		$name =~ s/>//g;
		my $chr = $a[5];
		$chr =~ s/chr=//g;
		my $start = $a[2];
		$start =~ s/begin=//g;
		my $end = $a[3];
		$end =~ s/end=//g;
		my $window_start;
		for (my $i = 0; $i < 400000000; $i+= 1000000){
			my $j = $i+1000000;
			if (($start > $i) and ($start < $j)){
				if ($end < $j){
					$window_start = $i;
				}else{
					my $first_part = abs($start - $j);
					my $second_part = ($end - $j);
					if ($first_part >= $second_part){
						$window_start = $i;
					}else{
						$window_start = $j;
					}
				}
			}
		}
		print "$name\t$chr\t$start\t$end\t$window_start\n";
		my $result = $hash{$chr}{$window_start};
		print "$result\n";
		my $score;
		if ($parent eq "P1"){
			if ($result eq "TRUE FALSE FALSE"){
				$score = 1;
			}elsif ($result eq "TRUE FALSE TRUE"){
				$score = 0.5;
			}elsif (($result eq "TRUE TRUE TRUE") or ($result eq "FALSE FALSE FALSE")){
				$score = 0;
			}elsif ($result eq "FALSE TRUE TRUE"){
				$score = -0.5;
			}elsif ($result eq "FALSE TRUE FALSE"){
				$score = -1;
			}
		}
		print "\n$name\t$score";
	}
}
		
