#!/usr/bin/perl

use warnings;
use strict;

my $in = $ARGV[0];

open IN, $in;

while (<IN>){
	my $GenoCount = 0;
	chomp;
	if ($. == 1){
		print "$_";
	}else{
		my @a = split(/\t/,$_);
		foreach my $i (2..$#a){
			if ($a[$i] ne "NN"){
				$GenoCount++;
			}
		}
		if (($GenoCount eq "0") or ($GenoCount eq "1")){
			next;
		}
		else{
			print "\n$_";
		}
	}
}
close IN;
