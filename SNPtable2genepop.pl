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

open (OUTFILE, "> $out.gen") or die "Could not open a file\n";


my %h;
my %alleles;
my %loci;
my %lociname;

#SNP to numeric converter
my %snp;
$snp{"A"} = "001";
$snp{"C"} = "002";
$snp{"G"} = "003";
$snp{"T"} = "004";
$snp{"N"} = "000";

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
		my $locinum = ($.-1);
		$lociname{$locinum} = "$a[0]_$a[1]";
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			if($pop{$samples{$i}}){
		        my @tmp = split('',$a[$i]); 
				$h{$locinum}{$pop{$samples{$i}}}{$tmp[0]}++;
				$h{$locinum}{$pop{$samples{$i}}}{$tmp[1]}++;
				$alleles{$locinum}{$tmp[0]}++;
				$alleles{$locinum}{$tmp[1]}++;
				$loci{$locinum}{$samples{$i}}{"1"} = $tmp[0];
				$loci{$locinum}{$samples{$i}}{"2"} = $tmp[1];
			}
		}
    }
}
my $pop_count = keys %popList;
print OUTFILE "Genepop formatted data\n";
foreach my $i (1..$locicount){
    print OUTFILE "$lociname{$i}\n";
}
foreach my $eachpop (sort keys %popList){
    print OUTFILE "Pop";
    open POP, $popfile;
	while (<POP>){
	    chomp;
	    my @a = split (/\t/,$_);
	    if ($pop{$a[0]} eq $eachpop){
	    	print OUTFILE "\n$pop{$a[0]},\t"; 
	        foreach my $i (1..$locicount){
                	print OUTFILE "$snp{$loci{$i}{$a[0]}{1}}";
                	print OUTFILE "$snp{$loci{$i}{$a[0]}{2}}\t";
            	}
            }
    }
    close POP;
    print OUTFILE "\n";
}

