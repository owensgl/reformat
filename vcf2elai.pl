#!/usr/bin/perl

use warnings;
use strict;

#This only runs for one chromosome at a time!!!
#This converts all bases to an arbitrary format of alleles, i.e. the reference allele is A, alt1 = T.
my $out = $ARGV[1]; #Prefix for outfile.
my $pop = $ARGV[0]; #Population file for each sample, requires p1, p2 and H groups
my %pop;

my %samples;
my @samplelist;
my %popList;

open (PARFILE1, "> $out.parentfile1.txt") or die "Could not open a file\n";
open (PARFILE2, "> $out.parentfile2.txt") or die "Could not open a file\n";
open (ADMIXFILE, "> $out.admixed.txt") or die "Could not open a file\n";
open (LOCI, "> $out.geneticmap.txt") or die "Could not open a file\n";




if ($pop){
        open POP, $pop;
        while (<POP>){
                chomp;
                my @a = split (/\t/,$_);
                $pop{$a[0]}=$a[1];
                $popList{$a[1]}++;
        }
        close POP;
}

my $loci_count;
my %marker;
my %data;
my %sample;
while (<STDIN>){
    chomp;
    my @a = split(/\t/, $_);
    if ($_ =~ /^##/){next;}
    if ($_ =~ /^#/){
        foreach my $i (9..$#a){
            $sample{$i} = $a[$i];
            push (@samplelist, $a[$i]);
        }
        next;
    }else{
        $loci_count++;
        $marker{$loci_count} = "$a[0]_$a[1]";
        foreach my $i (9..$#a){
            my @fields = split(/:/,$a[$i]);
            my $genotype = $fields[0];
            if ($genotype eq '.' or $genotype eq './.'){
                    $data{$sample{$i}}{$loci_count} = "??";
                    next;}
            my @bases = split(/\//, $genotype);
            foreach my $j (0..1){
                    if ($bases[0] eq "0"){
                        $data{$sample{$i}}{$loci_count} .= "A";
                    }elsif  ($bases[0] eq "1"){
                        $data{$sample{$i}}{$loci_count} .= "T";
                   }elsif ($bases[0] eq "2"){
                        $data{$sample{$i}}{$loci_count} .= "C";
                  }
            }
        }
     }
}

print PARFILE1 "$popList{'p1'}\n$loci_count\nIND";
print PARFILE2 "$popList{'p2'}\n$loci_count\nIND";
print ADMIXFILE "$popList{'H'}\n$loci_count\nIND";
print "$loci_count\n";

foreach my $sample (@samplelist){
        if ($pop{$sample} eq "p1"){
                print PARFILE1 ",\t$sample";
        }elsif ($pop{$sample} eq "p2"){
                print PARFILE2 ",\t$sample";
        }elsif ($pop{$sample} eq "H"){
                print ADMIXFILE ",\t$sample";
        }
}

foreach my $i (1..$loci_count){
        print PARFILE1 "\n$marker{$i}";
        print PARFILE2 "\n$marker{$i}";
        print ADMIXFILE "\n$marker{$i}";
        my @marker_info = split(/_/, $marker{$i});
        print LOCI "$marker{$i}, $marker_info[1], 1\n";
        foreach my $sample (@samplelist){
                if ($pop{$sample} eq "p1"){
                        print PARFILE1 ",\t$data{$sample}{$i}";
                }elsif ($pop{$sample} eq "p2"){
                        print PARFILE2 ",\t$data{$sample}{$i}";
                }elsif ($pop{$sample} eq "H"){
                        print ADMIXFILE ",\t$data{$sample}{$i}";
                }
        }
}

close PARFILE1;
close PARFILE2;
close ADMIXFILE;
close LOCI;
