#!/bin/perl

#GLO Feb 6, 2015
#This script takes a tab separated snp table and converts it to hapmap format. It only outputs biallelic sites.
use warnings;
use strict;
use lib '/home/owens/bin/pop_gen/'; #For GObox server
my %t;
$t{"N"} = "NN";
$t{"A"} = "AA";
$t{"T"} = "TT";
$t{"G"} = "GG";
$t{"C"} = "CC";
$t{"W"} = "TA";
$t{"R"} = "AG";
$t{"M"} = "AC";
$t{"S"} = "CG";
$t{"K"} = "TG";
$t{"Y"} = "CT";

my $in = $ARGV[0];

require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

open IN, $in;
while (<IN>){
	chomp;
	my @a = split(/\t/, $_);
	if ($. == 1){
		print "rs\talleles\tchrom\tpos\tstrand\tassembly\tcenter\tprotLSID\tassayLSID\tpanelLSID\tQCcode";
		foreach my $i ($badcolumns..$#a){
			print "\t$a[$i]";
		}
	}else{
		next if /^\s*$/;
		print "\n";
		my %total_alleles;
		foreach my $i ($badcolumns..$#a){
			if ($iupac_coding eq "TRUE"){
						$a[$i] = $t{$a[$i]};
			}
			unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
				my @bases = split(//, $a[$i]);
				$total_alleles{$bases[0]}++;
				$total_alleles{$bases[1]}++;
			}
		}
		if (keys %total_alleles == 2){
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			print "$a[0]_$a[1]\t$bases[0]/$bases[1]\t$a[0]\t$a[1]\t+\tNA\tNA\tNA\tNA\tNA\tQC+";
			foreach my $i ($badcolumns..$#a){
				print "\t$a[$i]";
			}
		}
	}
}
close IN;
