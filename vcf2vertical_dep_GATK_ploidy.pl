#!/bin/perl
use warnings;
use strict;
use File::Basename;

#GLO Feb 20, 2015
#This script takes a polyploid vcf file from GATK and outputs the allele count for reference and alternate alleles, based on specified ploidy.
#It requires a minimum depth for the site to be printed.
#It prints invariant sites as well.

my $min_dp = 20;
my $ploidy;
while(<STDIN>){
	my $line = "$_";
	chomp $line;
	my @fields = split /\t/,$line;
	if ($line=~m/^##GATKCommandLine/){
		my @tmp = split(/ /, $_);
		foreach my $a (@tmp){
			if ($a=~m/^sample_ploidy/){
				$a =~ s/sample_ploidy=//g;
				$ploidy = $a;
			}
		}
	}
	if($line=~m/^##/){
		next;
	}
	elsif($fields[7]=~m/^NCC/) {
		next;
	} 
	else{
		my $chrome = shift @fields;
		my $pos =    shift @fields;
		my $id =     shift @fields;
		my $ref =    shift @fields;
		my $alt =    shift @fields;
		my $qual =   shift @fields;
		my $filter = shift @fields;
		my $info =   shift @fields;
		my $format = shift @fields;
		if($line=~m/^#/){
			print "chrom\tpos\tref\tref_alleles\talt\talt_alleles";
		}
		my @infofields = split(/;/, $info);
		my $DP = 0;
		my $AF;
		foreach my $category (@infofields){
			if ($category =~ /^DP/){
				$category =~ s/DP=//g;
				$DP = $category;
			}elsif ($category =~ /^AF/){
				$category =~ s/AF=//g;
				$AF = $category;
			}
		}
                if ((length($ref) > 1) or (length($alt) > 1)){ #If its an indel, skip the line
                	next;
                }
		elsif ($alt eq '.'){
			if ($DP >= $min_dp){
				print "\n$chrome\t$pos\t$ref\t$ploidy\t.\t.";
			}
		}
		else{
			if ($DP >= $min_dp){
				my $tmp = ($AF * $ploidy);
				my $altfreq = sprintf("%.0f", $tmp);
				my $reffreq = ($ploidy - $altfreq);					
				print "\n$chrome\t$pos\t$ref\t$reffreq\t$alt\t$altfreq";
			}
		}
	}
}
