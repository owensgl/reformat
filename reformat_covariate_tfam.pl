#!/bin/perl
use strict;
use warnings;

my $tfam = $ARGV[0];

#Pipe in the covariate or phenotype file to reorganize.
#First column should be sample name. The rest of the columns are information.

my %info;
my $columns = 0;
while(<STDIN>){
  chomp;
  my @a = split(' ',$_);
  $columns = $#a - 1;
  foreach my $i (1..$#a){
    $info{$a[0]}{$i - 1} = $a[$i];
  }
}
open FILE, $tfam;
while(<FILE>){
  chomp;
  my @a = split(/\t/,$_);
  my $fam = $a[0];
  my $sample = $a[1];
  print "$fam\t$sample\t1";
  foreach my $i (0..$columns){
    if (exists $info{$sample}{$i}){
      print "\t$info{$sample}{$i}";
    }else{
      print "\tNA";
    }
  }
  print "\n";
}
