#!/usr/bin/perl

use strict;
use warnings;

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

my $in = $ARGV[0];
my $pop = $ARGV[1];
my $out = $ARGV[2];

require "countbadcolumns.pl";
my ($iupac_coding, $badcolumns) = count_bad_columns($in);
$. = 0;

my %sample;
my $loci_count;
my %data;
my @samplelist;
my %marker;
my %poplist;
my %totals;
my @parents = ("P1", "P2");
my %Major;
my %Minor;

open POP, $pop;
while (<POP>){
    chomp;
    my @a = split(/\t/, $_);
    $poplist{$a[0]} = $a[1];
}
close POP;

open IN, $in;
while (<IN>){
    chomp;
    my @a = split(/\t/, $_);
    if ($. == 1){
        foreach my $i ($badcolumns..$#a){
            $sample{$i} = $a[$i];
            push (@samplelist, $a[$i]);
        }
    }else{
        next if /^\s*$/;
        my %total_alleles;
        $loci_count++;
        $marker{$loci_count} = "$a[0]_$a[1]";
        foreach my $i ($badcolumns..$#a){
            if ($iupac_coding eq "TRUE"){
                $a[$i] = $t{$a[$i]};
            }
            unless (($a[$i] eq "NN")or($a[$i] eq "XX")){
                my @strands = split(//, $a[$i]);
                $total_alleles{$strands[0]}++;
                $total_alleles{$strands[1]}++;
                if ($poplist{$sample{$i}} ne "H"){
                	$totals{$loci_count}{$poplist{$sample{$i}}}{$strands[0]}++;
                	$totals{$loci_count}{$poplist{$sample{$i}}}{$strands[1]}++;
                }
            }
        }
#	print "$totals{$loci_count}{'P1'}{'A'}\n";
        my @bases = sort { $total_alleles{$a} <=> $total_alleles{$b} } keys %total_alleles ;
        $Major{$loci_count} = $bases[1];
        $Minor{$loci_count} = $bases[0];
	unless (($totals{$loci_count}{"P1"}{$bases[0]}) or
		($totals{$loci_count}{"P2"}{$bases[0]})){
		$totals{$loci_count} = ();
		$loci_count-=1;
		goto SKIP;
	}
        foreach my $i ($badcolumns..$#a){
            my @strands = split(//, $a[$i]);
            if ($strands[0] eq "N"){
                $data{$sample{$i}}{$loci_count} = "-9";
            }elsif(($strands[0] eq $bases[0]) and ($strands[1] eq $bases[0])){
                $data{$sample{$i}}{$loci_count} = "0";
            }elsif ($strands[0] ne $strands[1]){
                $data{$sample{$i}}{$loci_count} = "1";
            }else{
                $data{$sample{$i}}{$loci_count} = "2";
            }
        }
    }
	SKIP:
}

open(my $g_file, '>', "${out}.hiest.G");
open(my $p_file, '>', "${out}.hiest.P");
print $g_file "sample";
foreach my $i (1..$loci_count){
	print $g_file "\t$marker{$i}";
}
foreach my $sample (@samplelist){
    if ($poplist{$sample}){
        print $g_file "\n";
        print $g_file "$sample";
        foreach my $i (1..$loci_count){
            print $g_file "\t$data{$sample}{$i}";
        }
    }
}
close IN;
close $g_file;
print $p_file "Locus\tAllele\tP1\tP2";
foreach my $i (1..$loci_count){
    print $p_file "\n";
    print $p_file "$marker{$i}\t1";
    foreach my $pop (@parents){
        my $freq;
        if (($totals{$i}{$pop}{$Major{$i}}) and ($totals{$i}{$pop}{$Minor{$i}})){
            $freq = ($totals{$i}{$pop}{$Major{$i}} / ($totals{$i}{$pop}{$Major{$i}} + $totals{$i}{$pop}{$Minor{$i}}));
        }elsif($totals{$i}{$pop}{$Major{$i}}){
            $freq = "1";
        }else{
            $freq = "0";
        }
        print $p_file "\t$freq";
    }
}
close $p_file;
