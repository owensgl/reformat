#!/bin/perl
use warnings;

#This script takes a bronze.windowtocm.1mb.txt file and converts it to the genetic map file for multimix

my $current_chr = "NA";
my $current_file = "NA";
my $fh = "FILEHANDLE";
while(<STDIN>){
  chomp;
  if ($. == 1){
    next;
  }
  my @a = split(/\t/,$_);
  my $chrom = $a[0];
  my $start = $a[1];
  my $end = $a[2];
  my $cm_start = $a[3];
  my $cm_end = $a[4];
  my $cm_size = $a[5];
  if ($chrom ne $current_chr){
    close $fh; #Close old file
    $current_chr = $chrom; 
    $chrom =~ s/Ha//g;
    $current_file = "chr$chrom.map"; 
    open($fh, '>', $current_file); #open new file
    #print the openning window of the new chrom;
    print $fh "position COMBINED_rate(cM/Mb) Genetic_Map(cM)";
    print $fh "\n$start -1 0";
  }
  print $fh "\n$end $cm_size $cm_end";
}
close $fh;
