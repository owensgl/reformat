#!/bin/perl
use warnings;
use strict;
use File::Basename;
my $min_dp = 10;

#GLO Mar 20, 2015. This script takes stdout piped from GATK when outputting a vcf with all sites. It filters out invariant sites with depth less than a cut off. 
while(<STDIN>){
	my $line = "$_";
	chomp $line;
	my @fields = split /\t/,$line;
   	if($line=~m/^##/){
		print "$line\n";
	}
	elsif($line=~m/^#/){
		print "$line";
	}
	elsif($fields[7]=~m/^NCC/) {
		next;
	}elsif($fields[7]=~m/^DP/){
		my @tmp = split(/;/,$fields[7]);
		my @DP = split(/=/,$tmp[0]);
		if ($DP[1] < $min_dp){
			next;
		}else{
			print "\n$line";
		}
	}else {
		print "\n$line";
	}
}
			
