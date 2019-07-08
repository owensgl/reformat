#!/bin/perl
use warnings;
use strict;
use POSIX;
use List::Util qw(sum);
#This script takes the output of vcftools geno-r2 and calculates the number of pairs above some thresholds.

my $window_size = 500000;
my %r2_hash;
my %r2_scores;
my %count_hash;
my %max_hash;
my %max_2_hash;
my %sum_hash;
my $current_window = 0;
my $current_chr = "NA";
print "chr\twin1\twin2\tn\tmean_r2\tmax_r2\tmax_2_r2";
my %r2_values;
while(<STDIN>){
  chomp;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos1 = $a[1];
  my $pos2 = $a[2];
  my $r2 = $a[4];
  my $window1 = floor($pos1/$window_size)*$window_size;
  my $window2 = floor($pos2/$window_size)*$window_size;
  $count_hash{$chr}{$window1}{$window2}++;
  $sum_hash{$chr}{$window1}{$window2}+=$r2;
  if ($current_window != $window1){
    foreach my $current_window2 (sort {$a<=>$b} keys %{$count_hash{$current_chr}{$current_window}}){
#      print "$current_window2 TRYING!\n";
      my $mean_r2 = $sum_hash{$current_chr}{$current_window}{$current_window2}/$count_hash{$current_chr}{$current_window}{$current_window2};
      print "\n$current_chr\t$current_window\t$current_window2\t$count_hash{$current_chr}{$current_window}{$current_window2}\t$mean_r2";
      print "\t$max_hash{$current_chr}{$current_window}{$current_window2}";
      print "\t$max_2_hash{$current_chr}{$current_window}{$current_window2}";
    }
  }
  $current_chr = $chr;
  $current_window = $window1;
  unless($max_hash{$chr}{$window1}{$window2}){
    $max_hash{$chr}{$window1}{$window2} = $r2;
    $max_2_hash{$chr}{$window1}{$window2} = $r2;
  }
  if ($r2 > $max_hash{$chr}{$window1}{$window2}){
    $max_2_hash{$chr}{$window1}{$window2} = $max_hash{$chr}{$window1}{$window2};
    $max_hash{$chr}{$window1}{$window2} = $r2;
  }elsif ($r2 > $max_2_hash{$chr}{$window1}{$window2}){
    $max_2_hash{$chr}{$window1}{$window2} = $r2;
  }
}

foreach my $current_window2 (sort {$a<=>$b} keys %{$count_hash{$current_chr}{$current_window}}){
  my $mean_r2 = $sum_hash{$current_chr}{$current_window}{$current_window2}/$count_hash{$current_chr}{$current_window}{$current_window2};
  print "\n$current_chr\t$current_window\t$current_window2\t$count_hash{$current_chr}{$current_window}{$current_window2}\t$mean_r2";
  print "\t$max_hash{$current_chr}{$current_window}{$current_window2}";
  print "\t$max_2_hash{$current_chr}{$current_window}{$current_window2}";
}
