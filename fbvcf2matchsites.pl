#!/bin/perl
use warnings;
use strict;

#This script will parse through a vcf file and print out site quality information. It keeps sites that were preloaded as "good" snps, and otherwise grabs 0.1% of sites randomly
#It only keeps biallleic sites
my $good_file = "/media/owens/Copper/WGS_annuus/public_annuus_snps_sort.snpset";

open FILE, $good_file;

my %refset;
my %altset;
while(<FILE>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $ref = $a[2];
  my $alt = $a[3];
  $altset{$chr}{$pos} = $alt;
}
close FILE;
print "chr\tpos\tmatch";


while(<STDIN>){
  chomp;
  next if(/^#/);
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $alt = $a[4];
  my $keep;
  my $match = 0;
  my $result;
  if ($altset{$chr}{$pos}){
  }else{next;}
  if (length($alt) > 1){
    $result = "TriNoMatch";
    my @alts = split(/,/,$alt);
    foreach my $allele (@alts){
      if ($allele eq $altset{$chr}{$pos}){
        $result="TriMatch";
      }
    }
  }else{
    if ($alt eq $altset{$chr}{$pos}){
      $result = "BiMatch";
    }else{
      $result = "BiNoMatch";
    }
  }
  print "\n$chr\t$pos\t$result";
}

