#!/bin/perl
use strict;
use warnings;

my $windowsize = 5000000;
my $start = 0;
my $end = $start+$windowsize;
my $mid = $start + ($windowsize/2);
my %data;
my $chr;
my $first_line;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^#/){next;}
  my @a = split(/\t/,$_);
  if (($chr) and ($chr ne $a[0])){
    print "\n$chr\t$mid";
    foreach my $i (2..17){
      print "\t$data{$i}";
    }
    $start = 0;
    $end = $start+$windowsize;
    $mid = $start + ($windowsize/2);
    undef(%data);
  }
  $chr = $a[0];
  my $pos = $a[1];
  if ($pos > $end){
    unless ($first_line){
      print "$chr\t$mid";
      $first_line++;
      foreach my $i (2..17){
        print "\t$data{$i}";
      }
      $start = $end;
      $end = $start+$windowsize;
      $mid = $start + ($windowsize/2);
      undef(%data);
    }else{
      print "\n$chr\t$mid";
      foreach my $i (2..17){
        print "\t$data{$i}";
      }
      $start = $end;
      $end = $start+$windowsize;
      $mid = $start + ($windowsize/2);
      undef(%data);
    }
  }
  foreach my $i (2..17){
    $data{$i}+=$a[$i];
  }
}
print "\n$chr\t$mid";
foreach my $i (2..17){
  print "\t$data{$i}";
}
