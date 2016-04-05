#!/bin/perl
use warnings;
use strict;

while (<STDIN>){
    chomp;
    my $line = $_;
    if ($. == 1){
        print "$line";
    }else{
        my $variant;
        my @a = split(/\t/,$line);
        foreach my $i (2..$#a){
            if ($a[$i] eq "NN"){
                next;
            }
            my @bases = split(//,$a[$i]);
            foreach my $n (0..1){
                unless ($variant){
                    $variant = $bases[$n];
                }else{
                    if ($variant ne $bases[$n]){
                        print "\n$line";
                        goto NEXTLINE;
                    }
                }
            }
        }
    }
    NEXTLINE:
}
