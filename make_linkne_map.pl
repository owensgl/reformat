#!/bin/perl

use warnings;
use strict;

my $map = $ARGV[0]; #lg.ALL.bronze14.path.txt
my $snp = $ARGV[1]; #SNP file in hmp format

my $tmp;
my %hash;
open MAP, $map;
while(<MAP>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. ne "1"){
		if ($a[2] ne "NA"){
			my $chrom = $a[0];
			$hash{$chrom}{$a[1]} = $a[2];
		}
	}
}

close MAP;

print "locus\tchromosome\tposition";
open SNP, $snp;
while(<SNP>){
	chomp;
	my $line = $_;
	if ($line =~ /^#/){next;}
	if ($. == 1){next;}
	my @a = split(/\t/,$line);
	my $chrom = $a[0];
	my $bp = $a[1];
	my $loci = "${chrom}_${bp}";
	$chrom =~ s/Ha//;
	$chrom = sprintf("%02d", $chrom);
	my $previous_site;
	my $before_site;
	my $after_site;
	my $loci_cM;
	foreach my $site (sort  {$a <=> $b} keys %{$hash{$chrom}}){
		if ($site > $bp){
			if ($previous_site){
				$before_site = $previous_site;
				$after_site = $site;
				goto FOUNDPOS;
			}else{
				$loci_cM = "NA";
				goto BADSITE;
			}
		}
		$previous_site = $site;
	}
	$loci_cM = "NA";
	goto BADSITE;
	FOUNDPOS:
	my $cM_range = $hash{$chrom}{$after_site} - $hash{$chrom}{$before_site};
	my $bp_range = $after_site - $before_site;
	my $percent_of_range = ($bp - $before_site)/$bp_range;
	$loci_cM = ($percent_of_range * $cM_range) + $hash{$chrom}{$before_site};
	
	BADSITE:
	print "\n$loci\t$chrom\t$loci_cM";
}
