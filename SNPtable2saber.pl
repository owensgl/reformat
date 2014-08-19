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
my $locicount=-1;
my $NumColBad=2;
my @locilist;


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


foreach my $i (1..21){
	open (CHROMOUT$i, "> $out.chr$i.txt") or die "Could not open a file\n";
}
			
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
                foreach my $i ($NumColBad..$#a){
                        $samples{$i}=$a[$i];
                        push(@samples,$a[$i]);
                }
        }else{
		my %h;
		my %alleles;
		my %loci;
		$locicount++;
		my $chr = $a[0];
		my $pos = $a[1];
		$chr =~ s/group//g;
		$chrom = $rom{$chr};
		push(@locilist{$chrom}, $pos);
		#print LOCI "$locicount\t$rom{$chr}\t$pos\n";
		foreach my $i (1..21){
			if ($rom{$chr} eq $i){
				print CHROMOUT$i "$pos\t";
			}
		}
		print CHROMOUT$rom{$chr} "$pos\t";	

		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			unless ($a[$i] eq "NN"){
				my @tmp = split('',$a[$i]); 
				$h{$chrom}{$pos}{$pop{$samples{$i}}}{$tmp[0]}++;
				$h{$chrom}{$pos}{$pop{$samples{$i}}}{$tmp[1]}++;
				$alleles{$chrom}{$pos}{$tmp[0]}++;
				$alleles{$chrom}{$pos}{$tmp[1]}++;
				$loci{$chrom}{$pos}{$samples{$i}}{"1"} = $tmp[0];
				$loci{$chrom}{$pos}{$samples{$i}}{"2"} = $tmp[1];
			}
		}
	}
}
foreach my $i (1..21){
	print CHROMOUT$i "\n";
}
foreach my $i (1..21){ #for each chromosome
	foreach my $s (@samples){ #for each sample
		if ($pop{$s}){	#if it has a population
			if ($pop{$s} == "p1"){ #If that population is parent 1
				foreach my $position ($locilist{$i}){ #for each position in that chromosome
					if ($loci{$i}{$position}{$s}{"1"}){ #If there is a base call at that position for that individual
						my $counter == 0; #Sets counter at zero
						foreach my $allele (sort keys %{$alleles{$i}{$position}}){ #For each allele at that position
							if ($counter == 0){ #If this is the first allele
								if (($loci{$i}{$position}{$s}{"1"} == $allele) and ($loci{$i}{$position}{$s}{"2"} == $allele)){ #If both first and second position are the first allele
									print CHROMOUT$i "2\t"; #print out 2
								}elsif (($loci{$i}{$position}{$s}{"1"} == $allele) or ($loci{$i}{$position}{$s}{"2"} == $allele)){ #If either position is allele one (but not both)
									print CHROMOUT$i "1\t"; #print out 1
								}else{
									print CHROMOUT$i "0\t"; #print out 0
								}
							}
							$counter++; #Ticks the counter up one, so it only prints once
						}
					}else{
						print CHROMOUT$i "-99\t"; #print out 0
					}
				}
				print CHROMOUT$i "\n"; #Prints line end after each position
			}
		}
	}
}
			
foreach my $i (1..21){
	close CHROMOUT$i;
}

