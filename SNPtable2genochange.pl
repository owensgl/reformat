#!/usr/bin/perl

use warnings;
#use strict;

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

sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty array\n");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}
# $std = &stdev(\@array);




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
	my @nucleotides;
	my %coverage;
	my %geno;
	my %het;
	my %h;
	my %alleles;
	my %loci;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
        foreach my $i ($NumColBad..$#a){
        		$samples{$i}=$a[$i];
        		push(@samples,$a[$i]);
        }
        print OUT "loc\tCHROM\tPOS\t";
		foreach my $eachpop (sort keys %popList){ 
			print OUT "$eachpop"."_AA\t$eachpop"."_aa\t$eachpop"."_Aa\t$eachpop"."_total\t";
		}
		foreach my $eachpop (sort keys %popList){ 
			print OUT "$eachpop"."_std\t";
		}
		print OUT "\n";       
    }else{
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			if($pop{$samples{$i}}){
			    	unless ($a[$i] eq "NN"){
		            my @tmp = split('',$a[$i]); 
		            $geno{$pop{$samples{$i}}}{$a[$i]}++;
				    $h{$pop{$samples{$i}}}{$tmp[0]}++;
				    $h{$pop{$samples{$i}}}{$tmp[1]}++;
					push(@nucleotides,$tmp[0]);
					push(@nucleotides,$tmp[1]);
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
		my %unique = ();
		foreach my $item (@nucleotides)
		{
    			$unique{$item} ++;
		}
		my @uniq_nucleotides = keys %unique;
		if ($#uniq_nucleotides == 1) { #If the site is not monomorphic in the populations selected.
			my @genotypes;
			$genotypes[0] = "$uniq_nucleotides[0]$uniq_nucleotides[0]";
			$genotypes[1] = "$uniq_nucleotides[1]$uniq_nucleotides[1]";
			print OUT "$a[0]"."_$a[1]\t$a[0]\t$a[1]\t";
			foreach my $eachpop (sort keys %popList){
				foreach my $genotype (@genotypes){
					if ($geno{$eachpop}{$genotype}){
						#print OUT "$geno{$eachpop}{$genotype}\t";
						my $freq = $geno{$eachpop}{$genotype} / $coverage{$eachpop};
						print OUT "$freq\t";
					} else {
						print OUT "0\t";
					}
				}
				if ($het{$eachpop}){
					#print OUT "$het{$eachpop}\t";
					my $freq = $het{$eachpop} / $coverage{$eachpop};
					print OUT "$freq\t";
				} else {
					print OUT "0\t";
				}
				print OUT "$coverage{$eachpop}\t";
			}
			foreach my $i ($NumColBad..$#a){
    				if($pop{$samples{$i}}){
			   	 	unless ($a[$i] eq "NN"){
			   	 		if ($a[$i] eq $genotypes[0]) {
			   	 			push (@{$pop{$samples{$i}}}, "1");
			 	   		} elsif ($a[$i] eq $genotypes[1]) {
			 	   			push (@{$pop{$samples{$i}}}, "-1");
			    			} else {
			    				push (@{$pop{$samples{$i}}}, "0");
			    			}
			    		}
				}
			}
			foreach my $eachpop (sort keys %popList){
				my $std = &stdev(\@{$eachpop});
				print OUT "$std\t";
			}
			print OUT "\n";	
    		}	    	
	}
}
close OUT;
close IN;


