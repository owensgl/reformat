#!/usr/bin/perl

use warnings;
use strict;

#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $out = $ARGV[1]; #Prefix for outfile.
my $pop = $ARGV[2]; #Population file for each sample
my %pop;

my %samples;
my @samples;
my %popList;
my $Locicount=1;
my $NumColBad=2;

open (PARFILE1, "> $out.parentfile1.txt") or die "Could not open a file\n";
open (PARFILE2, "> $out.parentfile2.txt") or die "Could not open a file\n";
open (ADMIXFILE, "> $out.admixed.txt") or die "Could not open a file\n";
open (LOCI, "> $out.geneticmap.txt") or die "Could not open a file\n";

my %rom;
$rom{"I"} = "1";
$rom{"II"} = "2";
$rom{"III"} = "3";
$rom{"IV"} = "4";
$rom{"V"} = "5";
$rom{"VI"} = "6";
$rom{"VII"} = "7";
$rom{"VIII"} = "8";
$rom{"IX"} = "9";
$rom{"X"} = "10";
$rom{"XI"} = "11";
$rom{"XII"} = "12";
$rom{"XIII"} = "13";
$rom{"XIV"} = "14";
$rom{"XV"} = "15";
$rom{"XVI"} = "16";
$rom{"XVII"} = "17";
$rom{"XVIII"} = "18";
$rom{"XIX"} = "19";
$rom{"XX"} = "20";
$rom{"XXI"} = "21";
$rom{"XXII"} = "22";



if ($pop){
	open POP, $pop;
	while (<POP>){
		chomp;
		my @a = split (/\t/,$_);	
		$pop{$a[0]}=$a[1];
		$popList{$a[1]}++;
	}
	close POP;
}

open IN, $in;
while (<IN>) {}
my $locinum = ($.-1);
print PARFILE1 "$popList{'p1'}\n$locinum\n";
print PARFILE2 "$popList{'p2'}\n$locinum\n";
print ADMIXFILE "$popList{3}\n$locinum\n";
print "$locinum\n";

open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if (($a[0] eq "contig" ) or ($a[0] eq "CHROM")){
		print PARFILE1 "IND";
		print PARFILE2 "IND";
		print ADMIXFILE "IND";
                foreach my $i ($NumColBad..$#a){
                        $samples{$i}=$a[$i];
                        push(@samples,$a[$i]);
			if ($pop{$a[$i]} eq "p1"){
				print PARFILE1 ", $a[$i]";
			}
			elsif ($pop{$a[$i]} eq "p2"){
                                print PARFILE2 ", $a[$i]";
                        }
			elsif ($pop{$a[$i]} eq 3){
                                print ADMIXFILE ", $a[$i]";
                        }
                }
                print PARFILE1 "\n";
                print PARFILE2 "\n";
                print ADMIXFILE "\n";
        }else{
		print PARFILE1 "$a[0]_$a[1]";
                print PARFILE2 "$a[0]_$a[1]";
                print ADMIXFILE "$a[0]_$a[1]";
		print LOCI "$a[0]_$a[1], $a[1], 1";
		$Locicount++;
		foreach my $i ($NumColBad..$#a){
			if ($pop{$samples{$i}}){
				if ($pop{$samples{$i}} eq "p1"){
                       	        	print PARFILE1 ", $a[$i]";
                        	}
                        	elsif ($pop{$samples{$i}} eq "p2"){
                                	print PARFILE2 ", $a[$i]";
                        	}
                        	elsif ($pop{$samples{$i}} eq 3){
                                	print ADMIXFILE ", $a[$i]";
                        	}
			}
		}
                print PARFILE1 "\n";
                print PARFILE2 "\n";
                print ADMIXFILE "\n";
		print LOCI "\n";
	}
}
close PARFILE1;
close PARFILE2;
close ADMIXFILE;
close LOCI;

