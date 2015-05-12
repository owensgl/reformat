#!/bin/perl
use warnings;
use strict;
use File::Basename;
my $min_AR2 = 0.75;
my $min_prob = 0.9;
#old VCF2VERTICAL had format from mpileup: GT:PL:DP:GQ
#THIS VERSION:    has format from GATK-UG: GT:AD:DP:GQ:PL
#GLO VERSION Sept2014: includes ./.:
while(<STDIN>){
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
			my $meta = "$chrome\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
			if($line=~m/^#/){
				print "CHROM\t$pos";
				foreach(@fields){
					my $long = "$_";
					my $name = basename($long,'.bam');
					print "\t$name";
				}
				print "\n";
				next;
			}
			my @infos = split(/;/,$info);
			$infos[0] =~ s/AR2=//g;
			my $AR2 = $infos[0];
                        if ($AR2 < $min_AR2){
                                next;
                        }
                        elsif ((length($ref) > 1) or (length($alt) > 1)){ #If its an indel, skip the line
				next;
                        }
			elsif ($alt eq '.'){
				print "$chrome\t$pos";
				if ($format eq "GT:DP"){
					foreach(@fields){
						my @genotype = split (/:/, $_);
						if ($genotype[1]){
							if ($genotype[1] eq '.'){
								print "\tN|N";
							}
							elsif ($genotype[1] >= 5){
								print "\t$ref$ref";
							}else{				
								print "\tN|N";
							}
						}else{
							print "\tN|N";
						}
					}
				}
			}
			else{
				print "$chrome\t$pos";
				foreach(@fields){
					my $fourbasename = "$_";
					my @a = split(/:/,$fourbasename);
					my @b = split(/,/,$a[2]);
					unless (($b[0] > $min_prob) or ($b[1] > $min_prob) or ($b[2] > $min_prob)){
						print "\tN|N";
						next;
					}
					my @alleles = split(/\|/,$a[0]);
					print "\t$alleles[0]|$alleles[1]";
#					if ($alleles[0] eq "0"){
#						print "\t$ref|";
#					}else{
#						print "\t$alt|";
#					}
#					if ($alleles[1] eq "0"){
#						print "$ref";
#					}else{
#						print "$alt";
#					}
				}
				print "\n";
			}
		}
	}
}

