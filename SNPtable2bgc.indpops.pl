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
my $locicount=-1;
my $NumColBad=2;


open (PARFILE1, "> $out.parentfile1.txt") or die "Could not open a file\n";
open (PARFILE2, "> $out.parentfile2.txt") or die "Could not open a file\n";
#open (ADMIXFILE, "> $out.admixed.txt") or die "Could not open a file\n";
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
foreach my $eachpop (sort keys %popList){
    if (($eachpop ne "p1") and ($eachpop ne "p2")){
        open ($eachpop, "> $out.admixed.$eachpop.txt") or die "Could not open a file\n";
    }
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
		my $popnumber=-1;
		my $chr = $a[0];
		my $pos = $a[1];
		$chr =~ s/group//g;
		print LOCI "$locicount\t$rom{$chr}\t$pos\n";
		foreach my $i ($NumColBad..$#a){
			#print "$samples{$i}\n";
			unless ($a[$i] eq "NN"){
			    if ($pop{$samples{$i}}){
				    my @tmp = split('',$a[$i]); 
				    $h{$pop{$samples{$i}}}{$tmp[0]}++;
				    $h{$pop{$samples{$i}}}{$tmp[1]}++;
				    $alleles{$tmp[0]}++;
				    $alleles{$tmp[1]}++;
				    $loci{$samples{$i}}{"1"} = $tmp[0];
				    $loci{$samples{$i}}{"2"} = $tmp[1];
			    }
			}
		}
		foreach my $eachpop (sort keys %popList){
            if (($eachpop ne "p1") and ($eachpop ne "p2")){
                print $eachpop "locus_$locicount\n";
            }
        }
		foreach my $eachpop (sort keys %popList){
            if ($eachpop eq "p1"){
				my $c;
				print PARFILE1 "locus_$locicount\n";
				foreach my $allele (sort keys %alleles){
					$c++;
					if ($c ==2){
                               		        print PARFILE1 " ";
                                	}elsif ($c ==3){
						print "-WARNING_MORE_THAN_2_ALLELES-(this script is fail)\t";
					}
					if ($h{$eachpop}{$allele}){
						print PARFILE1 "$h{$eachpop}{$allele}";
					}else{
					print PARFILE1 "0";
					}
				}
				print PARFILE1 "\n";
			}
            elsif ($eachpop eq "p2"){
				my $c;
                print PARFILE2 "locus_$locicount\n";
                foreach my $allele (sort keys %alleles){
                    $c++;
                    if ($c ==2){
                        print PARFILE2 " ";
                    }elsif ($c ==3){
                        print "-WARNING_MORE_THAN_2_ALLELES-(this script is fail)\t";
                    }
                    if ($h{$eachpop}{$allele}){
                        print PARFILE2 "$h{$eachpop}{$allele}";
                    }else{
                        print PARFILE2 "0";
					}
                 }
            print PARFILE2 "\n";
			}
            else{
		        $popnumber++;
		        	my $tmpcount=0;
		        #print $eachpop "pop_$popnumber\n"; #For version that prints out all the populations together.
		        	print $eachpop "pop_0\n";
		        foreach my $i ($NumColBad..$#a){
		            if ($pop{$samples{$i}}){
        			        if ($pop{$samples{$i}} eq $eachpop){
        				        if ($loci{$samples{$i}}{"1"}){
        					        my @keys = sort keys %alleles;
        					        if ($keys[0] eq $loci{$samples{$i}}{"1"}){
        						        if ($keys[0] eq $loci{$samples{$i}}{"2"}){
        							        print $eachpop "2 0\n";
        						        }
        						        elsif ($keys[1] eq $loci{$samples{$i}}{"2"}){
        							        print $eachpop "1 1\n";
        						        }
        					        }
        					        elsif (($keys[0] eq $loci{$samples{$i}}{"2"}) and $keys[1] eq $loci{$samples{$i}}{"1"}){
        					            print $eachpop "1 1\n";
        					        }
        					        elsif (($keys[1] eq $loci{$samples{$i}}{"1"}) and ($keys[1] eq $loci{$samples{$i}}{"2"})){
        						        print $eachpop "0 2\n";
        					        }
        				        }else{
        					        print $eachpop "-9 -9\n";
        					    }
        				    }
        			    }
        		    }
        		}
        	}
    }
}


close PARFILE1;
close PARFILE2;
close LOCI;
close IN;
foreach my $eachpop (sort keys %popList){
    if (($eachpop ne "p1") and ($eachpop ne "p2")){
       close $eachpop;
    }
}
