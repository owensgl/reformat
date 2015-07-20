#!/bin/perl
use warnings;
use strict;

my $line = $ARGV[0];
my $label = $ARGV[1];

my $line_quarter = $line/4;
my $snp_number = 10;
my @random_set;
my %seen;
for (1..$snp_number) {
    my $candidate = int rand($line_quarter);
    redo if $seen{$candidate}++;
    push @random_set, $candidate;
}

my $printcounter = 0;
my $firstprint;
while(<STDIN>){
	chomp;
	my $quarter_number = ($. / 4)-.25;
	if ($seen{$quarter_number}){
		$printcounter = 4;
	}
	if ($printcounter){
		if ($_ =~ m/^@/){
			my @tmp = split(/ /, $_);
			if ($firstprint){
				print "\n$tmp[0]:$label $tmp[1]";
			}else{
				print "$tmp[0]:$label $tmp[1]";
				$firstprint++;
			}
		}else{
			print "\n$_";
		}
		$printcounter--;
	}
}
