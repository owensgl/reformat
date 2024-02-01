#!/bin/perl
#This script takes a beagle phased vcf file and outputs a fasta.
use strict;
use warnings;


my %ind;
my %sites;
my $window_size = 10;
my $current_window = 0;
my $window_start = "NA";
my $window_end = "NA";
my $current_chr = "NA";
while(<STDIN>){
  chomp;
  if ($_ =~ m/^##/){next;}
  my @a = split(/\t/,$_);
  if ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      $ind{$i} = $a[$i];
    }
  }else{
    my $chr = $a[0];
    my $pos = $a[1];
    my $ref = $a[3];
    my $alt = $a[4];
    if ($window_start eq "NA"){
      $window_start = $pos;
    }
    $window_end = $pos;
    $current_chr = $chr;
    foreach my $i(9..$#a){
      my @bases = split(/\|/,$a[$i]);
      my $current_call;
      foreach my $j (0..1){
        if ($bases[$j] eq "0"){
          $current_call = $ref;
          $sites{$ind{$i}}{$j} .= $current_call;
        }elsif($bases[$j] eq "1"){
          $current_call = $alt;
          $sites{$ind{$i}}{$j} .= $current_call;
        }
      }
    }
    $current_window++;
    if ($current_window >= $window_size){
      my $outputfile = "$chr.$window_start.$window_end.fa";
      open(FH, '>', $outputfile) or die $!;
      &print_fasta;
      close(FH);
      %sites = ();
      $current_window = 0;
      $window_start = "NA";

    }
  }
}
if ($current_window > 0){
  my $outputfile = "$current_chr.$window_start.$window_end.fa";
  open(FH, '>', $outputfile) or die $!;
  &print_fasta;
  close(FH);
}


sub print_fasta {
  my @a = sort values %ind;
  foreach my $i (0..$#a){
    foreach my $j (0..1){
      print FH ">$a[$i].$j\n";
      print FH "$sites{$a[$i]}{$j}\n";
    }

  }
}
