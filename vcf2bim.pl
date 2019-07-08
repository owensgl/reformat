#!/bin/perl
use strict;
use warnings;

#This script takes a VCF from GATK and creates a .bim format 
my $first_line;
while(<STDIN>){
  chomp;
  if ($_ =~ m/#/){
    next;
  }
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  $chr =~ s/HanXRQChr//g;
  my $pos = $a[1];
  my $ref = $a[3];
  my $alt = $a[4];
  unless ($first_line){
    print "$chr\t${chr}_$pos\t0\t$pos\t$ref\t$alt";
    $first_line++;
    next;
  }
  print "\n$chr\t${chr}_$pos\t0\t$pos\t$ref\t$alt";
}
