#!/usr/bin/perl

use warnings;
use strict;

unless (@ARGV == 3) {die;}

my $in = $ARGV[0];
my $pop = $ARGV[1];
my $out = $ARGV[2];
my %pop;
my %snp_to_dig;
$snp_to_dig{"A"}='1';
$snp_to_dig{"T"}='2';
$snp_to_dig{"C"}='3';
$snp_to_dig{"G"}='4';
$snp_to_dig{"N"}='-9';

my %h;
my %samples;
my %cm;
my @samples;
my @loc;
my $lociNum;
if ($pop){
	open POP, $pop;
	while (<POP>){
		chomp;
		my @a = split (/\t/,$_);	
		$pop{$a[0]}=$a[1];
	}
	close POP;
}
open IN, $in;

while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1){
      		foreach my $i (3..$#a){
            		$samples{$i}=$a[$i];
                  	push(@samples,$a[$i]);
            	}
      	}else{
		$lociNum++;
		my $loc = "$a[0]\t$a[1]";
		push(@loc, $loc);
            	foreach my $i (3..$#a){
			my @tmp = split('',$a[$i]); 
        		$h{$samples{$i}}{$loc}{1}= $snp_to_dig{$tmp[0]};
        		$h{$samples{$i}}{$loc}{2}= $snp_to_dig{$tmp[1]};
		}
		$cm{$loc} = $a[2]; #Put in a script for putting in genetic location

	}
}
close IN;
open OUT, ">$out";
foreach my $loc (@loc){
	print OUT "\t$cm{$loc}";
}
print OUT "\n";
foreach my $s (@samples){
	if ($pop){
		if ($pop{$s}){
			print OUT "$s\t$pop{$s}";
			if ($pop{$s} eq "6"){
				print OUT "\t0";
			}else{
				print OUT "\t1";
			}
			foreach my $loc (@loc){
				print OUT "\t$h{$s}{$loc}{1}";
			}
			print OUT "\n";
			print OUT "$s\t$pop{$s}";
			if ($pop{$s} eq "6"){
				print OUT "\t0";
			}else{
				print OUT "\t1";
			}
			foreach my $loc (@loc){
				print OUT "\t$h{$s}{$loc}{2}";
			}
			print OUT "\n";
		}
	}else{
		print OUT "$s";
		foreach my $loc (@loc){
			print OUT "\t$h{$s}{$loc}";
		}
		print OUT "\n";
	}
}




