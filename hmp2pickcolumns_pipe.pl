#!/usr/bin/perl
use warnings;
use strict;
use lib '/home/owens/bin/pop_gen/'; #For GObox server


my $list = $ARGV[0]; # what you want

open LIST, "$list";

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

#require "countbadcolumns.pl"; #Identify the number of columns before genotype data starts
#my ($iupac_coding, $badcolumns) = count_bad_columns($in);
#$. = 0;
my $badcolumns = 11;
while (<STDIN>){
	chomp;
	my @a = split(/\t/, $_);
	if ($. == 1){
		print "$a[0]";
		foreach my $i (1..($badcolumns-1)){
			print "\t$a[$i]";
		}foreach my $i ($badcolumns..$#a){
			$good{$i} = $a[$i];
			if($okay_samples{$a[$i]}){
				print "\t$a[$i]";
			}
		}
		print "\n";
	}
	else{
		print "$a[0]";
                foreach my $i (1..($badcolumns-1)){
                        print "\t$a[$i]";
		}foreach my $i ($badcolumns..$#a){
			if($okay_samples{$good{$i}}){
				print "\t$a[$i]";
			}
		}
		print "\n";
	}
}




