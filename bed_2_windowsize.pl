#!/bin/perl
use strict;
use warnings;
use POSIX;

my $window_size = 1000000;

my %sizes;
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $start = $a[1];
  my $end = $a[2];
  my $current_window_number = floor($start/$window_size);
  my $current_window_bp = floor($start/$window_size) * $window_size;
  if ($chr =~ m/00/){next;}
  #check if it spans a window
  if (floor($start/$window_size) == floor($end/$window_size)){
    $sizes{$chr}{floor($start/$window_size)}+=($end - $start);
  }else{
    $sizes{$chr}{floor($start/$window_size)}+=((floor($end/$window_size) * $window_size) - $start);
    $sizes{$chr}{(floor($start/$window_size)+1)}+=($end - (floor($end/$window_size) * $window_size));
  }
  
}
print "chr\tstart\tend\tsize_non_te";
foreach my $chr (sort keys %sizes){
  foreach my $window (sort {$a<=>$b} keys %{$sizes{$chr}}){
    my $start = ($window * $window_size) + 1;
    my $end = ($window +1) * $window_size;
    print "\n$chr\t$start\t$end\t$sizes{$chr}{$window}";
  }
}
