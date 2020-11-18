#!/bin/perl
#This script takes a vcf file and outputs a baypass file
#example usage: cat tmp.vcf | perl vcf2baypass.pl tmp.grouplist.txt tmp2
use strict;
use warnings;
use POSIX;

my $pop_file = $ARGV[0];# list of population with ind \t pop
#Populations are ordered numerically in output, so easiest just label them 1, 2,3, etc
my $outprefix= $ARGV[1];

my %pop;
my %pop_list;
open POP, $pop_file;
while (<POP>){
    chomp;
  my @a = split(/\t/,$_);
  $pop{$a[0]} = $a[1];
  $pop_list{$a[1]}++;
}
close POP;

my @pops = sort { $a cmp $b } keys %pop_list;

open OUT1, ">$outprefix.pop_order";
foreach my $p (@pops){
        print OUT1 "$p\n";
}

open OUT_geno, ">$outprefix";
open OUT_loci, ">$outprefix.loci";

my $first_line;
my %ind;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^##/){next;}
  my @a = split(/\t/,$_);
  if ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      unless ($pop{$a[$i]}){
        die "$a[$i] sample not found in population file\n";
      }
      $ind{$i} = $pop{$a[$i]};
    }
  }else{
    my $chr = $a[0];
    my $pos = $a[1];
    my $ref = $a[3];
    if (length($ref) > 1){
      print STDERR "For $chr $pos skipping due to ref $ref being longer than 1 base.\n";
      next;
    }
    my $alt = $a[4];
    if (length($alt) > 1){
      print STDERR "For $chr $pos skipping due to alt $alt being longer than 1 base, and possibly multiallelic\n";
      next;
    }
    my %geno_counts;
    foreach my $i(9..$#a){
      my @tmp = split(/:/,$a[$i]);
      my $call = $tmp[0];
      my $current_call;
      if (($call eq ".") or ($call eq "./.")){
        next;
      }else{
        my @bases = split(/\//,$call);
        $geno_counts{$ind{$i}}{$bases[0]}++;
        $geno_counts{$ind{$i}}{$bases[1]}++;
      }
    }
    foreach my $n (0..$#pops){
      unless($geno_counts{$pops[$n]}{0}){
        $geno_counts{$pops[$n]}{0} = 0;
      }
      unless($geno_counts{$pops[$n]}{1}){
        $geno_counts{$pops[$n]}{1} = 0;
      }
    }
    if ($first_line){
      print OUT_geno "\n";
    }else{
      $first_line++;
    }
    foreach my $n (0..($#pops-1)){
      print OUT_geno "$geno_counts{$pops[$n]}{0} ";
      print OUT_geno "$geno_counts{$pops[$n]}{1} ";
    }
    print OUT_geno "$geno_counts{$pops[$#pops]}{0} ";
    print OUT_geno "$geno_counts{$pops[$#pops]}{1}";
    print OUT_loci "$chr\t$pos\n";
  }
}
    

