#!/usr/bin/perl

#This takes a SNP table and turns it into a matrix for PCA with allele counts
use warnings;
use strict;
my $popfile = $ARGV[0];
my %poplist;
open POP, $popfile;
while (<POP>){
	chomp;
	my @a = split(/\t/,$_);
	$poplist{$a[0]} = $a[1];
}
my %name_hash;
my %data;
my $counter = 0;
my @names;
my @pos_array;
while(<STDIN>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		foreach my $i (2..$#a){
			$name_hash{$i} = $a[$i];
			push(@names, $a[$i]);
		}
		next;
	}
	my %total_alleles;
	foreach my $i (2..$#a){
		if ($a[$i] ne "NN"){
			my @bases = split(//,$a[$i]);
			$total_alleles{$bases[0]}++;
			$total_alleles{$bases[1]}++;
		}
	}
	if (keys %total_alleles ne 2){
		next;
	}
	my @alleles = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles;
	my $major = $alleles[1];
	my $minor = $alleles[0];
	foreach my $i (2..$#a){
		if ($a[$i] eq "NN"){
			$data{$name_hash{$i}}{$counter} = "NA";
		}elsif ($a[$i] eq "${major}${major}"){
			$data{$name_hash{$i}}{$counter} = "2";
		}elsif ($a[$i] eq "${minor}${minor}"){
			$data{$name_hash{$i}}{$counter} = "0";
		}else{
			$data{$name_hash{$i}}{$counter} = "1";
#			print "$a[$i]\t${major}.${major} or ${minor}.${minor}\n";
		}
	}
	my $pos = "$a[0]_$a[1]";
	push(@pos_array,$pos);
	$counter++;
}
print "\tpopulation";
foreach my $pos (@pos_array){
	print "\t$pos";
}
foreach my $name (@names){
	print "\n$name";
	print "\t$poplist{$name}";
	foreach my $i (0..($counter -1)){
		print "\t$data{$name}{$i}";
	}
	
}
