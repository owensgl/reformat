#!/bin/perl
use warnings;
use strict;

#This script reduces a snp table to one snp every 1000 bp at max.
my $dist = 1000; #Minimum distance between SNPs

my $previous_chr;
my $previous_pos;
while (<STDIN>){
	chomp;
	if ($. == 1){
		print "$_";
	}else{
		my @a = split(/\t/,$_);
		my $chr = $a[0];
		my $pos = $a[1];
		unless ($previous_chr){
			$previous_chr = $chr;
			$previous_pos = $pos;
			print "\n$_";
			next;
		}
		if ($chr ne $previous_chr){
			$previous_chr = $chr;
			$previous_pos = $pos;
			print "\n$_";
			next;
		}elsif ($previous_pos +1000<= $pos){
			$previous_chr = $chr;
			$previous_pos = $pos;
			print "\n$_";
			next;
		}
	}
}

