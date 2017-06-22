#!/bin/perl
use strict;
use warnings;
#This takes a list of samples with populations. It calculates the percent of alelele sharing between individuals of the same
my $popinfo = $ARGV[0];
my $max_sites = 10000000;
my $min_depth = 1;
my $counter;
my %pophash;
my %temp_hash;
my @populations;
my %pop_array;
open POP, $popinfo;
while(<POP>){
 chomp;
 if ($. == 1){next;}
 my @a = split(/\t/,$_);
 my $sample = $a[0];
 my $pop = $a[1];
 $pophash{$sample} = $pop;
 unless($temp_hash{$pop}){
  push(@populations,$pop);
  $temp_hash{$pop}++;
 }
 push(@{$pop_array{$pop}},$sample);
}

my %sample;
my %shared_allele_hash;
my %count_hash;
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
    $sample{$i} = $fields[$i];
   }
  }
  else{
   $counter++;
   if ($counter > $max_sites){goto PRINTTOTALS;}
   if ($counter % 100000 == 0){print STDERR "Processed $counter sites\n";}
   my $alt = $fields[4];
   my $multi_alt;
   my @alts;
   @alts = split(/,/,$alt);
   if (length($alt) > 1){
    next;
   }
   my %genohash;
   foreach my $i (9..$#fields){
    my $genotype;
    if ($fields[$i] ne '.'){
     my @info = split(/:/,$fields[$i]);
     my $call = $info[0];
     my $dp = $info[1];
     if ($dp < $min_depth){
      $genotype = "NA";
      next;
     }
     my @bases = split(/\//,$call);
     foreach my $j (0..1){
      if ($bases[$j] eq "0"){
       #$genotype .= $ref;
        $genotype += 0;
      }elsif ($bases[$j] eq "1"){
#       $genotype .= $alts[0];
       $genotype +=1;
      }elsif ($bases[$j] eq "."){
       $genotype = "NA";
       goto PRINTGENOTYPE;
      }
     }
     PRINTGENOTYPE:
    }else{
     $genotype = "NA";
    }
    $genohash{$sample{$i}} = $genotype;
   }
   foreach my $pop (@populations){
    foreach my $i (0..($#{$pop_array{$pop}}-1)){
     foreach my $j (($i+1)..$#{$pop_array{$pop}}){
      if (($genohash{$pop_array{$pop}[$i]} ne "NA") and ($genohash{$pop_array{$pop}[$j]} ne "NA")){
       $count_hash{"$pop_array{$pop}[$i]\t$pop_array{$pop}[$j]"}++;
       if (abs($genohash{$pop_array{$pop}[$i]} - $genohash{$pop_array{$pop}[$j]}) ne 2){
        $shared_allele_hash{"$pop_array{$pop}[$i]\t$pop_array{$pop}[$j]"}++;
       }
      }
     }
    }
   }
  }
 }
PRINTTOTALS:
print "sample1\tsample2\ttotalsites\tshared";
foreach my $pair (sort keys %count_hash){
 unless ($shared_allele_hash{$pair}){
  $shared_allele_hash{$pair} = 0;
 }
 print "\n$pair\t$count_hash{$pair}\t$shared_allele_hash{$pair}";
}
