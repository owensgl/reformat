#!/bin/perl
use warnings;
use strict;
#This takes a vcf file and a list of samples, and converts it to the csvr format of rqtl
#NOTE: It converts 1/1 to 0/1 because it was written for a BC1 design
my $list = $ARGV[0];
my $min_dp = 10;
my %samples;
open LIST, $list;
while(<LIST>){
  chomp;
  $samples{$_}++;
}
close LIST;

my %name;
my @samples;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($_ =~ m/##/){next;}
  if ($_ =~ m/#/){
    print "pheno\t";
    foreach my $i (9..$#a){
      if ($samples{$a[$i]}){
        $name{$i} = $a[$i];
        push(@samples,$i);
        print "\t$i";
      }
    }
  }else{
    my $chr = $a[0];
    my $chr_numeric = $chr;
    $chr_numeric =~ s/HanXRQChr//g;
    if ($chr_numeric =~ m/c/){next;} #Skip contigs not in chromosomes.
    my $pos = $a[1];
    print "\n$chr.$pos\t$chr_numeric";
    foreach my $i (@samples){
      my @fields = split(/:/,$a[$i]);
      my $geno = "-";
      if ($fields[0] eq "0/0"){
        $geno = "A";
      }elsif ($fields[0] eq "0/1"){
        $geno = "H";
      }elsif ($fields[0] eq "1/1"){
	$geno = "H"; #For the BC1 design;
#        $geno = "B";
      }
      my $dp = $fields[2];
      if ($dp eq '.'){$dp = 0;}
      if ($dp < $min_dp){
        $geno = "-";
      }
      print "\t$geno";
    }
  }
}
