#!/usr/bin/perl

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

my $in = $ARGV[0]; #Infile SNP table


require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;


my $locicount;
my %snp_hash;
my %samples;
my @samplelist;
my $loci_count;

open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1 ){
    	foreach my $i ($badcolumns..$#a){
            $samples{$i}=$a[$i];
            push(@samplelist,$a[$i]);
        }
	}else{
		next if /^\s*$/;
		$loci_count++;
		my %total_alleles;
		foreach my $i ($badcolumns..$#a){
            if ($iupac_coding eq "TRUE"){
                $a[$i] = $t{$a[$i]};
            }
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
		foreach my $i ($badcolumns..$#a){
			my $majorcount = 0;
			my @strands = split(//, $a[$i]);
			if ($a[$i] eq "NN"){
				$snp_hash{$samples{$i}}{$loci_count} = "??";
				next;
			}
			foreach my $base (@strands){
				if ($base eq "$major_allele"){
					$majorcount++;
				}
			}
			if ($majorcount == 2){
				$snp_hash{$samples{$i}}{$loci_count} = "11";
			}elsif($majorcount == 1){
				$snp_hash{$samples{$i}}{$loci_count} = "01";
			}else{
				$snp_hash{$samples{$i}}{$loci_count} = "00";
			}
		}
	}
}
my $n_snps = ($loci_count * 2);
print "#nexus\n\n";
print "BEGIN Taxa;\n";
print "DIMENSIONS ntax=$#samplelist;\n";
print "TAXLABELS\n";
my $samplecounter = 0;
foreach my $samplename(@samplelist){
	$samplecounter++;
	print "[$samplecounter] \'$samplename\'\n";
}
print ";\nEND;[Taxa]\n\n";

print "BEGIN Characters;\n";
print "DIMENSIONS nchar=$n_snps;\n";
print "FORMAT\n";
print "\tdatatype=STANDARD\n";
print "\tmissing=?\n";
print "\tgap=-\n";
print "\tsymbols=\"01\"\n";
print "\tlabels=left\n";
print "\ttranspose=no\n";
print "\tinterleave=no\n";
print ";\n";
print "MATRIX\n";
foreach my $samplename(@samplelist){
	print "\'$samplename\' ";
	foreach my $snpnumber (1..$loci_count){
		print "$snp_hash{$samplename}{$snpnumber}";
	}
	print "\n";
}
print ";\n";
print "End;";
