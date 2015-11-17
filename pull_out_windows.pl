#!/bin/perl
use warnings;
use strict;

my $windows = $ARGV[0];

my @start_array;
my @end_array;
my @chr_array;
open WINDOWS, $windows;
while(<WINDOWS>){
    chomp;
    my @a = split(/\t/,$_);
    my $chr = $a[0];
    my $start = $a[1];
    my $end = $a[2];
    push(@chr_array, $chr);
    push(@start_array,$start);
    push(@end_array,$end);
}

while(<STDIN>){
    chomp;
    my $line = $_;
    my @a = split(/\t/,$_);
    if ($. == 1){print "$_";next;}
    my $chr = $a[0];
    my $pos = $a[1];
    foreach my $i(0..$#start_array){
        if ($chr_array[$i] eq $chr){
            if (($start_array[$i] <= $pos) and ($end_array[$i] >= $pos)){
                print "\n$_";
            }
        }
    }
}
