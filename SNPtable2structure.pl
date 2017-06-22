#!/bin/perl
use strict;
use warnings;

#This converts a piped in snptable into structure format. It may have a population info file but doesn't need it.
#This also can remove non-biallelic sites;
#It also prints the percent missing data in the third column
my $popfile = $ARGV[0]; #Not manditory.
my $remove_non_bi = "TRUE";

my %pop;
if($popfile){
  open POP, $popfile;
  while(<POP>){
    chomp;
    my @a = split(' ',$_);
    $pop{$a[0]} = $a[1];
  }
}

my %d;
$d{"A"} = "1";
$d{"C"} = "2";
$d{"G"} = "3";
$d{"T"} = "4";
$d{"N"} = "-9";
my $counter = 0;
my %sample;
my %data;
my $n_samples;
my %missing;
my %total;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($. == 1){
    $n_samples = $#a;
    foreach my $i (2..$#a){
      $sample{$i} = $a[$i];
    }
  }else{
    my %alleles;
    foreach my $i (2..$#a){
      if ($a[$i] eq "NN"){next;}
      my @genotype = split(//,$a[$i]);
      $alleles{$genotype[0]}++;
      $alleles{$genotype[1]}++;
    }
    my $n_alleles = scalar keys %alleles;
    if (($n_alleles != 2) and ($remove_non_bi eq "TRUE")){next;}
    $counter++;
    foreach my $i (2..$#a){
      if ($a[$i] eq "NN"){$missing{$i}++;}
      my @genotype = split(//,$a[$i]);
      $data{$counter}{$i}{0} = $d{$genotype[0]};
      $data{$counter}{$i}{1} = $d{$genotype[1]};
      $total{$i}++;
    }
  }
}
my $notfirst_line;
foreach my $i (2..$n_samples){
  unless ($missing{$i}){$missing{$i} = 0};
  my $percent_missing = $missing{$i} / $total{$i};
  my $actual_sites = $total{$i} - $missing{$i};
  my $current_pop = "NA";
  if ($pop{$sample{$i}}){
    $current_pop = $pop{$sample{$i}};
  }
  if ($notfirst_line){
    print "\n";
  }
  $notfirst_line++;
  print "$sample{$i}\t$current_pop\t$percent_missing\t$actual_sites\t.\t.";
  foreach my $j (1..$counter){
    print "\t$data{$j}{$i}{0}";
  }
  print "\n$sample{$i}\t$current_pop\t$percent_missing\t$actual_sites\t.\t.";
  foreach my $j (1..$counter){
    print "\t$data{$j}{$i}{1}";
  }
}
