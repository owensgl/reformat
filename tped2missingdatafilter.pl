#!/bin/perl
use strict;
use warnings;

#This script filters a tped file for MAF. SNPs must be only biallelic.
my $missing = $ARGV[0];
my $first_line;
my $total_sites;
my $printed_sites;
while(<STDIN>){
  chomp;
  $total_sites++;
  my @a = split(/\t/,$_);
  my $present = 0;
  my $absent = 0;
  foreach my $i (4..$#a){
    if ($a[$i] eq "0"){
      $absent++;
    }else{
      $present++;
    }
  }
  my $total = $absent + $present;
  my $current_missing = ($absent / $total);
#  print STDERR "$present out of $total, therefor $current_missing percent missing\n";
  if ($current_missing <= $missing){
    $printed_sites++;
    unless($first_line){
      print "$_";
      $first_line++;
    }else{
      print "\n$_";
    }
  }
}
print STDERR "For missing data filter, printed $printed_sites / $total_sites\n";
