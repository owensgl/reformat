#!/bin/perl
#This script takes a vcf file from Freebayes and applies a depth filter to the genotypes. It then filters for number of samples with genotypes (above the cut off)
my $min_dp = 5;
my $min_genotypes = 2;

while(<STDIN>){
    chomp;
    my $genotype_count = 0;
    my $line = $_;
    if ($line=~m/^#/){
        print "$line\n";
    }else{
        my @fields = split(/\t/,$line);
        foreach my $i (9..$#fields){
            if ($fields[$i] eq "."){
                next;
            }else{
                my @info = split(/:/,$fields[$i]);
                my $depth = $info[1];
                if ($depth >= $min_dp){
                    $genotype_count++;
                }
            }
        }
        if ($genotype_count >= $min_genotypes){
            print "$line\n";
        }
    }
}
