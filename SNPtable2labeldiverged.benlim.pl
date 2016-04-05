#!/usr/bin/perl

#This requires there to be 20 of each parent. It looks for sites where the parents have different major alleles and then codes them as 0 or 1. 0 is the alphabetically early parent, 1 is the alphabetically later parent. 
use warnings;
use strict;

my $pop = $ARGV[0]; #Pop file with P1, P2, and H

my %pop;
my %poplist;
my %samplepop;
open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);
	if (($a[1] eq "Admix") or ($a[1] eq "H")){ next;} #Don't include hybrids in calculating parental major alleles;
	$pop{$a[0]}=$a[1];
	$poplist{$a[1]}++;
}
close POP;

my @pops = sort keys %poplist;
while (<STDIN>){
	chomp;
	my @a = split (/\t/, $_);
	if ($. == 1){
		foreach my $i(2..$#a){
			if ($pop{$a[$i]}){
				$samplepop{$i} = $pop{$a[$i]};
			}
		}
		print "$_";
	}else{
		next if /^\s*$/;
		my %bases;
		my %calls;
		my %total_alleles;
		foreach my $i (2..$#a){
			if ($samplepop{$i}){
				unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
					my @bases = split(//, $a[$i]);
					$total_alleles{$bases[0]}++;
					$total_alleles{$bases[1]}++;
					$bases{$samplepop{$i}}{$bases[0]}++;
					$bases{$samplepop{$i}}{$bases[1]}++;
					$calls{$samplepop{$i}}++;
					$calls{$samplepop{$i}}++;
				}
			}
		}
		unless (($calls{$pops[0]}) and ($calls{$pops[1]})){
			next;
		}
		if (($calls{$pops[0]} >= 40) and ($calls{$pops[1]} >= 40)){
			my %major_alleles;
			foreach my $pop (@pops){
				my @bases = sort { $bases{$pop}{$b} <=> $bases{$pop}{$a} } keys %{$bases{$pop}};	
				my $major = $bases[0];
				$major_alleles{$pop} = $major;
			}
			if ($major_alleles{$pops[0]} ne $major_alleles{$pops[1]}) { #If they have different major alleles;
				print "\n$a[0]\t$a[1]";
				foreach my $i (2..$#a){
					if ($a[$i] eq "NN"){
						print "\tNA";
					}elsif ($a[$i] eq "$major_alleles{$pops[0]}$major_alleles{$pops[0]}"){
						print "\t00";
					}elsif ($a[$i] eq "$major_alleles{$pops[1]}$major_alleles{$pops[1]}"){
						print "\t11";
					}else{
						print "\t01";
					}
				}
			}else{
				next;
			}
		}		
	}
}
