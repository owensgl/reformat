#!/usr/bin/perl

#This takes a SNP table and turns AA into 0, 1 or 2, which is the count of the major alelle. It removes invariant sites;
use warnings;
use strict;
my %name_hash;
my %data;
my $counter = 0;
my @names;
my @pos_array;
my $min_genotyped = 0.8;
my $min_maf = 0.001;
my $n_samples;
while(<STDIN>){
	chomp;
	my $line = $_;
	my @a = split(/\t/,$_);
	if ($. == 1){
		$n_samples = $#a - 1;
		print "$line";
		next;
	}
	my %total_alleles;
	my $n_genotyped = 0;
	foreach my $i (2..$#a){
		if ($a[$i] ne "NN"){
			my @bases = split(//,$a[$i]);
			$total_alleles{$bases[0]}++;
			$total_alleles{$bases[1]}++;
			$n_genotyped++;
		}
	}
	
	if (keys %total_alleles ne 2){
		next;
	}
	my @alleles = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles;
	my $major = $alleles[1];
	my $minor = $alleles[0];
	my $maf = $total_alleles{$minor}/($total_alleles{$major} + $total_alleles{$minor});
	if ($maf < $min_maf){next;}
	my $percent_genotyped = $n_genotyped/$n_samples;
	if ($percent_genotyped < $min_genotyped){next;}
	print "\n$a[0]\t$a[1]";
#	print "\t$maf\t$percent_genotyped";
	foreach my $i (2..$#a){
		if ($a[$i] eq "NN"){
			print "\tNA";
		}elsif ($a[$i] eq "${major}${major}"){
			print "\t0";
		}elsif ($a[$i] eq "${minor}${minor}"){
			print "\t2";
		}else{
			print "\t1";
		}
	}
}

