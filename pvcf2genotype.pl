#!/bin/perl 
use warnings;
use strict;

#This script takes a phased and imputed vcf file and converts it to genotypes format for inveRsion.
my $file_prefix = $ARGV[0];

my %genotypes;
my %sites;
my $current_chr;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($_ =~ m/#/){next;}
  my $chr = $a[0];
  my $pos = $a[1];
  unless($current_chr){
    $current_chr = $chr;
  }
  if ($current_chr ne $chr){
    my $filename = "$file_prefix.$current_chr.txt";
    open(my $fh, '>', $filename);
    my $first_field;
    foreach my $pos (sort {$a <=> $b} keys %sites){
      unless($first_field){
        print $fh "$pos";
        $first_field++;
      }else{
        print $fh " $pos";
      }
    }
    foreach my $sample (sort keys %genotypes){
      my $first;
      foreach my $pos (sort {$a <=> $b} keys %sites){
        unless($first){
          print $fh "\n$genotypes{$sample}{$pos}";
          $first++;
        }else{
          print $fh " $genotypes{$sample}{$pos}";
        }
      }
    }
    close $fh;
    undef(%sites);
    undef(%genotypes);
    $current_chr = $chr;  
  }
  $sites{$pos}++;
  foreach my $i (9..$#a){
    my $genotype = 0;
    if ($a[$i] eq '0|1'){
      $genotype = 1;
    }elsif ($a[$i] eq '1|0'){
      $genotype = 1;
    }elsif ($a[$i] eq '1|1'){
      $genotype = 2;
    }
    $genotypes{$i}{$pos} = $genotype;
  }
}

    my $filename = "$file_prefix.$current_chr.txt";
    open(my $fh, '>', $filename);
    my $first_field;
    foreach my $pos (sort {$a <=> $b} keys %sites){
      unless($first_field){
        print $fh "$pos";
        $first_field++;
      }else{
        print $fh " $pos";
      }
    }
    foreach my $sample (sort keys %genotypes){
      my $first;
      foreach my $pos (sort {$a <=> $b} keys %sites){
        unless($first){
          print $fh "\n$genotypes{$sample}{$pos}";
          $first++;
        }else{
          print $fh " $genotypes{$sample}{$pos}";
        }
      }
    }
    close $fh;
