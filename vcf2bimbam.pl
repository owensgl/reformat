#!/bin/perl
use strict;
use warnings;

#Requires no missing data. Doesn't take likelihoods into account. Requires biallelic data.
my $convert_chr = "TRUE"; #Set to TRUE to convert chromosomes to numeric and filter out non-number chromosomes. This is only set for the HanXRQChr prefix of the XRQ sunflower genome.
my $chr_prefix = "Ha412HOChr";
my $first;
while(<STDIN>){
  my $line = "$_";
  chomp $line;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
   next;
  }
  if ($line =~m/^#CHROM/){
   my $first_line;
   foreach my $i (9..$#fields){
    my $fam = "$fields[$i]";
    my $ID = $fields[$i];
    my $father = "0";
    my $mother = "0";
    my $sex = "0";
    my $phenotype = "-9";
   }
  }
  else{
   my $chr = $fields[0];
   if ($convert_chr){
    $chr =~ s/$chr_prefix//;
    if (($chr =~ m/MT/) or ($chr =~ m/CP/) or ($chr =~ m/00/)){next;}
   }
 
   my $pos = $fields[1];
   my $ref = $fields[3];
   my $alt = $fields[4];
   my $multi_alt;
   my @alts;
   @alts = split(/,/,$alt);
   if (length($alt) > 1){
    next;
   }
   if($first){
    print "\n";
   }else{
    $first++;
   }
   print "${chr}_$pos\t$ref\t$alt";
   foreach my $i (9..$#fields){
    my $genotype;
    my @info = split(/:/,$fields[$i]);
    my $call = $info[0];
    my $dp = $info[1];
    my @bases;
    if ($call =~ m/\//){
      @bases =split(/\//,$call);
    }elsif ($call =~ m/\|/){
      @bases=split(/\|/,$call);
    }
    if (($call eq './.') or ($call eq '.')){
print STDERR "\n$call\t$pos\t$i";
     print STDERR "Must not have missing data\n";
     exit;
    }
    my $summed_genotype = $bases[0] + $bases[1];
    print "\t$summed_genotype";
   }
   
  }
 }

