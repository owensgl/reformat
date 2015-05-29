#!/bin/perl
use warnings;
use strict;

#This script takes a .goa file and converts it to a annotation file for ermineJ

my $in = $ARGV[0]; #.goa file
my %hash;
my %genetype;
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
	my $name = $a[2];
	my $GO = $a[4];
	my $type = $a[9];
	$hash{$name}{$GO}++;
	$genetype{$name} = $type
}
print "ProbeName\tGeneSymbols\tGeneNames\tGOTerms";
foreach my $name(sort keys %hash){
	print "\n$name\t$name\t$genetype{$name}\t";
	my $counter;
	foreach my $GO ( keys %{ $hash{$name} } ) {
		if($counter){
			print "|$GO";
		}else{
			print "$GO";
		}
	$counter++;
	}
}
		
