#!/bin/perl
use warnings;
use strict;

#This script takes a .iprscan file and converts it to a annotation file for ermineJ

my $in = $ARGV[0]; #.iprscan file
my %namehash;
my %GOhash;
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
	my $ID = $a[0];
	my $name = $a[5];
	$namehash{$ID} = $name;
#	print "$ID\t$#a\n";
	my $info = $a[$#a];
	my @dat = split(/ /,$info);
	foreach my $b (@dat){
		$b =~ s/\(//g;
		$b =~ s/\)//g;
		$b =~ s/\,//g;
		if ($b =~ /GO:/){
			$GOhash{$ID}{$b}++;
		}
	}
}
foreach my $ID (sort keys %namehash){
	print "\n$ID\t$ID\t$namehash{$ID}\t";
	my $counter;
	foreach my $GO ( keys %{ $GOhash{$ID} } ) {
		if ($counter){
			print "|$GO";
		}else{
			print "$GO";
			$counter++;
		}
	}
}
