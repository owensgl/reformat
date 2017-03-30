#!/bin/perl
#This script takes a vcf file phased by beagle, and outputs a vcf, by windows
use strict;
use warnings;

my $tag = $ARGV[0]; #Thing to stick on fasta names

my %ind;
my %sites;
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
    foreach my $i(9..$#a){
      my @tmp = split(/:/,$a[$i]);
      my $call = $tmp[0];
      my @bases = split(/\|/,$call);
      foreach my $j (0..1){
        if ($bases[$j] == 0){
          $sites{$ind{$i}}{$j} .= $ref;
        }else{
          $sites{$ind{$i}}{$j} .= $alt;
        }
      }
    }
  }
}
&print_fasta;

sub print_fasta {
  my $file = $tag."."."fasta";
  open my $output,">$file" or die "Can't open the output file!";
  my @a = sort values %ind;
  foreach my $i (0..$#a){
    foreach my $j (0..1){
      print $output ">$a[$i] strand_$j\n";
      print $output "$sites{$a[$i]}{$j}\n";
    }
  }
  close $output;
}
