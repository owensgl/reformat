#!/usr/bin/perl

use warnings;
use strict;

#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $pop = $ARGV[1]; #Population file for each sample
my $out = $ARGV[2]; #Prefix for outfile.

my %pop;

my %samples;
my @samples;
my %popList;
my $locicount=0;
my $NumColBad=2;
my $popnumber=0;

open (OUTFILE, "> $out.migrate.txt") or die "Could not open a file\n";
open (KEYFILE, "> $out.popkey.txt") or die "Could not open a file\n";

my %h;
my %alleles;
my %loci;



if ($pop){
	open POP, $pop;
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
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			if($pop{$samples{$i}}){
			    unless ($a[$i] eq "NN"){
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
}
my $pop_count = keys %popList;
print OUTFILE "H $pop_count $locicount $out\n";
foreach my $pop (sort keys %popList){
    my $doublepop = $popList{$pop} * 2;
    $popnumber++;
    print OUTFILE "$doublepop pop$popnumber\n";
    print KEYFILE "pop$popnumber\t$pop\n";
    foreach my $i (1..$locicount){
		print OUTFILE "$i\t";
		my $allelecount = 0;
		my $c = 0;
        foreach my $allele (sort keys %{$alleles{$i}}){
            $c++;
			if ($c ==2){
                print OUTFILE "\t";
                	}
            elsif ($c ==3){
				print "-WARNING_MORE_THAN_2_ALLELES-(this script is fail)\t";
			}
			if ($h{$i}{$pop}{$allele}){
			    $allelecount += $h{$i}{$pop}{$allele};
				print OUTFILE "$allele\t$h{$i}{$pop}{$allele}";
			}else{
			    print OUTFILE "$allele\t0";
			}
		}
		print OUTFILE "\t$allelecount\n";
    }
}

close OUTFILE;

