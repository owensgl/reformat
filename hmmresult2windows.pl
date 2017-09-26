#!/bin/perl
use warnings;
use strict;

my $sample = $ARGV[0];
my $current_chr = "NA";
my $previous_pos;
my $previous_state;
my $min_prob = $ARGV[1]; #minimum probability to pick state

print "sample\tchr\tstart\tend\tstate";
while(<STDIN>){
  chomp;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $p1 = $a[2];
  my $het = $a[3];
  my $p2 = $a[4];
  my $current_state = "Unknown";
  if ($p1 >= $min_prob){
    $current_state = "P1";
  }elsif ($p2 >= $min_prob){
    $current_state = "P2";
  }elsif ($het >= $min_prob){
    $current_state = "Het";
  }
  if ($chr ne $current_chr){
    #Print end of previous chr
    if ($previous_state){
      print "\t$previous_pos\t$previous_state";
    }
    $current_chr = $chr;
    undef($previous_pos);
    undef($previous_state);
    #Start new window;
    $previous_pos = $pos;
    $previous_state = $current_state;
    print "\n$sample\t$chr\t$pos";
  }else{
    if ($previous_state eq $current_state){
      $previous_pos = $pos;
    }else{
      my $midway_point = int($previous_pos + (($pos - $previous_pos)/2));
      my $midway_point_plus = $midway_point+1;
      print "\t$midway_point\t$previous_state";
      print "\n$sample\t$chr\t$midway_point_plus";
      $previous_state = $current_state;
      $previous_pos = $pos;
    }
  }
}

#PRINT LAST WINDOW
print "\t$previous_pos\t$previous_state";
