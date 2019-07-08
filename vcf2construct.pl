#!/bin/perl
use strict;
use warnings;

my $popfile = $ARGV[0];
my $count = 1;
my $subset = "TRUE";
my $subset_value = 100; #Print every nth line;
my %info;
open POP, $popfile;
my %groups;
while(<POP>){
  chomp;
  my @a = split(/\t/,$_);
  $info{$a[0]} = $a[1];
  $groups{$a[1]}++;
}
close POP;

my %pop;
my %altcount;
my %datacount;
my @sitelist;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($_ =~ m/^##/){
    next;
  }elsif ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      if ($info{$a[$i]}){
        $pop{$i}= $info{$a[$i]};
      }
    }
  }else{
    my $chr = $a[0];
    my $pos = $a[1];
    my $ref = $a[3];
    my $alt = $a[4];
    if ((length($ref) > 1) or (length($alt) > 1)){
      next; #Skip sites with more than two alleles or indels
    }
    $count++;
    if ($subset eq "TRUE"){
      if ($count % $subset_value != 0){next;}
    }
    if ($count % 10000 == 0){
      print STDERR "Loading $chr $pos...\n";
    }
    push (@sitelist,"$chr.$pos");
    foreach my $i (9..$#a){
      unless ($pop{$i}){next;}
      my $full = $a[$i];
      if ($full eq '.'){
#	print STDERR "FULL MISSING DATA\n";
	next;}
      my @info = split(/:/,$full);
      if ($info[0] eq './.'){
#	print STDERR "MISSING DATA\n";
	next;}
      my @bases = split('/',$info[0]);
      my $call;
      foreach my $n (0..1){
	if ($bases[$n] eq '.'){goto NEXTLINE;}
        $altcount{"$chr.$pos"}{$pop{$i}}+=$bases[$n];
        $datacount{"$chr.$pos"}{$pop{$i}}++;
      }
      NEXTLINE:
    }
  }
}
print "sample";
foreach my $loc (@sitelist){
  print "\t$loc";
}
foreach my $pop (sort keys %groups ){
  print "\n$pop";
  foreach my $loc (@sitelist){
    my $freq;
    unless ($datacount{$loc}{$pop}){
      $freq = "NA";
    }else{
      unless($altcount{$loc}{$pop}){
        $altcount{$loc}{$pop} = 0;
      }
      $freq = $altcount{$loc}{$pop} / $datacount{$loc}{$pop};
    }
    print "\t$freq";
  }
}
