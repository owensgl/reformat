#!/bin/perl
use warnings;
use strict;

#This takes a vcf file (from STDIN), a genetic map file and a sample information file, and outputs files formatted for Admixture_HMM. It prints one file per chromosome per admixed sample.

my $infofile = $ARGV[0]; #Information about samples, whether they are admixed (A) or part of reference populations (1 or 2); Samples not in info file are ignored.
my $output = $ARGV[1]; #The prefix of your output file

#Options:
my $remove_indels = "TRUE";
my $print_empty_sites = "FALSE"; #if TRUE, will print sites where the admixed sample has no reads (but reference populations do). This will keep all sites consistent between samples.
my $min_ref_size = "5"; #minimum number of individuals genotyped in each reference set.
my $min_ref_dif = "0.2"; #Minimum allele frequency difference between the reference populations to keep a site. Set to 0 for no filtering.
#####

my $chr_n = 17; #The number of chromosomes;
my $chr_prefix = "Ha412TMPChr";

my %group;
my @admixed_samples;
my %fh;
open INFO, $infofile;
while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  $group{$a[0]} = $a[1];
  if ($a[1] eq "A"){
    push(@admixed_samples,$a[0]);
    foreach my $chr (1..17){
      my $padded_chr = sprintf "%02d", $chr;
      my $full_chr = ${chr_prefix}.$padded_chr;
      my $file = "$output.$a[0].${full_chr}.input";
      open $fh{$a[0]}{$full_chr},'>', $file or die "Can't open the output file: $!";
    }
  }
}

close INFO;
my %name;
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
          if (($genotype ne './.') and  ($genotype ne '.')){
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

    foreach my $i (9..$#a){
      if ($group{$name{$i}}){
        if ($group{$name{$i}} eq "A"){
          my @b = split(/:/,$a[$i]);
          my $genotype = $b[0];
          my @reads = split(/,/,$b[1]);
          if (($reads[0] eq "0") and ($reads[1] eq "0")){
            unless($print_empty_sites eq "TRUE"){
              next;
            }
          }
          my $morgan_dist = 0.1; #Placeholder value
          print { $fh{$name{$i}}{$chr} }"$pos\t$ref_genotypes{1}{0}\t$ref_genotypes{1}{1}\t$ref_genotypes{2}{0}\t$ref_genotypes{2}{1}\t$reads[0]\t$reads[1]\t$morgan_dist\n";
        }
      }
    }
  }
  SKIPSITE:
}


