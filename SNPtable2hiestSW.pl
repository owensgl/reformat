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

my $currentchr;
my $currentpos_breakpoint = 0;
my @breakpoints = 1;
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
	next if /^scaffold/;
	unless ($currentchr){
		$currentchr = $a[0];
	}
        my %total_alleles;
        $loci_count++;
	if ($currentchr ne $a[0]){
		push( @breakpoints, $loci_count);
		$currentchr = $a[0];
		$currentpos_breakpoint = 0;
	}
	elsif($a[1] > $currentpos_breakpoint) {
		push(@breakpoints, $loci_count);
		$currentpos_breakpoint = $currentpos_breakpoint + 5000000;
	}
		
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
}

open(my $window_file, '>', "${out}.windowregions.txt");
close IN;
foreach my $window (1..($#breakpoints-1)){
	open(my $g_file, '>', "${out}.window${window}.hiest.G");
	open(my $p_file, '>', "${out}.window${window}.hiest.P");
	print $g_file "sample";
	my @startmarker = split(/_/,$marker{$breakpoints[$window]});
	my @endmarker = split(/_/,$marker{$breakpoints[$window+1]});
	my $midmarker;
	if ($startmarker[0] eq $endmarker[0]){
		$midmarker = $startmarker[1] + (($endmarker[1] - $startmarker[1]) / 2);
	}else{
		my @tmpendmarker = split(/_/,$marker{$breakpoints[$window+1]-1});
		$midmarker = ($startmarker[1] + (($tmpendmarker[1] - $startmarker[1]) / 2));
	}
	print $window_file "${window}\t$startmarker[0]\t$midmarker\n";
	foreach my $i ($breakpoints[$window]..($breakpoints[($window+1)]-1)){
		print $g_file "\t$marker{$i}";
	}
	foreach my $sample (@samplelist){
   		if ($poplist{$sample} eq "H"){
        		print $g_file "\n";
		        print $g_file "$sample";
		        foreach my $i ($breakpoints[$window]..($breakpoints[($window+1)]-1)){
        			print $g_file "\t$data{$sample}{$i}";
		        }
   		 }
	}
	close $g_file;
	print $p_file "Locus\tAllele\tP1\tP2";
	foreach my $i ($breakpoints[$window]..($breakpoints[($window+1)]-1)){
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
}
