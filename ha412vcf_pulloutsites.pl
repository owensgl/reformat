#!/bin/perl
use warnings;
use strict;

#This script takes a vcf that has been converted to HA412, and extracts just position comparisons. 

print "HA412_chr\tHA412_pos\tXRQ_chr\tXRQ_pos";
while(<STDIN>){
  chomp;
  if ($_ =~ m/^#/){next;}
  my @a = split(/\t/,$_);
  print "\n$a[0]\t$a[1]";
  my @info = split(/;/,$a[7]);
  my $xrq = $info[$#info];
  $xrq =~ s/XRQ=//g;
  my @xrq = split(/\./,$xrq);
  print "\t$xrq[0]\t$xrq[1]";
}
