#!/bin/perl
use warnings;
use strict;
#This turns the ubc annotation bed file into a more easily readable bed file. 
my $first_line;
my @genes;
my %start;
my %stop;
my %chr;
my %product;
my %pos_gene;
my $genecount = 0;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($a[3] =~ m/mRNA/){
    $genecount++;
    if ($genecount % 5000 == 0){ 
      print STDERR "Processed $genecount genes\n";
    }
    my $chr = $a[0];
    my $start = $a[1];
    my $end = $a[2];
    my @info = split(/;/,$a[9]);
    my $gene = $info[1];
    $gene =~ s/Parent=//;
    my $description = "NA";
    foreach my $n (3..$#info){
      if ($info[$n] =~ m/^product/){
        $description = $info[$n];
        $description =~ s/product=//;
        $description =~ s/%3B/;/g;
        $description =~ s/%2C/,/g;
      }
    }
    push (@genes, $gene);
    $start{$gene} = $start;
    $stop{$gene} = $end;
    $chr{$gene} = $chr;
    $pos_gene{$chr.$start.$end} = $gene;
    $product{$gene} = $description;
  }
  if ($a[3] =~ m/^match/){
    my $chr = $a[0];
    my $start = $a[1];
    my $end = $a[2];
    my $gene;
    if ($pos_gene{$chr.$start.$end}){
      $gene = $pos_gene{$chr.$start.$end};
    }else{
      next;
    }
    my @info = split(/;/,$a[9]);
    my $description = "NA";
    foreach my $n (3..$#info){
      if ($info[$n] =~ m/^product/){
        $description = $info[$n];
        $description =~ s/product=//;
        $description =~ s/%3B/;/g;
        $description =~ s/%2C/,/g;
      }
    }
    if ($description ne "NA"){
      if ($description ne $product{$gene}){
        $product{$gene} .= "/ $description";
      }
    }
  }
}


foreach my $gene (@genes){
   if ($first_line){
     print "\n$gene\t$chr{$gene}\t$start{$gene}\t$stop{$gene}\t$product{$gene}";
   }else{
     print "$gene\t$chr{$gene}\t$start{$gene}\t$stop{$gene}\t$product{$gene}";
     $first_line++;
  }
}
