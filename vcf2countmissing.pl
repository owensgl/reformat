#!/bin/perl
use strict;
use warnings;
#This counts the percent of 1/(n-1) heterozygotes that may come from barcode switching at different depths. From 5 to 15 total depth at the site.
my %sample;
my $sites;
my %missing;
my $counter;
while(<STDIN>){
  my $line = "$_";
  chomp $line;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
   next;
  }
  if ($line =~m/^#CHROM/){
   foreach my $i (9..$#fields){
    $sample{$i} = $fields[$i];
   }
  }
  else{
   $counter++;
   $sites++;
   if ($counter % 500000 == 0){print STDERR "Currently processed $counter loci\n";}
   foreach my $i (9..$#fields){
    if ($fields[$i] eq '.'){
     $missing{$sample{$i}}++;
    }else{
     my @info = split(/:/,$fields[$i]);
     if ($info[0] eq './.'){
      $missing{$sample{$i}}++;
     }
    }
   }
  }
}
print "sample\tpercent_missing";
foreach my $sample (sort values %sample){
 unless($missing{$sample}){
  $missing{$sample} = 0;
 }
 my $percent_missing = $missing{$sample}/$sites;
 print "\n$sample\t$percent_missing";
}
