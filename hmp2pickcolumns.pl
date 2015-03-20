#!/usr/bin/perl
use warnings;
use strict;
use lib '/home/owens/bin/pop_gen/'; #For GObox server

unless (@ARGV == 3) {die "You must specify IN, List of samples with pop (only 1 and 2, OUT, Min number of individuals per pop.\n "}

my $in = $ARGV[0]; #large col table
my $list = $ARGV[1]; # what you want
my $out = $ARGV[2];

open LIST, "$list";
open OUT, ">", "$out";

my %okay_samples;
my %new_names;
my %col_sample;
my %good;
my %pop;
my %samples_covered;

while (<LIST>){
	chomp;
	my @a = split(/\t/, $_);
	$okay_samples{$a[0]}++;
}

require "countbadcolumns.pl"; #Identify the number of columns before genotype data starts
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;
#my $badcolumns = 11;
open IN, $in;
while (<IN>){
	chomp;
	my @a = split(/\t/, $_);
	if ($. == 1){
		print OUT "$a[0]";
		foreach my $i (1..($badcolumns-1)){
			print OUT "\t$a[$i]";
		}foreach my $i ($badcolumns..$#a){
			$good{$i} = $a[$i];
			if($okay_samples{$a[$i]}){
				print OUT "\t$a[$i]";
			}
		}
		print OUT "\n";
	}
	else{
		print OUT "$a[0]";
                foreach my $i (1..($badcolumns-1)){
                        print OUT "\t$a[$i]";
		}foreach my $i ($badcolumns..$#a){
			if($okay_samples{$good{$i}}){
				print OUT "\t$a[$i]";
			}
		}
		print OUT "\n";
	}
}
close IN;
close OUT;




