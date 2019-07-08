#!/bin/perl
use warnings;
use strict;
use POSIX;

#This script takes the output of vcftools geno-r2 and calculates the Nth highest R2 between windows of the genome.

my $window_size = 500000;
my $rank_printed = 2; #Which rank score should it print out per window.
my %r2_hash;
my %count_hash;
my $current_window = 0;
my $current_chr = "NA";
print "chr\twin1\twin2\trank_$rank_printed\tn";
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
  if ($current_window != $window1){
    foreach my $current_window2 (sort {$a<=>$b} keys %{$r2_hash{$current_chr}{$current_window}}){
      print "\n$current_chr\t$current_window\t$current_window2\t$r2_hash{$current_chr}{$current_window}{$current_window2}{$rank_printed}\t$count_hash{$current_chr}{$current_window}{$current_window2}";
    }
  }
  $current_chr = $chr;
  $current_window = $window1;
  unless($r2_hash{$chr}{$window1}{$window2}{1}){
    foreach my $n (1..$rank_printed){
      $r2_hash{$chr}{$window1}{$window2}{$n} = 0;
    }
  }
  foreach my $n (1..$rank_printed){
    if ($r2 >= $r2_hash{$chr}{$window1}{$window2}{$n}){ #If the new sample is top ranked.
    #Move all stored values down the chain.
      foreach my $m ($n..$rank_printed){
        $r2_hash{$chr}{$window1}{$window2}{$m+1} = $r2_hash{$chr}{$window1}{$window2}{$m};
      }
      $r2_hash{$chr}{$window1}{$window2}{$n} = $r2;
      goto NEXTSTEP;
    }
  }
  NEXTSTEP:
}
exit;
#Older print statement
print "chr\twin1\twin2\trank_$rank_printed\tn";
foreach my $chr (sort keys %r2_hash){
  foreach my $window1 (sort {$a<=>$b} keys %{$r2_hash{$chr}}){
    foreach my $window2 (sort {$a<=>$b} keys %{$r2_hash{$chr}{$window1}}){
      print "\n$chr\t$window1\t$window2\t$r2_hash{$chr}{$window1}{$window2}{$rank_printed}\t$count_hash{$chr}{$window1}{$window2}";
    }
  }
}
