#!/bin/perl

use warnings;
use strict;
#USAGE: cat file.vcf | perl THISSCRIPT.pl map.txt > newfile.vcf
my $map = $ARGV[0]; #In this, the chr is first col, bp is second, cm is third.
#/home/owens/ref/HanXRQr1.0-20151230.bp_to_cM.280x801.extradivisions.txt

#SNPfile piped in
my $tmp;
my %hash;
open MAP, $map;
while(<MAP>){
	chomp;
	my @a = split(/\t/,$_);
	if ($. ne "1"){
		if ($a[2] ne "NA"){
			my $chrom = $a[0];
			$chrom =~ s/"//g;
			$hash{$chrom}{$a[1]} = $a[2];
		}
	}
}
close MAP;

my $first_line;
while(<STDIN>){
	chomp;
	my $line = $_;
	my @a = split(/\t/,$line);
	if ($_ =~ m/^##/){
	}elsif ($_ =~ m/^#/){
	}else{
		my $chrom = $a[0];
		if (($chrom =~ m/00/) or ($chrom =~ m/CP/) or ($chrom =~ m/MT/)){
			next;
		}
		my $bp = $a[1];
		my $ref = $a[3];
		my $alt = $a[4];
		my $chr_n = $chrom;
		$chr_n =~ s/HanXRQChr//g;
		my $name = "$chrom.$bp";
		my $previous_site;
		my $before_site;
		my $after_site;
		my $loci_cM;
		foreach my $site (sort  {$a <=> $b} keys %{$hash{$chrom}}){
			if ($site > $bp){
				if ($previous_site){
					$before_site = $previous_site;
					$after_site = $site;
					goto FOUNDPOS;
				}else{
					$loci_cM = "NA";
					goto BADSITE;
				}
			}
			$previous_site = $site;
		}
		$loci_cM = "NA";
		goto BADSITE;
		FOUNDPOS:
		my $cM_range = $hash{$chrom}{$after_site} - $hash{$chrom}{$before_site};
		my $bp_range = $after_site - $before_site;
		my $percent_of_range = ($bp - $before_site)/$bp_range;
		$loci_cM = ($percent_of_range * $cM_range) + $hash{$chrom}{$before_site};
		
		BADSITE:
		if ($first_line){
			print "\n";
		}else{
			$first_line++;
		}
                print "$name $chr_n $loci_cM $bp $ref $alt";
	}
}
