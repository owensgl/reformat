#!/usr/bin/perl
#This reformates to nex format for snapp. It also has a feature built in where it only outputs the first X of each species. Change this if you want to print all.
use warnings;
use strict;
use lib '/home/owens/bin/pop_gen/'; #For GObox server
my %t;
$t{"N"} = "NN";
$t{"A"} = "AA";
$t{"T"} = "TT";
$t{"G"} = "GG";
$t{"C"} = "CC";
$t{"W"} = "TA";
$t{"R"} = "AG";
$t{"M"} = "AC";
$t{"S"} = "CG";
$t{"K"} = "TG";
$t{"Y"} = "CT";

my %f;
$f{"TA"} = "AT";
$f{"GA"} = "AG";
$f{"CA"} = "AC";
$f{"GC"} = "CG";
$f{"TC"} = "CT";
$f{"TG"} = "GT";

my $popfile = $ARGV[0]; #Sample name and species. It appends species to sample name
my $max_per_species = 4;

my %species;
my %species_count;
open POP, $popfile;
while(<POP>){
	chomp;
	my @a = split(/\t/,$_);
	$species_count{$a[1]}++;
	if($species_count{$a[1]} > $max_per_species){next;}
	$species{$a[0]} = $a[1];
	
}


my $locicount;
my %snp_hash;
my %samples;
my @samplelist;
my $loci_count;

while (<STDIN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
    	foreach my $i (2..$#a){
	    if ($species{$a[$i]}){
            	$samples{$i}=$a[$i];
            	push(@samplelist,$a[$i]);
	    }
        }
	}else{
		next if /^\s*$/;
		$loci_count++;
		my %total_alleles;
		foreach my $i (2..$#a){
			if ($f{$a[$i]}){ #Flip alleles so they're in alphabetical order
				$a[$i] = $f{$a[$i]};
			}
			unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
				my @strands = split(//, $a[$i]);
				$total_alleles{$strands[0]}++;
                		$total_alleles{$strands[1]}++;
			}
		}
		my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
		my $major_allele = $bases[1];
		my $minor_allele = $bases[0];
		foreach my $i (2..$#a){
			unless($samples{$i}){next;}
			my $majorcount = 0;
			my @strands = split(//, $a[$i]);
			if ($a[$i] eq "NN"){
				$snp_hash{$samples{$i}}{$loci_count} = "?";
				next;
			}
			foreach my $base (@strands){
				if ($base eq "$major_allele"){
					$majorcount++;
				}
			}
			if ($majorcount == 2){
				$snp_hash{$samples{$i}}{$loci_count} = "2";
			}elsif($majorcount == 1){
				$snp_hash{$samples{$i}}{$loci_count} = "1";
			}else{
				$snp_hash{$samples{$i}}{$loci_count} = "0";
			}
		}
	}
}
my $n_snps = ($loci_count);
my $n_samples = ($#samplelist+1);
print "#NEXUS\n\n";
#print "BEGIN Taxa;\n";
#print "DIMENSIONS ntax=$n_samples;\n";
#print "TAXLABELS\n";
#my $samplecounter = 0;
#foreach my $samplename(@samplelist){
#	unless($species{$samplename}){next;}
#	$samplecounter++;
#	print "[$samplecounter] \'$species{$samplename}_$samplename\'\n";
#}
#print ";\nEND;[Taxa]\n\n";

print "Begin data;\n";
print "\tDimensions ntax=$n_samples nchar=$n_snps;\n";
print "\tFormat";
print " datatype=integerdata";
print " missing=?";
print " gap=-";
print " symbols=\"012\";\n";
print "\tMatrix\n";
foreach my $samplename(@samplelist){
	unless($species{$samplename}){next;}
	print "$species{$samplename}_$samplename ";
	foreach my $snpnumber (1..$loci_count){
		print "$snp_hash{$samplename}{$snpnumber}";
	}
	print "\n";
}
print "\t;\n";
print "End;";
