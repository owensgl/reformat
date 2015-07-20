#!/bin/perl
#This script takes a snp table and filters out sites that are only in one population
#GLO July 14, 2015
use warnings;
use strict;

my $pop = $ARGV[0];
my %pop;
my %poplist;
open POP, $pop;
while (<POP>){
        chomp;
        my @a = split (/\t/,$_);
        $pop{$a[0]}=$a[1];
}
close POP;

my %samplepop;
while (<STDIN>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		foreach my $i (2..$#a){
			if ($pop{$a[$i]}){
				$samplepop{$i} = $pop{$a[$i]};
			}
		}
		print "$_";
	}else{
		foreach my $i (2..$#a){
			if ($a[$i] ne "NN"){
				$poplist{$samplepop{$i}}++;
			}
		}
		my $size = scalar keys %poplist;
		if ($size > 1){
			print "\n$_";
		}
	}
}
