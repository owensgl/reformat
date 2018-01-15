#!/bin/perl
use strict;
use warnings;

#This file outputs to tped format, with plink -recode 12 coding. Only outputs biallelic sites
my $outprefix = $ARGV[0];
my $convert_chr = "TRUE"; #Set to TRUE to convert chromosomes to numeric and filter out non-number chromosomes. This is only set for the HanXRQChr prefix of the XRQ sunflower genome.
open(my $tped, '>', "$outprefix.tped");
open(my $tfam, '>', "$outprefix.tfam");
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
    my $fam = "1";
    my $ID = $fields[$i];
    my $father = "0";
    my $mother = "0";
    my $sex = "0";
    my $phenotype = "-9";
    unless ($first_line){
     print $tfam "$fam\t$ID\t$father\t$mother\t$sex\t$phenotype";
     $first_line++;
    }else{ 
     print $tfam "\n$fam\t$ID\t$father\t$mother\t$sex\t$phenotype";
    }
   }
  }
  else{
   my $chr = $fields[0];
   if ($convert_chr){
    $chr =~ s/HanXRQChr//;
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
    print $tped "\n";
   }else{
    $first++;
   }
   print $tped "$chr\t ${chr}_$pos\t0\t$pos";
   foreach my $i (9..$#fields){
    my $genotype;
    if ($fields[$i] ne '.'){
     my @info = split(/:/,$fields[$i]);
     my $call = $info[0];
     my $dp = $info[1];
     my @bases = split(/\//,$call);
     foreach my $j (0..1){
      if ($bases[$j] eq "0"){
       #$genotype .= $ref;
        $genotype .= "1";
      }elsif ($bases[$j] eq "1"){
#       $genotype .= $alts[0];
       $genotype .= "2";
      }elsif ($bases[$j] eq "2"){
       $genotype .= $alts[1];
      }elsif ($bases[$j] eq "3"){
       $genotype .= $alts[2];
      }elsif ($bases[$j] eq "."){
       $genotype = "00";
       goto NEXTSAMPLE;
      }
     }
     NEXTSAMPLE:
    }else{
     $genotype = "00";
    }
unless($genotype){ print STDERR "$chr\t$pos\n";}
    my @bases = split(//,$genotype);
    print $tped "\t$bases[0]\t$bases[1]";
   }
   
  }
 }

