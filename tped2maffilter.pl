#!/bin/perl
use strict;
use warnings;

#This script filters a tped file for MAF. SNPs must be only biallelic.
my $maf = $ARGV[0];
my $first_line;
my $total_sites;
my $printed_sites;
while(<STDIN>){
  chomp;
  $total_sites++;
  my @a = split(/\t/,$_);
  my $major = 0;
  my $minor = 0;
  foreach my $i (4..$#a){
    if ($a[$i] eq "1"){
      $major++;
    }elsif ($a[$i] eq "2"){
      $minor++;
    }elsif ($a[$i] eq "3"){
      die "The SNP table should be biallelic! There is a third allele\n";
    }
  }
  my $total = $major + $minor;
  unless($total){next;}
  my $current_maf = $minor / $total;
  if ($current_maf > 0.5){
    $current_maf = 1 - $current_maf;
  }
  if ($current_maf >= $maf){
    $printed_sites++;
    unless($first_line){
      print "$_";
      $first_line++;
    }else{
      print "\n$_";
    }
  }
}
print STDERR "For MAF filter, printed $printed_sites / $total_sites\n";
