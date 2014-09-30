#!/usr/bin/perl

use warnings;
use strict;

#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $popfile = $ARGV[1]; #Population file for each sample
my $out = $ARGV[2]; #Prefix for outfile.

my %pop;

my %samples;
my @samples;
my %popList;
my $locicount=0;
my $NumColBad=2;
my $popnumber=0;

open (OUTFILE, "> $out.bayenv.txt") or die "Could not open a file\n";
open (POPKEY, "> $out.popkey.bayenv.txt") or die "Could not open a file\n";
open LOCINFO, "> $out.LocInfo.txt";

my %h;
my %alleles;
my %loci;
my %lociname;


if ($popfile){
	open POP, $popfile;
	while (<POP>){
		chomp;
		my @a = split (/\t/,$_);	
		$pop{$a[0]}=$a[1];
		$popList{$a[1]}++;
	}
	close POP;
}

open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
        	foreach my $i ($NumColBad..$#a){
                    	$samples{$i}=$a[$i];
                    	push(@samples,$a[$i]);
        	}
    	}else{
        	$locicount++;
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			if($pop{$samples{$i}}){
				unless ($a[$i] eq "NN"){
		            		my @tmp = split('',$a[$i]); 
				    	$h{$locicount}{$pop{$samples{$i}}}{$tmp[0]}++;
				    	$h{$locicount}{$pop{$samples{$i}}}{$tmp[1]}++;
				    	$alleles{$locicount}{$tmp[0]}++;
				    	$alleles{$locicount}{$tmp[1]}++;
#				    	$loci{$locicount}{$samples{$i}}{"1"} = $tmp[0];
#				    	$loci{$locicount}{$samples{$i}}{"2"} = $tmp[1];
			    	}
			}
		}
		my $c;
		foreach my $allele (sort keys %{$alleles{$locicount}}){
			$c++;
		}
		if ($c ==2){
               		print LOCINFO "$a[0]-$a[1]\n";
			foreach my $allele (sort keys %{$alleles{$locicount}}){
				foreach my $eachpop (sort keys %popList){
		        		if ($h{$locicount}{$eachpop}{$allele}){
		            			print OUTFILE "$h{$locicount}{$eachpop}{$allele}\t";
		        		} else {
		            			print OUTFILE "0\t";
		        		}   
		    		}
		    		print OUTFILE "\n";
			}
		}    
    	}
}
my $popcount = 1;
foreach my $eachpop (sort keys %popList){
    print POPKEY "$popcount\t"."$eachpop\n";
}


