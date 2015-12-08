#!/usr/bin/perl
use warnings;
use strict;
#This script takes a .map and .ped file and converts it to a tab separated hmp-esque file.

my $mapfile = $ARGV[0];
my $pedfile = $ARGV[1];

my @chr_list;
my @pos_list;
my @ref_list;
my @alt_list;
open MAP, $mapfile;
while(<MAP>){
    chomp;
    my @a = split(/\s+/,$_);
    my @info = split(/_/,$a[1]);
    my $chr = $info[3];
    my $pos = $a[3];
    my $ref = $info[5];
    my $alt = $info[6];
    push(@chr_list, $chr);
    push(@pos_list, $pos);
    push(@ref_list, $ref);
    push(@alt_list, $alt);
}
close MAP;
open PED, $pedfile;
my %data;
my @name_list;
while(<PED>){
    #There are 6 non-genotype columns before data in the ped file
    chomp;
    my @a = split(/\s+/, $_);
    my $name = $a[1];
    push(@name_list, $name);
    foreach my $i (6..$#a){
        my $j;
        if ($i % 2 == 0){ #If it's an even number, therefore the first of the pair
            $j = ($i/2) - 3;
        }else{ #If its the second in a pair
            $j = (($i-1)/2) - 3;
        }
        my $allele;
        if ($a[$i] eq 1){
            $allele = $ref_list[$j];
        }elsif($a[$i] eq 2){
            $allele = $alt_list[$j];
        }elsif($a[$i] eq 0){
            $allele = "N";
        }else{
            $allele = $a[$i];
        }
        $data{$chr_list[$j]}{$pos_list[$j]}{$name} .= $allele;
    }
}

close PED;
print "chr\tpos";
foreach my $name (@name_list){
    print "\t$name";
}
foreach my $i (0..$#chr_list){
    print "\n$chr_list[$i]\t$pos_list[$i]";
    foreach my $name (@name_list){
        print "\t$data{$chr_list[$i]}{$pos_list[$i]}{$name}";
    }
}
