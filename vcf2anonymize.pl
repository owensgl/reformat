#!/bin/perl
use strict;
use warnings;

#This will anonymize a vcf file.
my $counter = 1;
while(<STDIN>){
  chomp;
  my $line = $_;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
    print "$_\n";
  }elsif ($line=~m/^#/){
    print "$line";
  }else{
    if ($counter > 50000){goto ENDSCRIPT;}
    my $chr = $fields[0];
    my $pos = $fields[1];
    my $alt = $fields[4];
    my $multi_alt;
    my @alts;
    @alts = split(/,/,$alt);
    if (length($alt) > 1){
      next;
    }
    $counter++;
    print "\nchrNA\t$counter";
    foreach my $i (2..$#fields){
      print "\t$fields[$i]";
    }
  }
}
ENDSCRIPT:
