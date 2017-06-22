#!/bin/perl
use strict;
use warnings;

my $location = $ARGV[0];
my @tmp = split(/:/,$location);
my $loc_chr = $tmp[0];
my $loc_pos_start = $tmp[1];
my $loc_pos_end = $tmp[2];
$loc_chr =~ s/chr/group/g;
while(<STDIN>){
  chomp;
  if ($. == 1){
    print "$_";
  }else{
    my @a = split(/\t/,$_);
    my $chr = $a[0];
    my $pos = $a[1];
    if ($chr eq $loc_chr){
      if (($pos >= ($loc_pos_start)) and ($pos <= $loc_pos_end)){
        print "\n$_";
      }
    }
  }
  
}
