#!/bin/perl
use warnings;
use strict;

#This takes a VCF and outputs  a tidy output of genotypes. It does not output missing data. It also flattens all alternate alleles, so its basically just counting the number of non-reference alleles.

my %samples;
while(<STDIN>){
	chomp;
	if ($_ =~ m/^##/){next;}
	if ($_ =~ m/^#/){
		my @a = split(/\t/,$_);
		foreach my $i (9..$#a){
			$samples{$i} = $a[$i];
		}
	}else{
		my @a = split(/\t/,$_);
		my $chr = $a[0];
		my $pos = $a[1];
		foreach my $i (9..$#a){
			my @fields = split(/:/,$a[$i]);
			my $genotype = $fields[0];
			if ($genotype eq './.'){next;}
			if ($genotype eq '.'){next;}
			my @genotypes;
			if ($genotype =~ m/\|/){
				@genotypes = split(/\|/,$genotype);
			}else{
				@genotypes = split(/\//,$genotype);
			}
			my $alt_count = 0;
			foreach my $j (0..1){
				if ($genotypes[$j] ne '0'){
					$alt_count++;
				}
			}
			print "\n$chr\t$pos\t$samples{$i}\t$alt_count";
		}
	}
}
