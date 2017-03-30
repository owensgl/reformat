#This script takes a list of sample identities (P1, P2, <hybrid>, OUT), a list of genetic distances between samples, the name of the hybrid sample, the strand of the hybrid and all the fasta files. 
#It will downsample the parents to equal sample sizes.
#It will select from the parents that are closest to the hybrid.
#It will output the selected parents, along with the hybrid and outgroup and will rename them for phylonet-hmm.
#Note, it uses strand_0 from the outgroup.
#!/bin/perl
use warnings;
use strict;

my $list = $ARGV[0];
my $dist = $ARGV[1]; #distance file produced from fasta2dist.pl
my $hyb = $ARGV[2]; #Name of hybrid
my $strand = $ARGV[3]; #0 or 1

#Grab the sample species ids
my %pop;
my $out;
open LIST, $list;
while(<LIST>){
    chomp;
    my @a = split(/\t/,$_);
    $pop{$a[0]} = $a[1];
    if ($a[1] eq "Out"){
        $out = $a[0];
    }
}
close LIST;
#Grab the distance measures
my %distances;
open DISTFILE, $dist;
while(<DISTFILE>){
    chomp;
    my @a = split(/\|/,$_);
    my @sam1 = split(/ /,$a[0]);
    my $sam1 = $sam1[0].":".$sam1[1];
    my @sam2 = split(/ /,$a[1]);
    my $sam2 = $sam2[0].":".$sam2[1];
    $distances{$sam1}{$sam2} = $a[2];
    $distances{$sam2}{$sam1} = $a[2];
}
close DISTFILE;
#Get number of each parent
my $n_p1 = 0;
my $n_p2 = 0;
foreach my $key (keys %pop){
    if ($pop{$key} eq "P1"){
        $n_p1++;
    }elsif($pop{$key} eq "P2"){
        $n_p2++;
    }
}
my $max_p;
if ($n_p1 >= $n_p2){
    $max_p = $n_p2;
}else{
    $max_p = $n_p1;
}
#Pull random equal numbers of parents using hash [CHECK THAT IT IS RANDOM]
my @p1;
my @p2;
my $current_p1 = 0;
my $current_p2 = 0;
foreach my $key (keys %pop){
    if ($pop{$key} eq "P1"){
        if ($current_p1 < $max_p){
            push(@p1, $key);
            $current_p1++;
        }
    }elsif ($pop{$key} eq "P2"){
        if($current_p2 < $max_p){
            push(@p2, $key);
            $current_p2++;
        }
    }
}
my $hybrid_name = ">".$hyb.":strand_".$strand;
#Find the closest parent strand from the list
my $p1_closest = ">".$p1[0].":strand_0";
my $p2_closest = ">".$p2[0].":strand_0";

foreach my $sample (@p1){
    foreach my $i (0..1){
        if ($distances{$hybrid_name}{">".$sample.":strand_".$i} < $distances{$hybrid_name}{$p1_closest}){
            $p1_closest = ">".$sample.":strand_".$i;
        }
    }    
}
foreach my $sample (@p2){
    foreach my $i (0..1){
        if ($distances{$hybrid_name}{">".$sample.":strand_".$i} < $distances{$hybrid_name}{$p2_closest}){
            $p2_closest = ">".$sample.":strand_".$i;
        }
    }    
}
my $out_name = ">".$out.":strand_0";

#Make list of samples to print;

my $print_next;
foreach my $i (4..$#ARGV){
    my $file = $ARGV[$i];
    open FILE, $file;
    while(<FILE>){
        chomp;
        if (/^>/){
            my @a = split(/ /,$_);
            my $name = $a[0].":".$a[1];
            if ($name eq $out_name){
                print ">OUT\n";
                $print_next++;
            }elsif ($name eq $hybrid_name){
                print ">HYB\n";
                $print_next++;
            }elsif($name eq $p1_closest){
                print ">ANN\n";
                $print_next++;
            }elsif($name eq $p2_closest){
                print ">PET\n";
                $print_next++;
            }
        }else{
            if ($print_next){
                print "$_\n";
                undef($print_next);
            }
        }
    }
}
