#!/bin/perl
use warnings;
use strict;
#This will take a tab file (with cM) and a info file. It will look for fixed differences between the parents, print out the sample size of the parents (which are going to be equal) and also print out the number of copies of parent 2 alleles that each hybrid has at each site (i.e. 0 = two copies of P1 allele, 2 = two copies of P2 allele). It will print N for missing data. 
#INPUT
#tab format (chr, pos, cm, sample_1, sample_2...) piped in stdin
my $popfile = $ARGV[0]; #A population file.

my %pop;
my %popList;
my %samplepop;
my %samplename;


open POP, $popfile;
while (<POP>){ #Load in population information linked with sample name
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	$popList{$a[1]}++;
}
close POP;
#Variables guessed from file, set for hapmap without iupac
my $badcolumns="3";
my %good_number_hash;
my $counter;
while (<STDIN>){
	chomp;
	my @a = split(/\t/,$_);
	
	if ($. == 1){ #Load in sample names associated with column numbers, as well as population
		print  "chrom\tbp\tcm\tN";
		foreach my $i($badcolumns..$#a){
			if ($pop{$a[$i]}){
				$samplepop{$i} = $pop{$a[$i]};
				$samplename{$i} = $a[$i];
				$good_number_hash{$i}++;
				if ($pop{$a[$i]} eq "H"){
					print "\t$a[$i]";
				}
			}
		}
	}else{
		next if /^\s*$/;
		my $chrom = $a[0];
		my $pos = $a[1];
		my $cm = $a[2];
		my $counter++;
		if (($counter % 100000)== 0){
        	        print STDERR "Hyblik Processing $chrom $pos...\n";
        	}
		
		my %BC;
		my %total_alleles;
		my $P1count = 0;
		my $P2count = 0;
		foreach my $i (keys %good_number_hash){ #Load up parental alleles
                	if ($a[$i] ne "NN"){
                        	if ($samplepop{$i} eq "P1"){
                        	        $P1count++;
                        	}elsif($samplepop{$i} eq "P2"){
                                	$P2count++;
                       		}
                	}
        	}
		unless(($P1count >=5) and ($P2count >= 5)){
                	next;
        	}
		my $min_count;
		if ($P1count < $P2count){
                	$min_count = $P1count;
        	}else{
                	$min_count = $P2count;
        	}
		my %P1alleles;
		my %P2alleles;
		my $P1count2 = 0;
		my $P2count2 = 0;
		foreach my $i(keys %good_number_hash){
			if ($samplepop{$i}){
				$BC{"total"}{"total"}++;
				unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
					my @bases = split(//, $a[$i]);
					$total_alleles{$bases[0]}++;
					$total_alleles{$bases[1]}++;
				
					$BC{"total"}{$bases[0]}++;
		        		$BC{"total"}{$bases[1]}++;
					$BC{$samplepop{$i}}{$bases[0]}++;
		 			$BC{$samplepop{$i}}{$bases[1]}++;

					$BC{$i}{$bases[0]}++;
					$BC{$i}{$bases[1]}++;
					$BC{$i}{"Calls"}++;

					$BC{"total"}{"Calls"}++;
					$BC{$samplepop{$i}}{"Calls"}++;
					if (($samplepop{$i} eq "P1") and ($P1count2 < $min_count)){
						$P1alleles{$bases[0]}++;
						$P1alleles{$bases[1]}++;
						$P1alleles{"Calls"}++;
						$P1count2++;
					}elsif(($samplepop{$i} eq "P2") and ($P2count2 < $min_count)){
						$P2alleles{$bases[0]}++;
                                                $P2alleles{$bases[1]}++;
						$P2alleles{"Calls"}++;
                                                $P2count2++;
					}
				}
			}
		}
		if (keys %total_alleles == 2){
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			#Major allele
			my $b1 = $bases[1];
			#Minor allele
			my $b2 = $bases[0];
			my $p1;
			my $p2;
			my $q1;
			my $q2;
			my $dif;
			#Allele frequency of each allele in each population
			if ($P1alleles{$b1}){
				$p1 = $P1alleles{$b1}/($P1alleles{"Calls"}*2);
			}else{
				$p1 = 0;
			}
			if ($P2alleles{$b1}){
				$p2 = $P2alleles{$b1}/($P2alleles{"Calls"}*2);
			}else{
				$p2 = 0;
			}
			$dif = abs($p1 - $p2);
			if ($dif < 1){ #Skip sites with equal allele frequency between parents
				next;
			}
			my $parent1_allele;
			my $parent2_allele;
			if ($p1){
				$parent1_allele = $b1;
				$parent2_allele = $b2;
			}else{
				$parent1_allele = $b2;
				$parent2_allele = $b1;
			}
			print "\n$chrom\t$pos\t$cm\t$min_count";
			foreach my $i ($badcolumns..$#a){
				if ($samplepop{$i}){
					if ($samplepop{$i} eq "H"){
						if ($BC{$i}{"Calls"}){
							if ($BC{$i}{$parent2_allele}){
								if ($BC{$i}{$parent2_allele} == 2){
									print "\t2";
								}elsif ($BC{$i}{$parent2_allele} == 1){
									print "\t1";
								}
							}else{
								print "\t0";
							}
						}else{
							print "\tN";
						}
					}
				}
			}
		}
	}
	SKIP:
}
			
	
