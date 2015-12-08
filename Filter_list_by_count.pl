#!/bin/perl
use warnings;
use strict;
#This script takes a list of samples with count data. It then filters a list where the first column is a sample name, based on the count data

my $count = $ARGV[0];

#List is piped in

my $min_count = 1000;
my %data;
open COUNT, $count;
while(<COUNT>){
    chomp;
    my @a = split(/\t/,$_);
    $data{$a[0]} = $a[1];
}

while(<STDIN>){
    chomp;
    my @a = split(/\t/,$_);
    if ($data{$a[0]} > $min_count){
        print "$_\n"
    }
}
