#!/usr/bin/perl

#This only outputs biallelic sites and puts the major allele as reference.
use warnings;
use strict;
use lib '/home/owens/bin'; #For GObox server
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

my %samples;
my @Good_samples;

my %TotalSites;
my %pop;
my %Genotype;

my %samplepop;

my %poplist;


my $in = $ARGV[0];
my $pop = $ARGV[1];
my $out = $ARGV[2];

require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	$poplist{$a[1]}++;
}
close POP;




open (GENOFILE, "> $out.eigenstratgeno") or die "Could not open a file\n";
open (SNPFILE, "> $out.snp") or die "Could not open a file\n";
open (INDFILE, "> $out.ind") or die "Could not open a file\n";

open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1){
  		foreach my $i ($badcolumns..$#a){ #Get sample names for each column
        		if ($pop{$a[$i]}){
        			$samplepop{$i} = $pop{$a[$i]};
        			print INDFILE "$a[$i]\tU\t$pop{$a[$i]}\n";
        		}
        	}

	}else{
		next if /^\s*$/;
		my $snpname = $a[0]."-"."$a[1]";
		my $snpchrom = $a[0];
		my $snppos = $a[1];
		my %BC;
		my %BS;
		my %total_alleles;
		foreach my $i ($badcolumns..$#a){
			if ($samplepop{$i}){
				$BC{"total"}{"total"}++;
				if ($iupac_coding eq "TRUE"){
						$a[$i] = $t{$a[$i]};
				}
				unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
					my @bases = split(//, $a[$i]);
					$total_alleles{$bases[0]}++;
					$total_alleles{$bases[1]}++;
				
					$BC{"total"}{$bases[0]}++;
		        		$BC{"total"}{$bases[1]}++;
					$BC{$samplepop{$i}}{$bases[0]}++;
		 			$BC{$samplepop{$i}}{$bases[1]}++;

					$BC{"total"}{"Calls"}++;
					$BC{$samplepop{$i}}{"Calls"}++;
					
					if($bases[0] ne $bases[1]){
						$BC{"total"}{"Het"}++;
						$BC{$samplepop{$i}}{"Het"}++;
					}
				}
			}
		} 
		if (keys %total_alleles == 2){
			#Sort bases so p is the major allele and q is the minor allele
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			#Major allele
			my $b1 = $bases[1];
			#Minor allele
			my $b2 = $bases[0];
			print SNPFILE "$snpname\t$snpchrom\t0.0\t$snppos\n";
			foreach my $i ($badcolumns..$#a){
				if ($samplepop{$i}){
					my @bases = split(//, $a[$i]);
					if ($bases[0] eq "N"){
						print GENOFILE "9";
					}elsif (($bases[0] eq $b1) and ($bases[1] eq $b1)){
						print GENOFILE "2";
					}elsif (($bases[0] ne $b1) and ($bases[1] ne $b1)){
						print GENOFILE "0";
					}else {
						print GENOFILE "1";
					}
				}
			}
			print GENOFILE "\n";
		}
	}
}
