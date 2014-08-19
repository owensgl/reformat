#!/usr/bin/perl

use warnings;
use strict;

#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $popfile = $ARGV[1]; #Population file for each sample
my $out = $ARGV[2]; #outfile

my %pop;

my %samples;
my @samples;
my %popList;
my $locicount=0;
my $NumColBad=2;
my $popnumber=0;

open (OUT, "> $out") or die "Could not open a file\n";


my %het;
my %h;
my %alleles;
my %loci;
my %lociname;
my %coverage;

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
        print OUT "loc\tCHROM\tPOS\t";
		foreach my $eachpop (sort keys %popList){ 
			print OUT "$eachpop"."_n\t$eachpop"."_2n\t$eachpop"."_allele_freq\t$eachpop"."_allele_num\t$eachpop"."_heterozygosity\t";
		}
		print OUT "\n";       
    }else{
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			if($pop{$samples{$i}}){
			    	unless ($a[$i] eq "NN"){
		            my @tmp = split('',$a[$i]); 
				    $h{$pop{$samples{$i}}}{$tmp[0]}++;
				    $h{$pop{$samples{$i}}}{$tmp[1]}++;
				    $alleles{$tmp[0]}++;
				    $alleles{$tmp[1]}++;
				    $loci{$samples{$i}}{"1"} = $tmp[0];
				    $loci{$samples{$i}}{"2"} = $tmp[1];
				    $coverage{$pop{$samples{$i}}}++;
				    unless ($tmp[0] eq $tmp[1]){
				    		$het{$pop{$samples{$i}}}++;
				    }
			    }
			}
		}
		print OUT "$a[0]"."_$a[1]\t$a[0]\t$a[1]\t";
		foreach my $eachpop (sort keys %popList){
			my $first;
			foreach my $allele (sort keys %alleles){
				unless ($first) {
					$first++;
					if ($h{$eachpop}{$allele}){
						my $n = $coverage{$eachpop};
						my $two_n = (2* $coverage{$eachpop});

						print OUT "$n\t"; #n
						print OUT "$two_n\t"; #2n
						my $major_freq = $h{$eachpop}{$allele}/($two_n);
						print OUT "$major_freq\t"; #Major allele frequency
						print OUT "$h{$eachpop}{$allele}\t"; #Number of major allele calls
						if ($het{$eachpop}){
							my $Heterozygosity = $het{$eachpop}/$coverage{$eachpop};
							print OUT "$Heterozygosity\t";
						} else {
							print OUT "0\t";
						}
					} else {
						$first++;
						my $two_n = (2* $coverage{$eachpop});
						print OUT "$coverage{$eachpop}\t$two_n\t0\t0\t0\t";
					} 
				}
			}
		}
		print OUT "\n";
    }
}

close OUT;
close IN;


