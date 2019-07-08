#!/bin/perl
#This takes a 3 column map file and outputs the necessary map file for relate
use strict;
use warnings;

my $previous_chr;
my $previous_pos;
my $previous_cm;
my $previous_rate;
my $map_prefix = $ARGV[0];
my $chr_prefix = "Ha412HOChr";

my %file_handle;
foreach my $i (1..17){
  my $chr = sprintf("%02d", $i);
  open ($file_handle{$chr}, '>', "$map_prefix.$chr.map");
  print {$file_handle{$chr}} "pos COMBINED_rate Genetic_Map";
}
while(<STDIN>){
  chomp;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  $chr =~ s/$chr_prefix//;
  my $pos = $a[1];
  my $cm = $a[2];
  if ($previous_chr){
    if ($previous_chr == $chr){
      #Its still in same chr;
      my $rate = ($cm - $previous_cm)*1000000/($pos - $previous_pos);
      print {$file_handle{$chr}} "\n$previous_pos $rate $previous_cm";
      #Refresh variables
      $previous_pos = $pos;
      $previous_chr = $chr;
      $previous_cm = $cm;
      $previous_rate = $rate;
    }else{
      #its a new chr
      print {$file_handle{$previous_chr}} "\n$previous_pos $previous_rate $previous_cm";
      #Refresh variables
      $previous_pos = $pos;
      $previous_chr = $chr;
      $previous_cm = $cm;
      $previous_rate = "NA";
    }
  }else{
    $previous_pos = $pos;
    $previous_chr = $chr;
    $previous_cm = $cm;
    $previous_rate = "NA";
  }
}
print {$file_handle{$previous_chr}} "\n$previous_pos $previous_rate $previous_cm";
