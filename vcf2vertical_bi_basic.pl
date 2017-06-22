#!/bin/perl
use warnings;
use strict;
use File::Basename;

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
                if($line=~m/^#CHROM/){
                                print "CHROM\tPOS";
                                foreach my $i (9..$#fields){
                                        my $long = "$fields[$i]";
                                        my $name = $long;
                                        print "\t$name";
                                }
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
			my @alts = split(/,/, $alt);
			if (length($alt) > 1){next;}
                        if ((length($ref) > 1) or (length($alts[0]) > 1)){ #If its an indel, skip the line
		#		print STDERR "$pos\tSkipped because of ref or alt 1\n";
                                next;
                        }
			print "\n$chrome\t$pos";
			foreach(@fields){
				my @genotype = split (/:/, $_);
				if ($genotype[0] eq '.'){
					print "\tNN";
					next;
				}
				my @bases = split(/\//,$genotype[0]);
				print "\t";
				foreach my $i (0..1){
					if ($bases[$i] eq "0"){
						print "$ref";
					}elsif ($bases[$i] eq "1"){
						print "$alt";
					}else{
						print "N";
					}
				}
			}
		}
	}
}

