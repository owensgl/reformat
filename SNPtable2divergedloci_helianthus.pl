#!/usr/bin/perl

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

my $min_dif = 0.5; #Minimum difference in allele frequency
my $min_cov = 4; #Minimum number of samples sequenced for each parent group
my $in = $ARGV[0]; #SNP table
my $pop = $ARGV[1]; #Pop file with P1, P2, and H
require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

my %pop;
my %poplist;
my %samplepop;
open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);
	$pop{$a[0]}=$a[1];
	$poplist{$a[1]}++;
}
close POP;


open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/, $_);
	if ($. == 1){
		foreach my $i($badcolumns..$#a){
			if ($pop{$a[$i]}){
				$samplepop{$i} = $pop{$a[$i]};
			}
		}
		print "$_";
	}else{
		next if /^\s*$/;
		my %BC;
		my %total_alleles;
		foreach my $i ($badcolumns..$#a){
			if ($samplepop{$i}){
				if ($iupac_coding eq "TRUE"){
						$a[$i] = $t{$a[$i]};
				}
				unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
					my @bases = split(//, $a[$i]);
					$total_alleles{$bases[0]}++;
					$total_alleles{$bases[1]}++;
					$BC{$samplepop{$i}}{$bases[0]}++;
					$BC{$samplepop{$i}}{$bases[1]}++;
					$BC{$samplepop{$i}}{"Calls"}++;
					$BC{$samplepop{$i}}{"Calls"}++;
				}
			}
		}
		if (keys %total_alleles ==2){
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			my $b1 = $bases[1]; #Major
			my $b2 = $bases[0];	#Minor
			my $p1;
			my $p2;
			if ($BC{"P1"}{$b1}){
				$p1 = ($BC{"P1"}{$b1}/ $BC{"P1"}{"Calls"});
			}else{
				$p1 = 0;
			}
			if ($BC{"P2"}{$b1}){
				$p2 = ($BC{"P2"}{$b1}/ $BC{"P2"}{"Calls"});
			}else{
				$p2 = 0;
			}
			unless ($BC{"P1"}{"Calls"}){
				$BC{"P1"}{"Calls"} = 0;
			}
			unless ($BC{"P2"}{"Calls"}){
				$BC{"P2"}{"Calls"} = 0;
			}
			my $dif = abs($p1 - $p2);
			if (($dif >= $min_dif) and ($BC{"P1"}{"Calls"} >= 8) and ($BC{"P2"}{"Calls"} >= 8)){
				print "\n$_"
			}
		}
	}
}
