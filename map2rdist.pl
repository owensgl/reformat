#!/bin/perl
use warnings;
use strict;
use Statistics::Basic qw(:all);
#This takes a genetic map file, and outputs the recombination rate per bp. This recombination rate is 1/100 cM.

my $previous_cm;
my $previous_pos;
my $current_chr;
my $distances;
print "r";
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $cm = $a[2];
  unless($current_chr){
    $current_chr = $chr;
  }
  if ($current_chr ne $chr){
    undef($previous_cm);
    undef($previous_pos);
    $current_chr = $chr;
  }
  if ($previous_cm){
    my $cm_dist = $cm - $previous_cm;
    my $pos_dist = $pos - $previous_pos;
    my $cm_per_bp = ($cm_dist/100)/$pos_dist;
    print "\n$cm_dist\t$cm_per_bp";
    $previous_cm = $cm;
    $previous_pos = $pos;
  }else{
    $previous_cm = $cm;
    $previous_pos = $pos;
  }
}
