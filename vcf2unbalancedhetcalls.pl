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
     my $state = "homo";
     if ($info[0] eq "0/1"){
       $state = "het";
     }
#     unless($info[0] eq "0/1"){next};
     if ($info[2]){
       my $depth = $info[1];
       my @dp = split(/,/,$info[2]);
       if (($dp[0] eq 1) or ($dp[1] eq 1)){
         $total{$depth}{$state}++;
       }
     }
    }
   }
  }
}
print "depth\tpercent_het";
foreach my $depth (sort {$a <=> $b} keys %total){
  unless($total{$depth}{'het'}){
    $total{$depth}{'het'} = 0;
  }
  my $percent = $total{$depth}{'het'} / ($total{$depth}{'homo'} + $total{$depth}{'het'});
  print "\n$depth\t$percent";
}
