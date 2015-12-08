#!/usr/bin/perl

use warnings;
use strict;



while (<STDIN>){
	my $GenoCount = 0;
	chomp;
	if ($. == 1){
		print "$_";
	}else{
		my @a = split(/\t/,$_);
		foreach my $i (2..$#a){
			if ($GenoCount > 1){
				goto PRINTLINE;
			}
			if ($a[$i] ne "NN"){
				$GenoCount++;
			}
		}
		if (($GenoCount eq "0") or ($GenoCount eq "1")){
			next;
		}
		PRINTLINE:
		print "\n$_";
	}
}
