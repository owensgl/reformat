#!/bin/perl

use warnings;
use strict;

my %t;
$t{"Ha1"} = "1";
$t{"Ha2"} = "2";
$t{"Ha3"} = "3";
$t{"Ha4"} = "4";
$t{"Ha5"} = "5";
$t{"Ha6"} = "6";
$t{"Ha7"} = "7";
$t{"Ha8"} = "8";
$t{"Ha9"} = "9";
$t{"Ha10"} = "10";
$t{"Ha11"} = "11";
$t{"Ha12"} = "12";
$t{"Ha13"} = "13";
$t{"Ha14"} = "14";
$t{"Ha15"} = "15";
$t{"Ha16"} = "16";
$t{"Ha17"} = "17";
$t{"Ha0_73Ns"} = "18";

while(<STDIN>){
    chomp;
    if ($. == 1){
        print "$_";
    }else{
        my @a = split(/\t/,$_);
        my $chr = $t{$a[0]};
        print "\n$chr";
        foreach my $i (1..$#a){
            print "\t$a[$i]";
        }
    }
}
