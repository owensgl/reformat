#!/bin/perl
use warnings;
use strict;
#This takes a vcf file and a list of samples, and converts it to the csvr format of rqtl
#NOTE: It converts 1/1 to 0/1 because it was written for a BC1 design
my $list = $ARGV[0];
my $min_dp = 10;
my %samples;
my $total_samples = 0;
open LIST, $list;
while(<LIST>){
  chomp;
  $samples{$_}++;
  $total_samples++;
}
close LIST;

print "population_type DH";
print "\npopulation_name tmp";
print "\ndistance_function kosambi";
print "\ncut_off_p_value 0.000001";
print "\nno_map_dist 15.0";
print "\nno_map_size 2";
print "\nmissing_threshold 0.5";
print "\nestimation_before_clustering yes";
print "\ndetect_bad_data yes";
print "\nobjective_function COUNT";
print "\nnumber_of_loci XX";
print "\nnumber_of_individual $total_samples";


my %name;
my @samples;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($_ =~ m/##/){next;}
  if ($_ =~ m/#/){
    print "\nlocus_name";
    foreach my $i (9..$#a){
      if ($samples{$a[$i]}){
        $name{$i} = $a[$i];
        push(@samples,$i);
        print "\t$a[$i]";
      }
    }
  }else{
    my $chr = $a[0];
    my $chr_numeric = $chr;
    $chr_numeric =~ s/HanXRQChr//g;
    if ($chr_numeric =~ m/c/){next;} #Skip contigs not in chromosomes.
    my $pos = $a[1];
    print "\n$chr.$pos";
    foreach my $i (@samples){
      my @fields = split(/:/,$a[$i]);
      my $geno = "-";
      if ($fields[0] eq "0/0"){
        $geno = "A";
      }elsif ($fields[0] eq "0/1"){
        $geno = "X";
      }elsif ($fields[0] eq "1/1"){
	$geno = "X"; #For the BC1 design;
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
