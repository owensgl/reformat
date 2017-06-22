#!/bin/perl
use strict;
use warnings;

my $window_size = $ARGV[0];

my $current_chr = "NA";
my $current_start = 0;
my $current_end = $current_start+$window_size;
my $header;
my $outfh = "NA";
while(<STDIN>){
  chomp;
  if ($. == 1){
    $header = $_;
  }else{
    my @a = split(/\t/,$_);
    my $chr = $a[0];
    if ($chr =~ m/scaffold/){next;}
    my $pos = $a[1];
    if ($current_chr ne $chr){
      close FH;
      $current_chr = $chr;
      $current_start = 0;
      $current_end = $current_start+$window_size;
      until ($pos <= $current_end){
        $current_start += $window_size;
        $current_end += $window_size;
      }
      my $filename = "$current_chr.$current_start.$current_end.tab";
      open (FH, '>', $filename);
      print FH "$header";
    }
    if ($pos > $current_end){
#print STDERR "End of window $current_end with pos $pos with window size $window_size\n";
      close FH;
      until ($pos <= $current_end){
        $current_start += $window_size;
        $current_end += $window_size;
      }
      my $filename = "$current_chr.$current_start.$current_end.tab";
      open (FH, '>', $filename);
      print FH "$header"
    }
    print FH "\n$_";
  }
}
  
