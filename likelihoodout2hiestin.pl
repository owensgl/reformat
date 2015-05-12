#!/bin/perl

use warnings;
use strict;

my $in = $ARGV[0];

my %sample_assign;
my %loci_hash;
my %samplelist;
my %unique_samples;
my $unknowntohet = "TRUE";
open IN, $in;
while (<IN>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		foreach my $i (4..$#a){
			my $sample = substr($a[$i], 0, -2);
			$samplelist{$i} = $sample;
			$unique_samples{$sample}++;
		}
	}else{
		my $loci = "$a[0]_$a[1]";
		if ($loci =~ /scaffold/){
			next;
		}
		$loci_hash{$loci}++;
		foreach my $i (4..$#a){
			my @info = split(/:/,$a[$i]);
			if ($sample_assign{$loci}{$samplelist{$i}}){
				if ($info[0] eq "NA"){
					$sample_assign{$loci}{$samplelist{$i}} = "NA";
				}elsif ($info[0] eq "P1"){
					unless ($sample_assign{$loci}{$samplelist{$i}} eq "NA"){
						$sample_assign{$loci}{$samplelist{$i}}++;
					}
				}
			}else{
				if ($info[0] eq "NA"){
					$sample_assign{$loci}{$samplelist{$i}} = "NA";
				}elsif ($info[0] eq "P1"){
					$sample_assign{$loci}{$samplelist{$i}}++;
				}
			}
		}
	}
}
print "Sample";
foreach my $loci (keys %loci_hash){
	print "\t$loci";
}
foreach my $sample (keys %unique_samples){
	print "\n$sample";
	foreach my $loci (keys %loci_hash){
		if ($unknowntohet ne "TRUE"){
			if ($sample_assign{$loci}{$sample}){
				print "\t$sample_assign{$loci}{$sample}";
			}else{
				print "\t0";
			}
		}else{
			if ($sample_assign{$loci}{$sample}){
				$sample_assign{$loci}{$sample} =~ s/NA/1/g;
				print "\t$sample_assign{$loci}{$sample}";
			}else{
				print "\t0";
			}
		}
	}
}
		
	
