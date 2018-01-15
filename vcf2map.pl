#!/bin/perl
use warnings;
use strict;
#Turns a vcf file into a plink map file
my $first_line;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^#/){
    next;
  }
  my @a = split(/\t/,$_);
  my $chr = $a[0];
#  $chr =~ s/HanXRQChr//g;
  my $pos = $a[1];
  if ($first_line){
    print "\n";
  }else{
    $first_line++;
  }
  print "$chr\t${chr}_$pos\t0\t$pos";
}
