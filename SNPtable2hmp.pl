#!/bin/perl

#GLO Feb 6, 2015
#This script takes a tab separated snp table and converts it to hapmap format. It only outputs biallelic sites.
use warnings;
use strict;
use lib '/home/owens/bin/pop_gen/'; #For GObox server

while (<STDIN>){
	chomp;
	my @a = split(/\t/, $_);
	if ($. == 1){
		print "rs\talleles\tchrom\tpos\tstrand\tassembly\tcenter\tprotLSID\tassayLSID\tpanelLSID\tQCcode";
		foreach my $i (2..$#a){
			print "\t$a[$i]";
		}
	}else{
		next if /^\s*$/;
		my %total_alleles;
		foreach my $i (2..$#a){
			unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
				my @bases = split(//, $a[$i]);
				$total_alleles{$bases[0]}++;
				$total_alleles{$bases[1]}++;
			}
		}
		if (keys %total_alleles == 2){
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			print "\n$a[0]_$a[1]\t$bases[0]/$bases[1]\t$a[0]\t$a[1]\t+\tNA\tNA\tNA\tNA\tNA\tQC+";
			foreach my $i (2..$#a){
				print "\t$a[$i]";
			}
		}
	}
}
