#!/usr/bin/perl

use warnings;
use strict;

#unless (@ARGV == 3) {die;}

my $in = $ARGV[0];
my $out = $ARGV[1];
my $pop = $ARGV[2];
my %pop;

my %samples;
my @samples;
my %popList;

my $NumColBad=3;

if ($pop){
	open POP, $pop;
	while (<POP>){
		unless ($. == 1){
			chomp;
			my @a = split (/\t/,$_);	
			$pop{$a[0]}=$a[1];
			$popList{$a[1]}++;
		}
	}
	close POP;
}

open OUT, ">$out";
my $count;
foreach my $pop (sort keys %popList){
	$count++;
	if ($count ==1) {
		print OUT $pop;
	}else {
		print OUT "\t$pop";	
	}
}
print OUT "\n";
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
                foreach my $i ($NumColBad..$#a){
			if ($pop{$a[$i]}){
	                        $samples{$i}=$a[$i];
        	                push(@samples,$a[$i]);
			}
                }
        }else{
		my %h;
		my %alleles;
		foreach my $i ($NumColBad..$#a){
			if ($samples{$i}){
				unless ($a[$i] eq "NN"){
					my @tmp = split('',$a[$i]); 
					$h{$pop{$samples{$i}}}{$tmp[0]}++;
					$h{$pop{$samples{$i}}}{$tmp[1]}++;
					$alleles{$tmp[0]}++;
					$alleles{$tmp[1]}++;
				}
			}
		}
		if (keys %alleles ne 2){	
			next;
		}
		foreach my $pop (sort keys %popList){
			my $c;
			foreach my $allele (sort keys %alleles){
				$c++;
				if ($c ==2){
                                        print OUT ",";
                                }elsif ($c ==3){
					print OUT "-WARNING_MORE_THAN_2_ALLELES-(this script is fail)\t";
				}
				if ($h{$pop}{$allele}){
					print OUT "$h{$pop}{$allele}";
				}else{
					print OUT "0";
				}
			}
			print OUT "\t";
		}
		print OUT "\n";
	}
}
close IN;
