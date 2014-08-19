#!/usr/bin/perl

use warnings;
#use strict;

#Prints out each admixed population as it's own file.
#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $out = $ARGV[1]; #Prefix for outfile.
my $pop = $ARGV[2]; #Population file for each sample
my %pop;

my %samples;
my @samples;
my %popList;
my $NumColBad=2;


open (PARFILE1, "> $out.introgress.parentfile1.txt") or die "Could not open a file\n";
open (PARFILE2, "> $out.introgress.parentfile2.txt") or die "Could not open a file\n";
open (ADMIXFILE, "> $out.introgress.admixed.txt") or die "Could not open a file\n";
open (LOCI, "> $out.introgress.loci.txt") or die "Could not open a file\n";

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

my @parent1;
my @parent2;
my @admix;

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
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
        foreach my $i ($NumColBad..$#a){
            $samples{$i}=$a[$i];
            push(@samples,$a[$i]);
            if ($pop{$samples{$i}}){
                if ($pop{$samples{$i}} eq "p1"){
                    push(@parent1, $i);
                }elsif ($pop{$samples{$i}} eq "p2"){
                    push(@parent2, $i);
                }else {
                    push(@admix, $i);
                }
            }
        } 
        foreach my $i (0..$#admix){
            if ($i eq 0){
                print ADMIXFILE "$pop{$samples{$admix[$i]}}";
            }
            else {
                print ADMIXFILE ",$pop{$samples{$admix[$i]}}";
            }
        }
        print ADMIXFILE "\n";
        foreach my $i (0..$#admix){
            if ($i eq 0){
                print ADMIXFILE "$a[$admix[$i]]";
            }
            else{
                print ADMIXFILE ",$a[$admix[$i]]";
            }
        }
        print ADMIXFILE "\n";
        print LOCI "Locus,type\n";
    }else{
		my $chr = $a[0];
		my $pos = $a[1];
		print LOCI "$chr"."_$pos,C\n";

		foreach my $i (0..$#admix){
		    my @tmp = split('',$a[$admix[$i]]);
            for (@tmp) {
                s/N/NA/
            }
            if ($i eq 0){
                print ADMIXFILE "$tmp[0]/$tmp[1]";
            }
            else {
                print ADMIXFILE ",$tmp[0]/$tmp[1]";
            }
        }
        print ADMIXFILE "\n";
        
		foreach my $i (0..$#parent1){
		    my @tmp = split('',$a[$parent1[$i]]);
            for (@tmp) {
                s/N/NA/
            }
            if ($i eq 0){
                print PARFILE1 "$tmp[0]/$tmp[1]";
            }
            else {
                print PARFILE1 ",$tmp[0]/$tmp[1]";
            }
        }
        print PARFILE1 "\n";


        foreach my $i (0..$#parent2){
            my @tmp = split('',$a[$parent2[$i]]);
            for (@tmp) {
                s/N/NA/
            }
            
            if ($i eq 0){
                print PARFILE2 "$tmp[0]/$tmp[1]";
            }
            else{
                print PARFILE2 ",$tmp[0]/$tmp[1]";
            }
        }		 
        print PARFILE2 "\n"; 
    }
}

close PARFILE1;
close PARFILE2;
close LOCI;
close IN;
close ADMIXFILE;
