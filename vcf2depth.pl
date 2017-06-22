#!/bin/perl
use strict;
use warnings;
#This counts the percent of 1/(n-1) heterozygotes that may come from barcode switching at different depths. From 5 to 15 total depth at the site.
my %sample;
my %total;
my $counter;
while(<STDIN>){
  my $line = "$_";
  chomp $line;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
   next;
  }
  else{
   my $alt = $fields[4];
   my $multi_alt;
   my @alts;
   @alts = split(/,/,$alt);
   if (length($alt) > 1){
    next;
   }
   foreach my $i (9..$#fields){
    if ($fields[$i] ne '.'){
     my @info = split(/:/,$fields[$i]);
     if ($info[2]){
       my $dp = $info[2];
       $total{$dp}++;
     }
    }
   }
  }
}
print "depth\tcount";
foreach my $depth (sort {$a <=> $b} keys %total){
  print "\n$depth\t$total{$depth}";
}
