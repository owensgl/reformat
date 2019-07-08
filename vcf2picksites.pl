#!/bin/perl 
use warnings;
use strict;

#This script takes a list of sites (first two columns), and pulls them out from a vcf piped in.

my $sites = $ARGV[0];
my %sites;
open SITES, $sites;
while(<SITES>){
  chomp;
  my @a = split(/\t/,$_);
  $sites{$a[0]}{$a[1]}++;
}

close SITES;

while(<STDIN>){
  chomp;
  if ($. == 1){
    print "$_";
    next;
  }
  if ($_ =~ m/^#/){
    print "\n$_";
    next; 
  }
  my @a = split(/\t/,$_);
  if ($sites{$a[0]}{$a[1]}){
    print "\n$_";
  }
}

