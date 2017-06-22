#!/bin/perl
use warnings;
use strict;

#This takes a vcf file (from STDIN) and a sample information file, and outputs files formatted for Admixture_HMM. It prints one file per chromosome per sample. It outputs all samples that are in info file. It needs the cm position in the ID column (3rd column) of the VCF. 

my $infofile = $ARGV[0]; #Information about samples, whether they are admixed (A) or part of reference populations (1 or 2); Samples not in info file are ignored.

#Options:
my $remove_indels = "FALSE";
my $print_empty_sites = "FALSE"; #if TRUE, will print sites where the admixed sample has no reads (but reference populations do). This will keep all sites consistent between samples.
my $min_ref_size = "10"; #minimum number of individuals genotyped in each reference set.
my $min_ref_dif = "0.20"; #Minimum allele frequency difference between the reference populations to keep a site. Set to 0 for no filtering.
#####


my %group;
my @printing_samples;
my %fh;
open INFO, $infofile;
while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  $group{$a[0]} = $a[1];
  if ($a[1]){
    push(@printing_samples,$a[0]);
  }
}

close INFO;
my %name;
my $previous_cm;
my $previous_chr;
my $print_samplelist;

open SAMPLELIST, '>', "samplelist.txt";
while(<STDIN>){
  chomp;
  my $line = $_;
  if ($line=~m/^##/){next;}
  if ($line=~m/^#/){
    my @a = split(/\t/,$line);
    foreach my $i (9..$#a){
      $name{$i} = $a[$i];
    }
  }else{
    my @a = split(/\t/,$line);
    my $chr = $a[0];
    my $pos = $a[1];
    my $cm = $a[2];
    my $ref = $a[3];
    my @alt = split(/,/,$a[4]);
    my $qual = $a[5];
    my $info = $a[7];
    my @fields = split(/;/,$info);
    if ($alt[1]){next;} #Removes multiallelic sites
    if ($remove_indels eq "TRUE"){ #Remove indels if selected
      if ((length($ref) > 1) or (length($alt[0]) > 1)){
        next;
      }
    }

    unless($previous_chr){
      $previous_chr = $chr;
    }
    if ($previous_chr ne $chr){
      undef($previous_cm);
      $previous_chr = $chr;
    }
    #Count how many reference samples are genotyped per population.
    my %ref_counts;
    my %ref_genotypes;
    #Load up empty genotype counts;
    $ref_genotypes{1}{0} = 0;
    $ref_genotypes{1}{1} = 0;
    $ref_genotypes{2}{0} = 0;
    $ref_genotypes{2}{1} = 0;
    foreach my $i (9..$#a){
      if ($group{$name{$i}}){
        if (($group{$name{$i}} eq 1) or ($group{$name{$i}} eq 2)){
          my @b = split(/:/,$a[$i]);
          my $genotype = $b[0];
          my $reads = $b[1];
          if ($genotype ne './.'){
            $ref_counts{$group{$name{$i}}}++;
            my @alleles = split(/\//,$genotype);
            $ref_genotypes{$group{$name{$i}}}{$alleles[0]}++;
            $ref_genotypes{$group{$name{$i}}}{$alleles[1]}++;
          }

        }
      }
    }
    #Filter out sites without the minimum number of reference population calls.
    unless(($ref_counts{"1"}) and ($ref_counts{"2"})){
      goto SKIPSITE;
    }unless(($ref_counts{"1"} >= $min_ref_size) and ($ref_counts{"2"} >= $min_ref_size)){
      goto SKIPSITE;
    }
    if (($ref_genotypes{1}{1} eq 0) and ($ref_genotypes{2}{1} eq 0)){
      goto SKIPSITE;
    }
    if (($ref_genotypes{1}{0} eq 0) and ($ref_genotypes{2}{0} eq 0)){
      goto SKIPSITE;
    }
    my $p1 = $ref_genotypes{1}{0} / ($ref_genotypes{1}{0} + $ref_genotypes{1}{1});
    my $p2 = $ref_genotypes{2}{0} / ($ref_genotypes{2}{0} + $ref_genotypes{2}{1});
    my $dif = abs($p1 - $p2);
    if ($dif < $min_ref_dif){
      goto SKIPSITE;
    }
    unless($print_samplelist){
      foreach my $i (9..$#a){
        if ($group{$name{$i}}){
          print SAMPLELIST "$name{$i} 2\n";
        }
      }
      $print_samplelist++;
    }
    my $this_prev_cm = 0;
    if ($previous_cm){
      $this_prev_cm = $previous_cm;
    }
    my $morgan_dist = ($cm - $this_prev_cm)/100;
    print "$chr\t$pos\t$ref_genotypes{1}{0}\t$ref_genotypes{1}{1}\t$ref_genotypes{2}{0}\t$ref_genotypes{2}{1}\t$morgan_dist";
    $previous_cm = $cm;
    foreach my $i (9..$#a){
      if ($group{$name{$i}}){
        my @b = split(/:/,$a[$i]);
        my $genotype = $b[0];
        my @reads = split(/,/,$b[1]);
        print "\t$reads[0]\t$reads[1]";
      }
    }
    print "\n";
  }
  SKIPSITE:
}


