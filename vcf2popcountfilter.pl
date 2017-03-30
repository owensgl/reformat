#!/bin/perl

#This script takes a vcf file and a list of samples with population, and only outputs sites with genotype data in at least 1 per population

#my $n = 1;

my $popfile = $ARGV[0];
open POP, $popfile;

my $indhash;
my $pophash;
while(<POP>){
    chomp;
    my @a = split(/\t/,$_);
    $indhash{$a[0]} = $a[1];
    $pophash{$a[1]}++;
}
close POP;
my @pops = sort keys %pophash;

my %namehash;
my $firstline;
while(<STDIN>){
    chomp;
    if ($_ =~ m/^##/){
        unless($firstline){
            print "$_";
            $firstline++;
        }else{
            print "\n$_";
        }
        next;
    }
    my $line = $_;
    my @a = split(/\t/,$_);
    my $loc = "$a[0]_$a[1]";
    if ($_ =~ m/^#/){
        foreach my $i (10..$#a){
            $namehash{$i} = $a[$i];
        }
        print "\n$line";
        next;
    }
    my %pop_counter;
    foreach my $i (10..$#a){
        my @infos = split(/:/,$a[$i]);
        if ($infos[0] != './.'){
            $pop_counter{$indhash{$namehash{$i}}}++;
        }else{
#		print STDERR "FOUND MISSING DATA FOR $i\n";
	}
    }
    foreach my $pop (@pops){
#	print STDERR "Trying $pop\n";
        unless($pop_counter{$pop}){
#	    print STDERR "At $loc, $pop has ZERO genotyped samples\n";
            goto NEXTLINE;
        }
#	unless($pop_counter{$pop} >= $n){
#	    print STDERR "At $loc, $pop has $pop_counter{$pop} genotyped samples, but it isn't enough\n";
#	    goto NEXTLINE;
#	}
#	print STDERR "At $loc, $pop has $pop_counter{$pop} genotyped samples\n";
    }
    print "\n$line";
    NEXTLINE:
}
