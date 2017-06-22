#!/bin/perl
use strict;
use warnings;
use List::Util 'shuffle';

#This script is to look at a vcf file and tell if an unbalanced allele (e.g. 1/7 reads for heterozygote), is found in other individuals in that lane at a higher frequency than in other individuals not in that lane.

#Idea_1: permute the sample size of individuals in that lane (minus unbalanced sample), and ask how often that permuted group has the unbalance allele
#Idea_2: Look at frequency of the allele (i.e. the expected percentage) and then just ask if it is in the lane group or not. Plot expected versus observed. Use a random group as control.

#This version (2) takes the allele frequency of each technology for the null
my $min_dp = 5; #minimum depth of unbalanced allele;
my $max_sites = 500000;
my $min_unbalanced_dp = 1;
my %lane;
my %tech;
my %reads;
my $popinfo = $ARGV[0];
open POP, $popinfo;
while(<POP>){
  chomp;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  my $lane1 = $a[2];
  my $lane2 = $a[3];
  my $tech = $a[4];
  my $reads = $a[5];
  $lane{$sample}{1} = $lane1;
  $lane{$sample}{2} = $lane2;
  $tech{$sample} = $tech;
  $reads{$sample} = $reads;
}
close POP;
my $counter;
my %sample;

print "site\tsample\ttechnology\treads\tlane1\tlane2\tdepth\tpercent\ttype\tvalue\tcalledhet";
while(<STDIN>){
  my $line = "$_";
  chomp $line;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
    next;
  }
  if ($line =~m/^#CHROM/){
    my $first_line;
    foreach my $i (9..$#fields){
      $sample{$i} = $fields[$i];
    }
  }
  else{
    $counter++;
    if ($counter > $max_sites){goto ENDSCRIPT;}
    if ($counter % 100000 == 0){print STDERR "Processed $counter sites\n";}
    my $chr = $fields[0];
    my $pos = $fields[1];
    my $alt = $fields[4];
    my $multi_alt;
    my @alts;
    @alts = split(/,/,$alt);
    if (length($alt) > 1){
      next;
    }
    my @test_samples;
    my %lane_alleles;
    my %total_alleles;
    my %tech_alleles;
    my %tech_count;
    my %sample_alleles;
    my %rare_allele;
    my %test_depth;
    my %counts_in_sample;
    my %het;
    my %lane_counter;
    my $total_count;
    #Look for samples with unbalanced alleles
    foreach my $i (9..$#fields){
      unless($lane{$sample{$i}}{1}){next;}
      if ($fields[$i] ne '.'){
        my @info = split(/:/,$fields[$i]);
        my $call = $info[0];
        my @bases = split(/\//,$call);
        $lane_alleles{$lane{$sample{$i}}{1}}{$bases[0]}++;
        $lane_alleles{$lane{$sample{$i}}{1}}{$bases[1]}++;
	$lane_counter{$lane{$sample{$i}}}{1}++;
	$lane_counter{$lane{$sample{$i}}}{2}++;
        if ($lane{$sample{$i}}{1} ne $lane{$sample{$i}}{2}){
          $lane_alleles{$lane{$sample{$i}}{2}}{$bases[0]}++;
          $lane_alleles{$lane{$sample{$i}}{2}}{$bases[1]}++;
        }
        $sample_alleles{$sample{$i}}{1} = $bases[0];
        $sample_alleles{$sample{$i}}{2} = $bases[1];
        $counts_in_sample{$sample{$i}}{$bases[0]}++;
        $counts_in_sample{$sample{$i}}{$bases[1]}++;
        $total_alleles{$bases[0]}++;
        $total_alleles{$bases[1]}++;
	$tech_alleles{$tech{$sample{$i}}}{$bases[0]}++;
	$tech_alleles{$tech{$sample{$i}}}{$bases[1]}++;
	$tech_count{$tech{$sample{$i}}}+=2;
	$total_count+=2;
	if ($bases[0] ne $bases[1]){
	  $het{$sample{$i}} = "T";
	}
        my $dp = $info[1];
        my $ref_dp = $info[3];
        my $alt_dp = $info[5];
        if ($dp >= $min_dp){
          if ($ref_dp == $min_unbalanced_dp){
            push(@test_samples,$sample{$i});
            $rare_allele{$sample{$i}} = 0;
            $test_depth{$sample{$i}} = $dp;
          }elsif ($alt_dp == $min_unbalanced_dp){
            push(@test_samples,$sample{$i});
            $rare_allele{$sample{$i}} = 1;
            $test_depth{$sample{$i}} = $dp;
          }
        }
      }
    }
      unless (@test_samples){next;}
      foreach my $test_sample (@test_samples){
        my $testlane1 = $lane{$test_sample}{1};
	my $testlane2 = $lane{$test_sample}{2};
	my $n;
	foreach my $i (9..$#fields){ #Count each sample in the lane that has data to make it equal $n
	  if ($test_sample eq $sample{$i}){next;}
	  if (($lane{$sample{$i}}{1} eq $testlane1) or
	    ($lane{$sample{$i}}{1} eq $testlane2) or
	    ($lane{$sample{$i}}{2} eq $testlane1) or
	    ($lane{$sample{$i}}{2} eq $testlane2)){
	    $n++;
	  }
	}
#print STDERR "$chr.$pos\t$test_sample\t$n\n";
        my $picked_samples = 0;
        my %control_alleles;
        my $tmp_counter = 0;
	my @range = (9..$#fields);
	my @rand_range = shuffle(@range);	
        foreach my $rand (@rand_range){
          if ($sample{$rand} eq $test_sample){next;}
	  unless($lane{$sample{$rand}}{1}){next;}
          unless(defined $sample_alleles{$sample{$rand}}{1}){next;}
          #If correct technology and lane
          if ($tech{$sample{$rand}} eq $tech{$test_sample}){
            if (($lane{$sample{$rand}}{1} ne $lane{$test_sample}{1}) and ($lane{$sample{$rand}}{1} ne $lane{$test_sample}{2}) and ($lane{$sample{$rand}}{2} ne $lane{$test_sample}{2})){
              $control_alleles{$sample_alleles{$sample{$rand}}{1}}++;
              $control_alleles{$sample_alleles{$sample{$rand}}{2}}++;
              $picked_samples++;
#print STDERR "picked random sample $rand, which is $picked_samples\n";
#print STDERR "This sample had $sample_alleles{$sample{$rand}}{1} and $sample_alleles{$sample{$rand}}{2}\n";
            }
          }
	  if ($picked_samples >= $n){
	    goto TESTSAMPLE;
	  }
        }
	TESTSAMPLE:
	if ($picked_samples ne $n){next;}
        #check if unbalanced allele is in the lane
        my $lane_present = "0";
	my $lane1_tmp = $lane_alleles{$lane{$test_sample}{1}}{$rare_allele{$test_sample}};
	my $lane2_tmp = $lane_alleles{$lane{$test_sample}{2}}{$rare_allele{$test_sample}};
	if ($counts_in_sample{$test_sample}{$rare_allele{$test_sample}}){
	  $lane1_tmp-=$counts_in_sample{$test_sample}{$rare_allele{$test_sample}};
	  $lane2_tmp-=$counts_in_sample{$test_sample}{$rare_allele{$test_sample}};
	}

        if (($lane1_tmp) or ($lane2_tmp)){
          $lane_present = "1";
        }
        #check if unbalanced allele is in the random non-lane samples
        my $control_present = "0";
        if ($control_alleles{$rare_allele{$test_sample}}){
          $control_present = "1";
        }
        unless($het{$test_sample}){
	  $het{$test_sample} = "F";
	}
	my $test_sample_freq = 0;
	if ($counts_in_sample{$test_sample}{$rare_allele{$test_sample}}){
	  $test_sample_freq = $counts_in_sample{$test_sample}{$rare_allele{$test_sample}};
	}
	unless($total_alleles{$rare_allele{$test_sample}}){
	  $total_alleles{$rare_allele{$test_sample}} = 0;
	}
	unless($tech_alleles{$tech{$test_sample}}{$rare_allele{$test_sample}}){
	  $tech_alleles{$tech{$test_sample}}{$rare_allele{$test_sample}} = 0;
	}
        my $percent_unbalanced = (($tech_alleles{$tech{$test_sample}}{$rare_allele{$test_sample}} - $test_sample_freq) / ($tech_count{$tech{$test_sample}} - 2));
#print STDERR "$percent_unbalanced\t";
        #Calculate chance that you will have the allele in your lane given the allele freq and number of samples
        my $chance = 1 - (1 - $percent_unbalanced)**($n*2);
#print STDERR "$chance\t$n\t$lane{$test_sample}{1}\n";
	if ($chance > .95){next};
#print STDERR "percent = $percent_unbalanced, n = $n, chance = $chance\n";
        print "\n$chr.$pos\t$test_sample\t$tech{$test_sample}\t$reads{$test_sample}\t$lane{$test_sample}{1}\t$lane{$test_sample}{2}\t$test_depth{$test_sample}\t$chance\twithin_lane\t$lane_present\t$het{$test_sample}";
        print "\n$chr.$pos\t$test_sample\t$tech{$test_sample}\t$reads{$test_sample}\t$lane{$test_sample}{1}\t$lane{$test_sample}{2}\t$test_depth{$test_sample}\t$chance\tcontrol\t$control_present\t$het{$test_sample}";
      }
    }
}
ENDSCRIPT:
