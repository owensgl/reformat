#!/bin/perl
use strict;
use warnings;

#This script takes a VCF from GATK and creates a .fam format 
my $first_line;
while(<STDIN>){
  chomp;
  if ($_ =~ m/##/){
    next;
  }
  if ($_ =~ m/#CHR/){
    my @a = split(/\t/,$_);
    print "$a[9]\t$a[9]\t0\t0\t0\t0";
    foreach my $i (10..$#a){
      print "\n$a[$i]\t$a[$i]\t0\t0\t0\t0";
    }
    exit;
  }

}
