#!/usr/bin/perl

# this script takes a SNP table (formatted with three leading columns: contig/site/reference, followed by individual sample genotypes in columns) and a list of samples with their population IDs (text file, two columns with the sample name as in the SNP table header, then a tab, then the population ID), and outputs a structure input file formatted with each sample's allele calls on one line (e.g. sample, pop id, loc1_allele1, loc1_allele2, etc.). Written by Brook Moyers, last modified on Feb 9, 2012.

# usage: perl table2structure.pl infile popfile outfile

use warnings;
use strict;

unless (@ARGV == 3) {die;} # have you given it all the infos?

my $in = $ARGV[0]; # snp table
my $popfile = $ARGV[1]; # sample population ID list 
my $out = $ARGV[2];

open IN, $in;
open POP, $popfile;
open OUT, ">$out";

# pull out pop ID numbers
my %pop;
while (<POP>){
	chomp;
	my @a = split(/\t/,$_);
	$pop{$a[0]}=$a[1];
}

# take out SNP table header, move to first sample column
my $head = `head -n 1 $in`;
chomp $head;
my @samples = split /\t/,$head;
shift @samples;
shift @samples;
#shift @samples;
my $f = 3;

# for each column of sample genotypes, print sample name, pop ID, then transform each genotype call into two numbered alleles (1 = A, 2 = T, 3 = C, 4 = G). For missing data (e.g. 'N', but can be in any format except AGCT), the allele is given as -9, the standard STRUCTURE NA string.
foreach(@samples){
	my $id = "$_";
	print OUT "$id"."\t";
	print OUT $pop{$id};
	my $cut = `cut -f $f $in`;
	chomp $cut;
	my @genotypes = split /\n/,$cut;
	shift @genotypes;
	foreach(@genotypes){
		my $genotype = "$_";

		if ($genotype eq 'AA'){
           print OUT "\t".'1'."\t".'1';
       	}
       	elsif ($genotype eq 'TT'){
           print OUT "\t".'2'."\t".'2';
       	}
       	elsif ($genotype eq 'CC'){
           print OUT "\t".'3'."\t".'3';
       	}
       	elsif ($genotype eq 'GG'){
           print OUT "\t".'4'."\t".'4';
       	}
       	elsif (($genotype eq 'AC') || ($genotype eq 'CA')){
           print OUT "\t".'1'."\t".'3';
       	}
       	elsif (($genotype eq 'AG') || ($genotype eq 'GA')){
           print OUT "\t".'1'."\t".'4';
       	}
       	elsif (($genotype eq 'AT') || ($genotype eq 'TA')){
           print OUT "\t".'1'."\t".'2';
       	}
       	elsif (($genotype eq 'CG') || ($genotype eq 'GC')){
           print OUT "\t".'3'."\t".'4';
       	}
       	elsif (($genotype eq 'CT') || ($genotype eq 'TC')){
           print OUT "\t".'2'."\t".'3';
       	}
       	elsif (($genotype eq 'GT') || ($genotype eq 'TG')){
           print OUT "\t".'2'."\t".'4';
       	}
       	else{
           print OUT "\t".'-9'."\t".'-9';
       	}
	}
	print OUT "\n";
	++$f;
}

close POP;
close IN;
close OUT;
