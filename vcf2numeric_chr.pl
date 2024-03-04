#!/bin/perl
use strict;
use warnings;

my $key_file = $ARGV[0];

my %chr_hash;
my $current_chr_n = 1;
while(<STDIN>){
  chomp;
  my $line = $_;
  if ($. == 1){
    print "$line";
    next;
  }
  if ($line =~ m/^##contig/){
    if ($line =~ /ID=(\w+\.\d+)/) {
      my $contig_id = $1;
      $chr_hash{$contig_id} = $current_chr_n;
      $line =~ s/ID=\Q$contig_id\E/ID=$current_chr_n/;
      $current_chr_n++;
      print "\n$line";
    }
  }else{
    my @a = split(/\t/,$line);
    if ($chr_hash{$a[0]}){
      $line =~ s/$a[0]/$chr_hash{$a[0]}/;
    }
    print "\n$line";
  }
}
open (KEY, ">$key_file");
my @sorted_keys = sort { $chr_hash{$a} <=> $chr_hash{$b} } keys %chr_hash;
foreach my $key ( @sorted_keys ) {
   print KEY "$key\t$chr_hash{$key}\n";
}
close KEY
