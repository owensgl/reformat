#!/bin/perl
use strict;
use warnings;
#This counts the percent of 1/(n-1) heterozygotes that may come from barcode switching at different depths. From 5 to 15 total depth at the site.
my %sample;
my $max_dp = 15;
my $min_dp = 5;
my $max_loci = 10000000;
my %total;
my %rare_hets;
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
   if ($counter > $max_loci){goto PRINTOUT;}
   if ($counter % 500000 == 0){print STDERR "Currently processed $counter loci\n";}
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
     my $dp = $info[1];
     my $ref_dp = $info[3];
     my $alt_dp = $info[5];
     if (($dp >= $min_dp) and ($dp <= $max_dp)){
      $total{$sample{$i}}{$dp}++;
      if (($ref_dp == 1) or ($alt_dp == 1)){
       $rare_hets{$sample{$i}}{$dp}++;
      }
     }
     my $genotype = $info[0];
     my @bases = split('/',$genotype);
     if ($dp >= $min_dp){
      if (($ref_dp == 1) or ($alt_dp == 1)){
      print "$fields[$i]\n";
      if ($bases[0] eq $bases[1]){
#       print "Hom\t$dp\n";
      }else{
#       print "Het\t$dp\n";
      }
      }
     }
    }
   }
  }
}
PRINTOUT:
exit;
print "sample\tdepth\ttotal_sites\tunbalanced_hets";
foreach my $sample (sort values %sample){
 foreach my $dp ($min_dp..$max_dp){
  unless($total{$sample}{$dp}){
   $total{$sample}{$dp} = 0;
  }
  unless($rare_hets{$sample}{$dp}){
   $rare_hets{$sample}{$dp} = 0;
  }
  print "\n$sample\t$dp\t$total{$sample}{$dp}\t$rare_hets{$sample}{$dp}";
 }
}
