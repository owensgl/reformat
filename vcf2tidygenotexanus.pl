#!/bin/perl
use warnings;
use strict;
#This takes a vcf file, a list of samples (with location and generation) and a list of SNPs (where debilis allele is known).
#This outputs the genotypes in tidy format for plotting.
my $min_dp = 10;
my %samples;
my %loc;
my %gen;
my $list = "/home/owens/working/texanus/texanus.sampleinfo.txt";

open LIST, $list;
while(<LIST>){
  chomp;
  my @a = split(/\t/,$_);
  my $name = $a[0];
  my $gen = $a[2];
  my $loc = $a[5];
  my $type = $a[4];
  if ($type ne "BC"){next;} #Remove wild types
  my $seq = $a[9];
  if (($seq ne "GBS2") and ($seq ne "both")){next;} #Remove GBS1 samples
  $samples{$name}++;
  $gen{$name} = $gen;
  $loc{$name} = $loc;
}
close LIST;
my $snplist;
my %sites;
if ($ARGV[0]){
  $snplist = $ARGV[0];
  open SNP, $snplist;
  while(<SNP>){
    chomp;
    my @a = split(/\t/,$_);
    my $chr = $a[0];
    my $pos = $a[1];
    my $parent = $a[2];
    $sites{$chr}{$pos} = $parent;
  }
}

print "sample\tlocation\tgen\tchr\tpos\tparent\tgenotype";
my %name;
my @samples;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($_ =~ m/##/){next;}
  if ($_ =~ m/#/){
    foreach my $i (9..$#a){
      if ($samples{$a[$i]}){
        $name{$i} = $a[$i];
        push(@samples,$i);
      }
    }
  }else{
    my $chr = $a[0];
    my $pos = $a[1];
    if (%sites){
      unless ($sites{$chr}{$pos}){next;}
    }

    foreach my $i (@samples){
      if ($a[$i] eq "."){next};
      my @fields = split(/:/,$a[$i]);
      my $geno = "NA";
      if ($fields[0] eq "0/0"){
        $geno = "0";
      }elsif ($fields[0] eq "0/1"){
        $geno = "1";
      }elsif ($fields[0] eq "1/1"){
	$geno = "2"; #For the BC1 design;
#        $geno = "B";
      }
      my $dp = $fields[2];
      if ($dp eq '.'){$dp = 0;}
      if ($dp < $min_dp){
        $geno = "NA";
      }
      print "\n$name{$i}\t$loc{$name{$i}}\t$gen{$name{$i}}\t$chr\t$pos\t$sites{$chr}{$pos}\t$geno";
    }
  }
}
