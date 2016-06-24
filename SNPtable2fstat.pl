#!/bin/perl
use warnings;
use strict;
#This takes a SNPtable and a population file and turns it into a FSTAT format
my $popfile = $ARGV[0];
my $TMPFILE = "tmpfile.tab";
open TMPFILE, "> $TMPFILE" 
	or die "Couldn't open `$TMPFILE' for writing: $!; aborting"; 
print TMPFILE while <STDIN>; 

open TMP, "< $TMPFILE";
my %t;
$t{"A"}="1";
$t{"C"}="2";
$t{"G"}="3";
$t{"T"}="4";
$t{"N"}="0";
my %pop;
open POP, $popfile;
while(<POP>){
    chomp;
    my @a = split(/\t/,$_);
    $pop{$a[0]} = $a[1];
}
my $nloci;
my $nsample;
while(<TMP>){
    chomp;
    my @a = split(/\t/,$_);
    if ($. == 1){
        my $tmp_sample = ($#a - 1);
        $nsample = $tmp_sample;
    }else{
        $nloci++;
    }
}
close TMP;
open TMP, "< $TMPFILE";
my %sample;
my $locus_counter =0;
my %data;
while (<TMP>){
    chomp;
    my @a = split(/\t/,$_);
    if($. == 1){
        print "$nsample $nloci 4 1"; #Header line
        foreach my $i (2..$#a){
            $sample{$i} = $a[$i];
        }
    }else{
	$locus_counter++;
        print "\n$a[0]_$a[1]"; #Print locus information;
#	print "\nloc-$locus_counter";
        foreach my $i (2..$#a){
            my @bases = split(//,$a[$i]);
            $bases[0] = $t{$bases[0]};
            $bases[1] = $t{$bases[1]};
            $data{$sample{$i}}{$locus_counter}=$bases[0].$bases[1];
        }
    }
}
foreach my $i (2..($nsample+1)){
    print "\n$pop{$sample{$i}}";
    foreach my $j (1..$locus_counter){
        print "\t$data{$sample{$i}}{$j}";
    }
}
unlink $TMPFILE;
