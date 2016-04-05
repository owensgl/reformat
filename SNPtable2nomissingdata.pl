#!/bin/perl
use warnings;
use strict;
use List::MoreUtils qw(uniq);
#Calculates genetic distance between all individuals (includes species ID), using genpofad distance. Allows no missing data. 
my $samplefile = $ARGV[0];

my %printlist;
my %specieslist;
my @species_array;
open SAMPLEFILE, $samplefile;
while(<SAMPLEFILE>){
	chomp;
	my @a = split(/\t/,$_);
	$printlist{$a[0]}++;
	$specieslist{$a[0]} = $a[1]; #should have real species names, don't include species you don't want compared.
	push(@species_array,$a[1]);
}
close SAMPLEFILE;

my @tmp = uniq @species_array;
@species_array = @tmp;
my %species;
my %samplelist;
my $counter;
my @good_number_list;
my %data;
my $sitecounter;
while(<STDIN>){
  $counter++;
	chomp;
	my $line = "$_";
	my @a = split(/\t/,$line);
	if ($. == 1){
		foreach my $i (2..$#a){
			$samplelist{$i} = $a[$i];
			if ($specieslist{$a[$i]}){
				$species{$i} = $specieslist{$a[$i]};
				push(@good_number_list, $i);
			}
		}
		print "$_";
		next;
	}
	unless ($a[2]){
		next;
	}
  	my $pos = $a[1];
	my $chrom = $a[0];
	if (($counter % 100000)== 0){
		print STDERR "Processing $chrom $pos...\n";
	}
	my %species_counter;
	my %geno_hash;
	foreach my $i (@good_number_list){
		if ($a[$i] eq "NN"){
			goto NEXT_LINE; #Skip all lines with missing data
		}
	}
	print "\n$_";
	NEXT_LINE:
}

