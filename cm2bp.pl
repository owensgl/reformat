#!/bin/perl
use warnings;
use strict;

my $map = $ARGV[0]; #In this, the chr is second col, cm is third and bp is fourth.
my %hash;
open MAP, $map;
while(<MAP>){
        chomp;
        my @a = split(/\t/,$_);
        if ($. ne "1"){
                if ($a[2] ne "NA"){
                        my $chrom = $a[0];
                        $hash{$chrom}{$a[1]} = $a[2];
                }
        }
}

close MAP;

my @cm_columns = qw(1 2);
while(<STDIN>){
  chomp;
  if ($. == 1){
    print "$_";
    next;}
  my @a = split(/\t/,$_);
  my $tmp = $a[0];
  $tmp =~ s/Ha//g;
  my $chr_n = sprintf ("%02d",$tmp);
  my $chr = "HanXRQChr".$chr_n;
  my %storage;
  foreach my $i (@cm_columns){
    my $cm = $a[$i];
    my %before_sites;
    my %after_sites;
    my $exact_site;
    foreach my $site (sort keys %{$hash{$chr}}){
      if ($hash{$chr}{$site} eq $cm){
        $exact_site = $site;
        goto PRINTSITE;
      }elsif ($hash{$chr}{$site} > $cm){
        $after_sites{$site}++;
      }else{
        $before_sites{$site}++;
      }
    }
    my @after_sites = (sort { $a <=> $b} keys %after_sites);
    my @before_sites = (sort { $b <=> $a} keys %before_sites);
    unless($after_sites[0]){
      $exact_site = $before_sites[0];
      goto PRINTSITE;
    }
    my $after_site = $after_sites[0];
    my $before_site = $before_sites[0];
    my $cm_distance_between_keys = $hash{$chr}{$after_site} - $hash{$chr}{$before_site};
    my $bp_distance_between_keys = $after_site - $before_site;
    my $bp_per_cm = $bp_distance_between_keys / $cm_distance_between_keys;
    my $before_to_target_cm = $cm - $hash{$chr}{$before_site};
    $exact_site = int($before_site + ($bp_per_cm * $before_to_target_cm));
    PRINTSITE:
    $storage{$i}= $exact_site;
  }
  print "\n$chr";
  foreach my $i (1..$#a){
    if ($storage{$i}){
      print "\t$storage{$i}";
    }else{
      print "\t$a[$i]";
    }
  }
}
