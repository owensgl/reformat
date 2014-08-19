#!/bin/perl

use warnings;
use strict;

use lib '/home/owens/bin';

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

my %NT;
$NT{"A"} = "1";
$NT{"T"} = "2";
$NT{"C"} = "3";
$NT{"G"} = "4";


my $in = $ARGV[0];
my $pures = $ARGV[1];

require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

my $samplenumber;
my $NumLoci = 0;
my %data;
my $maxA;
my $NumIndivs;
my @samplename;
my %locusname;
my %type;

open PURE, $pures;
while (<PURE>){
	chomp;
	my @a = split (/\t/, $_);
	$type{$a[0]} = $a[1];
}
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/, $_);
	$maxA = $#a;
	$NumIndivs = ($#a - $badcolumns + 1);
	if ($. == 1){
		foreach my $i ($badcolumns..$#a){
			$samplename[$i] = $a[$i];
		}
	}else{
		$NumLoci++;
		$locusname{$NumLoci} = "$a[0]_$a[1]";
		foreach my $i ($badcolumns..$#a){
                        if ($iupac_coding eq "TRUE"){
                                $a[$i] = $t{$a[$i]};
                        }
                        unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
				my @bases = split(//, $a[$i]);
				$data{$i}{$NumLoci} = "$NT{$bases[0]}"."$NT{$bases[1]}";
			}else{
				$data{$i}{$NumLoci} = "0";
			}
		}
	}
}
close IN;
print "NumIndivs\t$NumIndivs\n";
print "NumLoci\t$NumLoci\n";
print "Digits\t1\n";
print "Format Lumped\n";
print "LocusNames";
foreach my $i (1..$NumLoci){
	print "\t$locusname{$NumLoci}";
}
print "\n";
foreach my $i ($badcolumns..$maxA){
	my $samplenumber = ($i - $badcolumns + 1);
	print "$samplenumber";
	if ($type{$samplename[$i]}){
		my $z = ($type{$samplename[$i]} - 1);
		print "\tz$z";
	}
	foreach my $j (1..$NumLoci){
		print "\t$data{$i}{$j}";
	}
	print "\n";
}
	
