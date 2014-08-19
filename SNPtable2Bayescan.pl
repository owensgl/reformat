#!/usr/bin/perl

use warnings;
use strict;

unless (@ARGV == 3) {die;}

my $in = $ARGV[0];
my $pop = $ARGV[1];
my $out = $ARGV[2];

my @pops;
$pops[0]=1;
$pops[1]=2;

my %pop;
my %snpsBySite;
my $c=1;
my %h;
my %samples;
my @samples;
my @loc;
my $lociNum;

open POP, $pop;
while (<POP>){
	chomp;
	unless (/^ID/){
		my @a = split (/\t/,$_);
		$pop{$a[0]}=$a[1];
	}
}
close POP;

open IN, $in;
open OUT, ">$out"."_Loci2Numbers";
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($a[0]=~/^contig/){
      	foreach my $i (3..$#a){
      		$samples{$i}=$a[$i];
                  push(@samples,$a[$i]);
            }
      }else{
		$lociNum++;
	      my $loc = "$lociNum";
		print OUT "$loc\t$a[0]\t$a[1]\t$a[2]\n";
	      foreach my $i (3..$#a){
			my @tmp = split('',$a[$i]); 
			unless ($tmp[0] eq "N"){
				$h{$pop{$samples{$i}}}{$loc}{$tmp[0]}++;
    	              	$h{$pop{$samples{$i}}}{$loc}{"total"}++;
				$snpsBySite{$loc}{$tmp[0]} ++;
			}
			unless ($tmp[1] eq "N"){
			 	$h{$pop{$samples{$i}}}{$loc}{$tmp[1]}++;
				$h{$pop{$samples{$i}}}{$loc}{"total"}++;
				$snpsBySite{$loc}{$tmp[1]} ++;
			}	
		}
	}
}
close IN;
close OUT;
my $tmp =  keys %h;

open OUT, ">$out";
print OUT "[loci]=".($lociNum)."\n\n";
print OUT "[populations]=".$tmp."\n";

foreach my $pop (@pops){
	print OUT "\n[pop]=$pop\n";
	foreach my $loc (1..$lociNum){
		print OUT "$loc ".$h{$pop}{$loc}{"total"}." ";
		print OUT scalar keys %{$snpsBySite{$loc}};
		foreach my $base (sort keys %{$snpsBySite{$loc}} ){
			if ($h{$pop}{$loc}{$base}){
				print OUT " $h{$pop}{$loc}{$base}";
			}else{
				print OUT " 0";
			}
 		}
		print OUT "\n";
	}
}





























