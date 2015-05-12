#!/bin/perl
use warnings;
use strict;
use File::Basename;
while(<STDIN>){
	my $line = "$_";
	chomp $line;
	if($line=~m/^##/){
		print "$line\n";
	}
	else{
		if($line=~m/^#/){
			print "$line";
			goto NEXT;
		}
		my @fields = split /\t/,$line;
		my @alts = split(/,/,$fields[4]);
		foreach my $i (0.. $#alts){
			if ($alts[$i] eq '.'){
				goto NEXT;
			}
			if (length($alts[$i]) ne 1){
				goto NEXT;
			}
		}
		print "\n$line";
	}
	NEXT:
}
