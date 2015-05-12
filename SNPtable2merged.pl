#!/usr/bin/perl
use warnings;
use strict;

#This combines multiple tab delimited files
#This version is not memory safe

my $Nvalue = "NN";
my %genotypehash;
my %positionhash;
my %totalsamplehash;
foreach my $n (0..$#ARGV){
	open IN, $ARGV[$n];
	my %samplehash;
	while (<IN>){
		chomp;
		my @a = split(/\t/,$_);
		if ($. == 1){
			foreach my $i (2..$#a){
				$samplehash{$i} = $a[$i];
				$totalsamplehash{$a[$i]}++;
			}
		}else{
			my $chrom = $a[0];
			my $pos = $a[1];
			$positionhash{$chrom}{$pos}++;
			foreach my $i (2..$#a){
				$genotypehash{$chrom}{$pos}{$samplehash{$i}} = $a[$i];
			}
		}
	}
	close IN;
}
print "CHROM\tPOS";
foreach my $sample (sort keys %totalsamplehash){
	print "\t$sample";
}
foreach my $chrom (sort keys %positionhash){
	foreach my $pos (sort {$a<=>$b} keys %{ $positionhash{$chrom} } ) {
		print "\n$chrom\t$pos";
		foreach my $sample (sort keys %totalsamplehash){
			if 	($genotypehash{$chrom}{$pos}{$sample}){
				print "\t$genotypehash{$chrom}{$pos}{$sample}";
			}else{
				print "\t$Nvalue";
			}
		}
	}
}
