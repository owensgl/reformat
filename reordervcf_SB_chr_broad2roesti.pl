#!/bin/perl
use strict;
use warnings;
use Roman;
my $map = "/home/owens/ref/Roesti_Broad_stickleback_genome_comparison.txt"; #Sup mat 4 from Roesti 2013 genetic map paper.

my %chr_hash;
my %pos_hash;
my %direction_hash;
my %cm_hash;
my %unsorted_anchor_sites;
my %anchor_sites;
my %direction;
open MAP, $map;

while(<MAP>){
  chomp;
  my @a = split(/\t/,$_);
  my $old_chr = $a[2];
  my $old_pos = $a[3];
  my $new_chr = $a[4];
  my $new_pos = $a[5];
  my $new_cm = $a[6];
  my $direction = $a[7];
  push ( @{$unsorted_anchor_sites{$old_chr}}, $old_pos);
  $pos_hash{$old_chr}{$old_pos} = $new_pos;
  $chr_hash{$old_chr}{$old_pos} = $new_chr;
  $direction{$old_chr}{$old_pos} = $direction;
  $cm_hash{$old_chr}{$old_pos} = $new_cm;
}

close MAP;

foreach my $i (1..21){
  @{$anchor_sites{$i}} = sort { $a <=> $b } @{$unsorted_anchor_sites{$i}};
}

while(<STDIN>){
  chomp;
  if ($_ =~ m/^##/){
    print "$_\n";
    next;
  }elsif($_ =~ m/^#/){
    print "#CONVERTED FROM BROAD TO ROESTI POSITION. ID IS NOW CM\n";
    print "$_";next;
  }
  my @a = split(/\t/,$_);
  my $tmp = $a[0];
  $tmp =~ s/group//;
  my $chr = &arabic($tmp);
  my $pos = $a[1];
  my $new_pos;
  my $new_chr;
  my $new_cm;
  foreach my $i ( 0 .. ($#{ $anchor_sites{$chr} }-1) ) {
    if (($anchor_sites{$chr}[$i] < $pos) and ($anchor_sites{$chr}[$i+1] > $pos)){
      if ($direction{$chr}{$anchor_sites{$chr}[$i]} eq $direction{$chr}{$anchor_sites{$chr}[$i+1]}){ #no rearrangements between markers
        if ($direction{$chr}{$anchor_sites{$chr}[$i]} =~ /reversed/){
          my $distance_from_anchor = $pos - $anchor_sites{$chr}[$i];
          my $new_anchor = $pos_hash{$chr}{$anchor_sites{$chr}[$i]};
          $new_pos = $pos_hash{$chr}{$anchor_sites{$chr}[$i]} - $distance_from_anchor;
          my $percent_distance = $distance_from_anchor / ($anchor_sites{$chr}[$i+1] - $anchor_sites{$chr}[$i]);
          my $cm_distance = $cm_hash{$chr}{$anchor_sites{$chr}[$i]} - $cm_hash{$chr}{$anchor_sites{$chr}[$i+1]};
          $new_cm = $cm_hash{$chr}{$anchor_sites{$chr}[$i]} - ($cm_distance * $percent_distance);
          $new_chr = $chr_hash{$chr}{$anchor_sites{$chr}[$i]};
          goto PRINTOUT;
        }else{
          my $distance_from_anchor = $pos - $anchor_sites{$chr}[$i];
          my $new_anchor = $pos_hash{$chr}{$anchor_sites{$chr}[$i]};
          $new_pos = $pos_hash{$chr}{$anchor_sites{$chr}[$i]} + $distance_from_anchor;
          $new_chr = $chr_hash{$chr}{$anchor_sites{$chr}[$i]};
          my $percent_distance = $distance_from_anchor / ($anchor_sites{$chr}[$i+1] - $anchor_sites{$chr}[$i]);
          my $cm_distance = $cm_hash{$chr}{$anchor_sites{$chr}[$i+1]} - $cm_hash{$chr}{$anchor_sites{$chr}[$i]};
          $new_cm = $cm_hash{$chr}{$anchor_sites{$chr}[$i]} + ($cm_distance * $percent_distance);
	  $new_chr = $chr_hash{$chr}{$anchor_sites{$chr}[$i]};
          goto PRINTOUT;
        }
      }
    }
    if ($pos_hash{$chr}{$pos}){
      $new_pos = $pos_hash{$chr}{$pos};
      $new_chr = $chr_hash{$chr}{$pos};
      $new_cm = $cm_hash{$chr}{$pos};
      goto PRINTOUT;
    }
  }
  PRINTOUT:
  if ($new_pos){
    print "\n$new_chr\t$new_pos\t$new_cm";
    foreach my $i (3..$#a){
      print "\t$a[$i]";
    }
  }else{
#    print STDERR "\n$chr\t$pos";
  }

}

