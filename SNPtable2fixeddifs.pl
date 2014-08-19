#!/usr/bin/perl

use warnings;
#use strict;

#Prints out each admixed population as it's own file.
#unless (@ARGV == 3) {die;}

my $in = $ARGV[0]; #Infile SNP table
my $pop = $ARGV[1]; #Population file for each sample
my %pop;

my %samples;
my @samples;
my %popList;
my $locicount=-1;
my $NumColBad=2;


open (FILTERED, "> $in.dif_filtered") or die "Could not open a file\n";




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
        }
        print FILTERED "$a[0]";
		foreach my $i (1..$#a){
			print FILTERED "\t$a[$i]";
		}
		print FILTERED "\n";
	}else{
		my %h;
		my %alleles;
		my %loci;
		$locicount++;
		my $popnumber=-1;
		my $chr = $a[0];
		my $pos = $a[1];
		$chr =~ s/group//g;
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
		my $counter = 0;
		foreach my $allele (sort keys %alleles){
		    if (($h{"p1"}{$allele}) and ($h{"p2"}{$allele})){
				$counter++;
			}
		}
		if ($counter eq 0){
			print FILTERED "$a[0]";
			foreach my $i (1..$#a){
		    		print FILTERED "\t$a[$i]";
		    }
		    	print FILTERED "\n";
		}
    }
}

close IN;
close FILTERED;
