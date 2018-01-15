#!/bin/perl
use strict;
use warnings;

my $line_number;
my $current_sample;
my @samples;
my %data;
my $n_markers;
my $header = 1;
my @contigs;
my $current_contig;
my %contig_markers;
my %geno;

my %t;
$t{"0"} = "A";
$t{"1"} = "C"; 
while(<STDIN>){
  chomp;
  if ($_ =~ m/BEGIN GENOTYPES/){
    $line_number = 1;
    $header = 0;
    $current_contig++;
    push(@contigs, $current_contig);
    next;
  }elsif ($_ =~ m/END GENOTYPES/){
    $header = 1;
    next;
  }
  if ($header){next;}
  if ($line_number){
    if ($line_number == 1){
      my $sample = $_;
      $sample =~ s/# //g;
      push(@samples,$sample) unless grep{$_ eq $sample} @samples;
      $current_sample = $sample;
      $line_number++;
      next;
    }elsif($line_number == 2){
      my @a = split(/ /,$_);
      $contig_markers{$current_contig} = $#a;
      foreach my $i (0..$#a){
        $data{$current_sample}{$current_contig}{$i}{1}= $t{$a[$i]};
      }
      $line_number++;
      next;
    }elsif($line_number == 3){
      my @a = split(/ /,$_);
      foreach my $i (0..$#a){
        $data{$current_sample}{$current_contig}{$i}{2}= $t{$a[$i]};
      }
      foreach my $i (0..$#a){
        $geno{$current_sample} .= " $data{$current_sample}{$current_contig}{$i}{1} $data{$current_sample}{$current_contig}{$i}{2}";
      }
      undef(%data);
      $line_number = 1;
      next;
    }
  }
}
my $first_line;
foreach my $sample (@samples){
  if($first_line){
    print "\n";
  }else{
    $first_line++;
  }
  print "$sample $sample 0 0 0 0";
  print "$geno{$sample}";
}
