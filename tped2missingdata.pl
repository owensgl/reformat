#!/bin/perl

#Script for taking a plink tped file, and introducing missing data.

use warnings;
use strict;
use Math::Random qw(:all);
use Math::Round;

#Usage perl tped2missingdata DATA.tped > DATA.missing.tped

#STEPS:
#Find number of SNPs and number of samples
#Calculate number of reads based on that
#use a normal distribution to distribute the number of reads per sample
#For each site, pick if it is common or rare. 50-> common, 30 -> less common, 20 -> rare #FIX LATER
#Distribute reads to sites
#Make missing data

my $tped = $ARGV[0];
my $mean_reads_per_site = 10; #The average number of reads per site, used to calculate total reads
my $min_depth = 6; #minimum read depth to call a site
my $missing_symbol = "0"; #For non-numeric it is 0, for numeric it is -9;
my $print_stats = "1"; #To print out stats for plotting, make this 1. To turn it off make it 0.
if ($print_stats){
    open (READS, '>', 'reads_per_sample.txt');
    open (DEPTH, '>', 'depth_per_site.txt');
    open (MISSING, '>', 'missing_per_site.txt');
}
#Get size information from file
my $n_samples = `head -n 1 $tped | tr ' ' '\n' | wc -l | cut -f 1 -d " "`;
$n_samples = ($n_samples - 4)/2;
my $n_sites = `wc -l $tped | cut -f 1 -d " "`;

#Calculate number of total reads
my $total_reads = $mean_reads_per_site * $n_samples * $n_sites;

#Divide the reads among samples
my %sample_depth;
my $total;
my %sample_reads;
foreach my $n (1..$n_samples){
    my $value = random_normal(1,5,2);
    if ($value <0){ $value = 0;} #Make sure its not negative
    $sample_depth{$n} = $value;
    $total += $value;
}
foreach my $n (1..$n_samples){
    my $percent = $sample_depth{$n}/$total;
    $sample_reads{$n} = $percent * $total_reads;
    $sample_reads{$n} = round($sample_reads{$n});
#    print STDERR "\nFor sample $n, it had a relative value of $sample_depth{$n} and a percent of $percent, so it got $sample_reads{$n} reads.";
    if ($print_stats){
	print READS "$n\t$sample_reads{$n}\n";
    }	
}
#Assign sites to categories;
my %site_type;
foreach my $n (1..$n_sites){
    my $tmp = rand();
    if (($tmp > 0) and ($tmp <= 0.5)){
        $site_type{$n} = 4; #100% likelihood. It gets 4 tickets to the read lottery
    }elsif (($tmp > 5) and ($tmp <= 0.80)){
        $site_type{$n} = 2; #50% likelihood. It gets 2 tickets to the read lottery
    }else{
        $site_type{$n} = 1; #25% likelihood. It gets 1 ticket to the read lottery
    }
}
#Assign reads to sites based on category values;
my %depth;
foreach my $sample (1..$n_samples){
    my @read_lottery;
    foreach my $n (1..$n_sites){ #
        foreach my $i (1..$site_type{$n}){
            push(@read_lottery,$n);
        }
    }
    my $n_tickets = $#read_lottery;
    foreach my $read (1..$sample_reads{$sample}){
        my $draw = int(rand($n_tickets + 1));
        $depth{$sample}{$read_lottery[$draw]}++;
    }
}
#Load in tped file and put in the missing data where read depth is below the minimum.
open TPED, $tped;
my $site = 1;
while(<TPED>){
    chomp;
    my @a = split(/ /,$_);
    if ($. == 1){
        print "$a[0] $a[1] $a[2] $a[3]";
    }else{
        print "\n$a[0] $a[1] $a[2] $a[3]";
    }
    for (my $i = 4; $i < $#a; $i+=2){
        my $sample = ($i - 2)/2;
	
        if ($depth{$sample}{$site}){
	    if ($depth{$sample}{$site} >= $min_depth){
                print " $a[$i] $a[($i+1)]";
            }else{
            print " $missing_symbol $missing_symbol";
            }
	}else{
            print " $missing_symbol $missing_symbol";
	}
	if ($print_stats){ #Stats for plotting
            if ($depth{$sample}{$site}){
                if ($depth{$sample}{$site} >= $min_depth){
            	    print DEPTH "$sample\t$site\t$depth{$sample}{$site}\n";
		    print MISSING "$sample\t$site\t1\n";
                }else{
                    print DEPTH "$sample\t$site\t$depth{$sample}{$site}\n";
                    print MISSING "$sample\t$site\t0\n";
                }
            }else{
                print DEPTH "$sample\t$site\t0\n";
                print MISSING "$sample\t$site\t0\n";
            }
	}
    }
    $site++;
}
