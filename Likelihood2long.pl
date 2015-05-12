#!/usr/bin/perl

use strict;
use warnings;
#This script takes the likelihood input file and converts it to long format for R plotting

my %t;
$t{"Des1484"} = "Des";
$t{"des2458"} = "Des";
$t{"Sample-DES1476"} = "Des";
$t{"Ano1495"} = "Ano";
$t{"Sample-Ano1506"} = "Ano";
$t{"Sample-des1486"} = "Des";
$t{"Sample-Des2463"} = "Des";
$t{"Sample-desA2"} = "Des";
$t{"Sample-Goblinvalley"} = "Ano";
$t{"Sample-desc"} = "Des";
$t{"king141B"} = "Par";
$t{"king145B"} = "Par";
$t{"king147A"} = "Par";
$t{"King151"} = "Par";
$t{"king152"} = "Par";
$t{"King156B"} = "Par";
$t{"Sample-king1443"} = "Par";
$t{"Sample-king159B"} = "Par";
$t{"BOL1037"} = "Bol";
$t{"EXI2348"} = "Bol";
$t{"G111-14"} = "Bol";
$t{"ARG1805"} = "Arg";
$t{"ARG1820"} = "Arg";
$t{"btm10-5"} = "Arg";
$t{"RAR43"} = "Deb";
$t{"RAR57"} = "Deb";
$t{"btm30-4"} = "Deb";
$t{"RAR46"} = "Deb";
$t{"btm13-6"} = "Pra";
$t{"btm14-4"} = "Pra";
$t{"btm16-2"} = "Pra";
$t{"14TB-2"} = "Tex";
$t{"20TB-7"} = "Tex";
$t{"btm11-1"} = "Tex";
$t{"btm3-2"} = "Tex";
$t{"btm35-4"} = "Tex";
$t{"btm6-1"} = "Tex";
$t{"K111"} = "Tex";
$t{"TEX"} = "Tex";


my $in = $ARGV[0];
open IN, $in;
my %poplist;
while (<IN>){
	chomp;
	my @a = split(/\t/, $_);
	if ($. == 1){
		foreach my $i (4..$#a){
			$poplist{$i} = $a[$i];
		}
		print "chrom\tstart\tend\tmidpoint\tn_sites\tspecies\tsample\tZscore\tassignment";
	}else{
		my $chrom = $a[0];
		my $start = $a[1];
		my $end = $a[2];
		my $midpoint = ((($end - $start)/ 2) + $start);
		my $n_sites = $a[3];
		foreach my $i(4..$#a){
			my $species = $t{$poplist{$i}};
			my $sample = $poplist{$i};
			my @info = split(/:/, $a[$i]);
			my $Zscore = $info[1];
			my $assignment = $info[0];
			if ($assignment eq "NA"){
				$assignment = "Unknown";
				if ($Zscore eq "NA"){
					$assignment = "NA";
				}
			}
			print "\n$chrom\t$start\t$end\t$midpoint\t$n_sites\t$species\t$sample\t$Zscore\t$assignment";
		}
	}
}
		
