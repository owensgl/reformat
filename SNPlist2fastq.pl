#!/bin/perl
use strict;
use warnings;

#This script takes a list of SNPs in their genomic context and turns the, into a fastq file for alignment
#Three columns in input, snpname, sequence (with variable site in []) and success(Yes or No).

my $first_line;
while(<STDIN>){
  chomp;
  s/^\s+//g; # no leading white spaces 
  next unless length;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $name=$a[0];
  my $seq = $a[1];
  my $success = $a[2];
  my @bases = split(//,$seq);
  #Find where the SNP is in the sequence
  my $startofsnp;
  for my $i (0..$#bases){
    if ($bases[$i] eq '['){
      $startofsnp = $i;
    }
  }
  my $ref=$bases[$startofsnp+1];
  my $alt=$bases[$startofsnp+3];
  #Print ref sequence
  if ($first_line){
    print "\n";
  }else{
    $first_line++;
  }
  print "@"."${name}_${ref}_${startofsnp}_$success";
  print "\n";
  foreach my $i (0..($startofsnp-1)){
    print "$bases[$i]";
  }
  print "$ref";
  foreach my $i (($startofsnp+5)..$#bases){
    print "$bases[$i]";
  }
  print "\n";
  print "+\n";
  foreach my $i (0..($#bases-4)){
    print "H";
  }
  #print alt sequence
  print "\n@"."${name}_${alt}_${startofsnp}_$success";
  print "\n";
  foreach my $i (0..($startofsnp-1)){
    print "$bases[$i]";
  }
  print "$alt";
  foreach my $i (($startofsnp+5)..$#bases){
    print "$bases[$i]";
  }
  print "\n";
  print "+\n";
  foreach my $i (0..($#bases-4)){
    print "H";
  }
}
