#!/usr/bin/perl
use warnings;
use strict;

#Takes a SNP table, counts the amount of missing data in each sample, picks the top X samples with the most data per population, prints it out in fasta format.

my $snptable = $ARGV[0];
my $popfile = $ARGV[1];
my $perpop = 10; #Number of samples to print per population

my %x;
$x{"AG"} = "R";
$x{"GA"} = "R";
$x{"AA"} = "A";
$x{"TT"} = "T";
$x{"CC"} = "C";
$x{"GG"} = "G";
$x{"CT"} = "Y";
$x{"TC"} = "Y";
$x{"GC"} = "S";
$x{"CG"} = "S";
$x{"AT"} = "W";
$x{"TA"} = "W";
$x{"GT"} = "K";
$x{"TG"} = "K";
$x{"AC"} = "M";
$x{"CA"} = "M";
$x{"NN"} = "N";
my %pophash;
my %poplist;
my %poscount;
my %h;
my %samples;
my @loc;
open POP, $popfile;
while (<POP>){
	chomp;
	my @a = split(/\t/,$_);
	$pophash{$a[0]} = $a[1];
	$poplist{$a[1]}++;
}
close POP;
open SNP, $snptable;
while (<SNP>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		foreach my $i (2..$#a){
			$samples{$i} = $a[$i];
		}
	}else{
		my $loc = "$a[1]\t$a[2]";
		push (@loc, $loc);
		foreach my $i (2..$#a){
			$h{$samples{$i}}{$loc} = $a[$i];
			if ($a[$i] ne "NN"){
				#print "$samples{$i}\t$pophash{$samples{$i}}\n";
				$poscount{$pophash{$samples{$i}}}{$samples{$i}}++;
			}
		}
	}
}
close SNP;
#foreach my $ind (sort values %samples){
#	print "$poscount{$pophash{$ind}}{$ind}\n";
#}
#exit;
foreach my $pop (sort keys %poplist){
	my $counter;
	foreach my $ind (sort { $poscount{$pop}{$b} <=> $poscount{$pop}{$a} } keys %{$poscount{$pop}} ){
		$counter++;
		if ($counter <= 10){
			print ">$ind\n";
			foreach my $loc (@loc){
				print "$x{$h{$ind}{$loc}}";
			}
			print "\n";
		}
	}
}
