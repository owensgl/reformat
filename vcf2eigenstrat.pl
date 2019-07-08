#!/usr/bin/perl

#This takes a vcf file and outputs eigenstrat format
#Currently gives dummy values for genetic distance
#Recodes chromosomes as numbers

use warnings;
use strict;

my %samples;
my %pop;
my %samplepop;
my %poplist;
my $chr_start = "Ha412HOChr";

my $pop = $ARGV[0];
my $out = $ARGV[1];


open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	$poplist{$a[1]}++;
}
close POP;




open (GENOFILE, "> $out.geno") or die "Could not open a file\n";
open (SNPFILE, "> $out.snp") or die "Could not open a file\n";
open (INDFILE, "> $out.ind") or die "Could not open a file\n";

my $first_line;
while (<STDIN>){
	chomp;
	if ($_ =~ m/##/){next;}

	my @a = split (/\t/,$_);
  	if ($_ =~ m/#/){
  		foreach my $i (9..$#a){ #Get sample names for each column
        		if ($pop{$a[$i]}){
        			$samplepop{$i} = $pop{$a[$i]};
        			print INDFILE "$a[$i]\tU\t$pop{$a[$i]}\n";
        		}
        	}

	}else{
		my $snpname = $a[0]."-"."$a[1]";
		my $chr = $a[0];
		$chr =~ s/$chr_start//g;
		my $pos = $a[1];
		my $ref = $a[3];
		my $alt = $a[4];
		if ($alt =~ m/\,/){next;} #Skip multiallelic sites	
		if ($first_line){
			print GENOFILE "\n";
			print SNPFILE "\n";
		}else{
			$first_line++;
		}
		foreach my $i (9..$#a){
			if ($samplepop{$i}){
				if (($a[$i] eq '.') or ($a[$i] eq './.')){
					print "9";
				}else{
					my @fields = split(/:/,$a[$i]);
					my @genos = split(/\//,$fields[0]);
					if (($fields[0] eq '.') or ($fields[0] eq './.')){
						print GENOFILE "9";
						next;
					}
					my $sum = $genos[0] + $genos[1];
					print GENOFILE "$sum";
				}
			}
		}
		print SNPFILE "$snpname\t$chr\t0.0\t$pos\t$ref\t$alt";
	}
}
