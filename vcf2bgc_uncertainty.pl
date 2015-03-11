#!/bin/perl
use warnings;
use strict;
use File::Basename;

#Usage: perl vcf2bgc_uncertainty.pl input.vcf outfilename population_file.txt

my $mincoverage = 0.25; #Percent of samples that need to have bases called for the script to output the site.
my $in = $ARGV[0]; #Infile vcf 
my $out = $ARGV[1]; #Prefix for outfile.
my $pop = $ARGV[2]; #Population file for each sample


open (PARFILE1, "> $out.parentfile1.txt") or die "Could not open a file\n";
open (PARFILE2, "> $out.parentfile2.txt") or die "Could not open a file\n";
open (ADMIXFILE, "> $out.admixed.txt") or die "Could not open a file\n";
open (LOCI, "> $out.geneticmap.txt") or die "Could not open a file\n";


my %samples;
my @samples;
my %popList;
my $locicount=-1;
my $NumColBad=2;
my %pop;


open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	if (($a[1] ne "P1") and ($a[1] ne "P2")){
		$popList{$a[1]}++;
	}
}
close POP;

my %samplename;
my $samplecount;
open IN, $in;

while(<IN>){
	if(eof()){
		#print "\n";	
	}
	else{
		my $line = "$_";
		chomp $line;
		my @fields = split /\t/,$line;
	    	if($line=~m/^##/){
			next;
		}
		elsif($fields[7]=~m/^NCC/) {
			next;
		} 
		else{
			my $chrome = shift @fields;
			my $pos =    shift @fields;
			my $id =     shift @fields;
			my $ref =    shift @fields;
			my $alt =    shift @fields;
			my $qual =   shift @fields;
			my $filter = shift @fields;
			my $info =   shift @fields;
			my $format = shift @fields;
			my $mq = "NA";
			if($info=~m/MQ=(\d+)/){
				$mq = "$1";	
			}
			my $meta = "$chrome\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
			if($line=~m/^#/){
				foreach my $i (0..$#fields){
					my $long = "$fields[$i]";
					my $name = basename($long,'.bam');
					$samplename{$i} = $name;
					$samplecount++;
				}
		
			}
            		elsif ((length($ref) > 1) or (length($alt) > 1)){ #If its an indel, skip the line
				next;
            		}
			else{
				my @infos = split(/;/,$info);
				my @AN;
				my $popnumber = 0;
				foreach my $data (@infos){
					if($data=~m/^AN/){
						@AN = split(/=/,$data);
					}
				}
				my $coverage = $AN[1] / (2* $samplecount);
				if ($coverage >= $mincoverage){
					$locicount++;
					print LOCI "$locicount\t$chrome\t$pos\n";
					print PARFILE1 "locus $locicount\n";
					print PARFILE2 "locus $locicount\n";
					print ADMIXFILE "locus $locicount\n";
					foreach my $i (0..$#fields){
						my @tmp = split (/:/,$fields[$i]);
						my @readcounts = split (/,/,$tmp[1]);
						if 	($pop{$samplename{$i}} eq "P1"){
							print PARFILE1 "$readcounts[0]\t$readcounts[1]\n";
						}elsif ($pop{$samplename{$i}} eq "P2"){
							print PARFILE2 "$readcounts[0]\t$readcounts[1]\n";
						}
					}
					foreach my $hybpop (sort keys %popList){
						print ADMIXFILE "pop $popnumber\n";
						foreach my $i (0..$#fields){
							my @tmp = split (/:/,$fields[$i]);
							my @readcounts = split (/,/,$tmp[1]);
							if 	($pop{$samplename{$i}} eq "$hybpop"){
								print ADMIXFILE "$readcounts[0]\t$readcounts[1]\n";
							}
						}
						$popnumber++;
					}
				}
			}
		}
	}
}
