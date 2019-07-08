#!/usr/bin/perl
#Pulls out fasta sequences that match your IDs

use strict;
use warnings;

my $ids = $ARGV[0];
my $fasta = $ARGV[1];

open ID, $ids;

my %genes;
while(<ID>){
  chomp;
  $genes{$_}++;
}
close ID;

open FASTA, $fasta;
my $print_code = 1;
while(<FASTA>){
  chomp;
  if ($_ =~ m/^>/g){
    my $gene = $_;
    $gene =~ s/>//g;
    if ($genes{$gene}){
      $print_code = 1;
    }else{
      $print_code = 0;
    }
  }
  if ($print_code){
    print "$_\n";
  }
}
