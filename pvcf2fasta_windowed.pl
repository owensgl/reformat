#!/bin/perl
#This script takes a vcf file phased by beagle, and outputs a vcf, by windows
use strict;
use warnings;

my $tag = $ARGV[0]; #Thing to stick on fasta names
my $key_file = $ARGV[1]; #File with a list of which sites are in which windows.
open (my $keyout, '>', $key_file);
my $window_size = 300000000;
my $window_start;
my $window_end;
my $current_chr = "NA";

my %ind;
my %sites;
my $window;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^##/){next;}
  my @a = split(/\t/,$_);
  if ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      $ind{$i} = $a[$i];
    }
  }else{
    my $chr = $a[0];
    my $pos = $a[1];
    my $ref = $a[3];
    my $alt = $a[4];
    if ($chr =~ m/^HanXRQChr00/){
	next;
    }elsif($chr =~ m/^HanXRQMT/){
	next;
    }elsif($chr =~ m/^HanXRQCP/){
	next;
    }
    if ($current_chr ne $chr){
      if (keys %sites){
        &print_fasta;
	undef(%sites);
      }
      $current_chr = $chr;
      $window_start = 0;
      $window_end = $window_start + $window_size;
      $window = "$current_chr\.$window_start\-$window_end";
    }
    print $keyout "$chr\t$pos\t$window\n";
    if ($pos > $window_end){
      if (keys %sites){
        &print_fasta;
	undef(%sites)
      }
      until($pos <= $window_end){
        $window_start += $window_size;
        $window_end += $window_size;
        $window = "$current_chr\.$window_start\-$window_end";
      }
    }
    
    foreach my $i(9..$#a){
      my @tmp = split(/:/,$a[$i]);
      my $call = $tmp[0];
      my @bases = split(/\|/,$call);
      foreach my $j (0..1){
        if ($bases[$j] == 0){
          $sites{$ind{$i}}{$j} .= $ref;
        }else{
          $sites{$ind{$i}}{$j} .= $alt;
        }
      }
    }
  }
}
if (keys %sites){
	&print_fasta;
        undef(%sites);
}
sub print_fasta {
  my $file = $tag.".".$window."."."fasta";
  open my $output,">$file" or die "Can't open the output file!";
  my @a = sort values %ind;
  foreach my $i (0..$#a){
    foreach my $j (0..1){
      print $output ">$a[$i] strand_$j $window\n";
      print $output "$sites{$a[$i]}{$j}\n";
    }
  }
  close $output;
}
