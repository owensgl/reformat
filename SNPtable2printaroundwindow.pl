#!/bin/perl
use strict;
use warnings;

my $location = $ARGV[0];
my $window = 100000;
my @tmp = split(/:/,$location);
my $loc_chr = $tmp[0];
my $loc_pos = $tmp[1];

while(<STDIN>){
  chomp;
  if ($. == 1){
    print "$_";
  }else{
    my @a = split(/\t/,$_);
    my $chr = $a[0];
    my $pos = $a[1];
    if ($chr eq $loc_chr){
      if (($pos > ($loc_pos - $window)) and ($pos < ($loc_pos + $window))){
        print "\n$_";
      }
    }
  }
  
}
