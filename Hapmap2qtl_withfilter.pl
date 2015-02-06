#!/usr/bin/perl

#GLO Jan 2015
#This script takes in a hapmap file, filters it for heterozygosity, minor allele frequency and coverage, then outputs in R/qtl format.

#Use flags with input to specify  --Infile, --Outfile, --MaxHet, --MinHet, --MaxMaf, --MinMaf and --MinCov.
#Use flag "--FixMinor True" to convert minor allele calls to heterozygote calls.

use warnings;
use strict;
use Getopt::Long;
use lib '/home/owens/bin/pop_gen/'; #For GObox server
my %t;
$t{"N"} = "NN";
$t{"A"} = "AA";
$t{"T"} = "TT";
$t{"G"} = "GG";
$t{"C"} = "CC";
$t{"W"} = "TA";
$t{"R"} = "AG";
$t{"M"} = "AC";
$t{"S"} = "CG";
$t{"K"} = "TG";
$t{"Y"} = "CT";

my %args;

#Input variables
my $in;
my $out;
my $maxhet = 1;
my $minhet = 0;
my $maxmaf = 1;
my $minmaf = 0;
my $mincov = 0;
my $fixminor = "false";

GetOptions("Infile=s" => \$in,
		"Outfile=s" => \$out,
		"MaxHet=f" => \$maxhet,
		"MinHet=f" => \$minhet,
		"MaxMaf=f" => \$maxmaf,
		"MinMaf=f" => \$minmaf,
		"MinCov=f" => \$mincov,
		"FixMinor=s" => \$fixminor);

unless (($in) and ($out)){
	die ("ERROR: Must specific '--Infile = filename.hmp', --Outfile = filename.txt\n" );
}

print "This script is taking in $in, filtering for $minhet < Het < $maxhet, $minmaf < MAF < $maxmaf, Coverage > $mincov, and printing to $out\n";
if ($fixminor eq "true"){
	print "It is also converting minor allele calls to heterozygote calls\n";
}

#Pick up the number of bad columns without genotype data
require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

open IN, $in;
open OUT, (">$out");
my %samples;
my @samples;
#my %calls;
while (<IN>){
	chomp;
	my $line = $_;
	my @a = split(/\t/, $line);
	
	if ($. == 1){
		print OUT "id,";
		foreach my $i ($badcolumns..$#a){
			print OUT ",$a[$i]";
		}
		
	}else{
		next if /^\s*$/;
		my $good_count = 0;
		my $allele_count = 0;
		my $Hetcount = 0;
		my %total_alleles;
		my $sample_count = 0;
		my $coverage_check;
		my $maf_check;
		my $het_check;
		my $b1;	
		my $b2;
		foreach my $i ($badcolumns..$#a){
			if ($iupac_coding eq "TRUE"){
				$a[$i] = $t{$a[$i]};
				$sample_count++;
			}
			unless ($a[$i] eq "NN"){
				$good_count++;
				$allele_count+=2;
				my @bases = split(//, $a[$i]);
				$total_alleles{$bases[0]}++;
				$total_alleles{$bases[1]}++;
				if ($bases[0] ne $bases[1]){
					$Hetcount++;
				}
			}
		}
		if (($good_count/$sample_count) > $mincov){
			$coverage_check++;
		}
		if ((($Hetcount/$good_count) > $minhet) and (($Hetcount/$good_count) < $maxhet)){
			$het_check++;
		}
		if (keys %total_alleles == 2){
			my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
			$b1 = $bases[1]; #major
			$b2 = $bases[0]; #minor
			if ((($total_alleles{$bases[0]}/$allele_count) > $minmaf) and (($total_alleles{$bases[0]}/$allele_count) < $maxmaf)){
				$maf_check++;
			}
			if (($coverage_check) and ($het_check) and ($maf_check)){
				print OUT "\n$a[0],1";
				foreach my $i ($badcolumns..$#a){
					my @bases = split(//, $a[$i]);
					if ($bases[0] eq "N"){
						print OUT ",-";
					}elsif ($bases[0] ne $bases[1]){
						print OUT ",H";
					}elsif ($bases[0] eq $b1){
						print OUT ",A";
					}elsif ($bases[0] eq $b2){
						unless ($fixminor eq "true"){
							print OUT ",B";
						}else{
							print OUT ",H";
						}
					}else{
						die ("SOMETHING WENT WRONG\n");
					}
				}
			}
		}
	}
}
close OUT;
close IN;
