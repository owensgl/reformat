#This script takes tab format and converts it to dadi input format
#It ignores the trinucleotides (i.e. does not produce bases around the SNP)
#It requires the SNP to be biallelic. 
#!/bin/perl
use warnings;
use strict;
use List::MoreUtils qw(uniq);
my $popfile = $ARGV[0];


my $NumColBad = 2;
my %pop;
my @long_poplist;

my $min_n = 10;
open POP, $popfile;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	if ($a[1] ne "ancestor"){
		push(@long_poplist, $a[1]);
	}
}
close POP;
my @poplist = uniq @long_poplist;

my %samples;
my %poplist;
while (<STDIN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
        	foreach my $i ($NumColBad..$#a){
        		$samples{$i}=$a[$i];
			if ($pop{$samples{$i}}){
				$poplist{$i} = $pop{$samples{$i}};
			}
        	}
		print "Reference\tAlternate\tAllele1\t";
		foreach my $pop (@poplist){
			print "$pop\t";
		}
		print "Allele2\t";
		foreach my $pop (@poplist){
			print "$pop\t";
		}
		print "Chrom\tPosition";
	}else{
		my $chr = $a[0];
		my $pos = $a[1];
		my %alleles;
		my %h;
		my %count;
		foreach my $i ($NumColBad..$#a){
			if($poplist{$i}){
				if ($a[$i] eq "NN"){
					next;
				}
				my @tmp = split('',$a[$i]);
				$h{$poplist{$i}}{$tmp[0]}++;
				$h{$poplist{$i}}{$tmp[1]}++;
				$alleles{$tmp[0]}++;
				$alleles{$tmp[1]}++;
				$count{$poplist{$i}}++;
			}
		}
		if (keys %alleles ne 2){ #Only use biallelic sites
			next;
		}
		#Check that there are atleast min_n per group
		unless($count{"ancestor"}){
			next;
		}
		if ($count{"ancestor"} <$min_n){
			next;
		}
		foreach my $popname (@poplist){
			unless($count{$popname}){
				goto SKIP;
			}
			if ($count{$popname} < $min_n){
				goto SKIP;
			}
		}

		if (keys %{$h{"ancestor"}} ne 1){ #If the ancestors is not fixed
			next;
		}
		my @ancestralallele = keys %{$h{"ancestor"}};
		my $ancestral = $ancestralallele[0];
                my @bases = sort { $alleles{$a} <=> $alleles{$b} } keys %alleles;
		
		my $derived;
		if ($ancestral eq $bases[0]){
			$derived = $bases[1];
		}else{
			$derived = $bases[0];
		}	
		foreach my $popname (@poplist){
			unless($h{$popname}{$derived}){
				$h{$popname}{$derived} = 0;
			}
			unless($h{$popname}{$ancestral}){
				$h{$popname}{$ancestral} = 0;
			}
		}
		print "\n-$derived-\t-$ancestral-\t$derived";
		foreach my $popname (@poplist){
			print "\t$h{$popname}{$derived}";
		}
		print "\t$ancestral";
                foreach my $popname (@poplist){
                        print "\t$h{$popname}{$ancestral}";
                }
		print "\t$chr\t$pos";
	}
	SKIP:
}
			

