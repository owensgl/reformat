#!/bin/perl
#This script takes a snp table and filters out sites that are only in one population
#GLO July 14, 2015
use warnings;
use strict;

my $pop = $ARGV[0];
my %pop;
open POP, $pop;
while (<POP>){
        chomp;
        my @a = split (/\t/,$_);
        $pop{$a[0]}=$a[1];
}
close POP;

my %samplepop;
while (<STDIN>){
	my %poplist;
	chomp;
	my @a = split(/\t/,$_);
	if ($. == 1){
		print "$a[0]\t$a[1]";
		foreach my $i (2..$#a){
			if ($pop{$a[$i]}){
				$samplepop{$i} = $pop{$a[$i]};
				print "\t$a[$i]";
			}
		}
	}else{
		my @print_list;
		foreach my $i (2..$#a){
			if ($samplepop{$i}){
				push(@print_list, $a[$i]);
				if ($a[$i] ne "NN"){
					$poplist{$samplepop{$i}}++;
				}
			}
		}
		my $size = scalar keys %poplist;
#		print "$a[0]\t$a[1]\t$size\n";
		if ($size > 1){
			print "\n$_";
#		}else{
#			print "\n$a[0]\t$a[1]\tSKIPPING";
		}
	}
}
