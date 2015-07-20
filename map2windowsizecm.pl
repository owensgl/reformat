#!/bin/perl
use strict;
use warnings;

my $map = $ARGV[0]; #linkage group to bp information for bronze genome
my $window_size = 1000000;
my $end_bp = $window_size;
my $start_cm = 0;
my $current_chr;

my $saved_cM;
print "chrom\tstart\tend\tcm_start\tcm_end\tcm_size";
open MAP, $map;
while (<MAP>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		#Nothing;
	}
	else{
		my $chrom = $a[0];
		if ($chrom =~ m/^0/){
			my @tmp = split(//, $chrom);
			$chrom = "Ha$tmp[1]";
		}else{
			$chrom = "Ha$chrom";
		}
		my $bp = $a[1];
		my $cM = $a[2];
		if ($cM eq "NA"){
			next;
		}
		
		unless ($current_chr){
			$current_chr = $chrom;
		}
		if (($current_chr ne $chrom) or ($bp > $end_bp)){
			my $start_bp = $end_bp - $window_size;
			my $cM_size = $saved_cM - $start_cm;
			print "\n$current_chr\t$start_bp\t$end_bp\t$start_cm\t$saved_cM\t$cM_size";
			if ($current_chr ne $chrom){
				$current_chr = $chrom;
				$end_bp = $window_size;
				$start_cm = 0;
			}else{		
				$end_bp = $end_bp + $window_size;
				$start_cm = $saved_cM;
			}
		}
		$saved_cM = $cM;
	}
}
		
		
