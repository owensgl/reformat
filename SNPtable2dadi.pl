#This script takes tab format and converts it to dadi input format
#It only takes SNPs that are surrounded by invariant sites
#It requires all bases input.
#!/bin/perl
use warnings;
use strict;
use List::MoreUtils qw(uniq);
my $popfile = $ARGV[0];


my $NumColBad = 2;
my %pop;
my @long_poplist;


open POP, $popfile;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	push(@long_poplist, $a[1]);
}
close POP;
my @poplist = uniq @long_poplist;
my $current_chr;
my %n_alleles;
my %homo_base;
my @bases;
my $major;
my $minor;
my %h;
my %samples;
while (<STDIN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
        	foreach my $i ($NumColBad..$#a){
        		$samples{$i}=$a[$i];
        	}
		print "Reference\tAlternate\tAllele1\t";
		foreach my $pop (@poplist){
			print "$pop\t";
		}
		print "Allele2\t";
		foreach my $pop (@poplist){
			print "$pop\t";
		}
		print "Gene\tPosition";
	}else{
		my $chr = $a[0];
		my $pos = $a[1];
		my %alleles;
		unless($current_chr){
			$current_chr = $chr;
		}
		if ($current_chr ne $chr){
			undef(%n_alleles);
			undef(%homo_base);
			undef(@bases);
			undef($major);
			undef($minor);
			undef(%h);
			$current_chr = $chr;
		}
		foreach my $i ($NumColBad..$#a){
			if($pop{$samples{$i}}){
				if ($a[$i] eq "NN"){
					next;
				}
				my @tmp = split('',$a[$i]);
				$h{$pos}{$pop{$samples{$i}}}{$tmp[0]}++;
				$h{$pos}{$pop{$samples{$i}}}{$tmp[1]}++;
				$alleles{$tmp[0]}++;
				$alleles{$tmp[1]}++;
			}
		}
		if (keys %alleles == 1){
			$n_alleles{$pos} = 1;
			my @tmp = sort keys %alleles;
			$homo_base{$pos} = $tmp[0];
		}elsif (keys %alleles == 2){
			$n_alleles{$pos} = 2;
			@bases = sort { $alleles{$a} <=> $alleles{$b} } keys %alleles;
			$major = $bases[1];
			$minor = $bases[0];
		}else{
			next;
		}
		my $first = $pos-2;
		my $second = $pos-1;
		my $third = $pos;
		if (($n_alleles{$third}) and ($n_alleles{$second}) and ($n_alleles{$first})){
			if (($n_alleles{$third} == 1) and ($n_alleles{$second} == 2) and ($n_alleles{$first} == 1)){
				print "\n$homo_base{$first}$major$homo_base{$third}\t";
				print "$homo_base{$first}$minor$homo_base{$third}\t";
				print "$major\t";
				foreach my $pop (@poplist){
					if ($h{$second}{$pop}{$major}){
						print "$h{$second}{$pop}{$major}\t";
					}else{
						print "0\t";
					}
				}
				print "$minor\t";
				foreach my $pop (@poplist){
					if ($h{$second}{$pop}{$minor}){
						print "$h{$second}{$pop}{$minor}\t";
					}else{
						print "0\t";
					}
				}
				print "NA\t${current_chr}_$second";
			}
		}
	}
}
			

