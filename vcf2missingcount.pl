#!/bin/perl
use warnings;
use strict;

#This counts the amount of missing data per sample and prints it out.

my %samples;
my %missing;
my %present;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^##/){next;}
  my @a = split(/\t/,$_);
  if ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      $samples{$i} = $a[0];
    }
  }else{
    foreach my $i (9..$#a){
      if ($a[0] eq '.'){
        $missing{$samples{$i}}++;
      }else{
        my @fields = split(/\t/,$a[$i]);
        if ($fields[0] eq './.'){
          $missing{$samples{$i}}++;
        }else{
          $present{$samples{$i}}++;
        }
      }
    }
  }
}
print "sample\tgenotyped\tmissing\tpercent_missing";
foreach my $i (sort keys %samples){
  unless($missing{$samples{$i}}){
    $missing{$samples{$i}} = 0;
  }
  unless($present{$samples{$i}}){
    $present{$samples{$i}} = 0;
  }
  my $percent = $missing{$samples{$i}} / ($missing{$samples{$i}} +$present{$samples{$i}});
  print "\n$sample{$i}\t$present{$samples{$i}}\t$missing{$samples{$i}}\t$percent";
}
