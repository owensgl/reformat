#/usr/perl
use warnings;
use strict;

#This script takes a sam file and converts it to fastq. It works with unpaired data, it does not pass on reads where the read aligns to the reference
my $out = $ARGV[0]; #The outfile prefix. Gets appended with _slim_unpaired.fastq
my $outfile1 = "${out}_slim_unpaired.fastq";
open(my $out1, '>', $outfile1);

my $firstprint_1;

while(<STDIN>){
    chomp;
    my $good;
    if ($_ =~m/^@/){next;}
    my @a = split(/\t/,$_);
    my $header = $a[0];
    my $match = $a[2];
    if ($match eq '*'){
        $good++
    }
    my $seq = $a[9];
    my $qual = $a[10];
    if ($good){
        if($firstprint_1){
            print $out2 qq(\n$header);
            print $out2 qq(\n$seq);
            print $out2 qq(\n+);
            print $out2 qq(\n$qual);
        }else{
            print $out2 qq($header);
            print $out2 qq(\n$seq);
            print $out2 qq(\n+);
            print $out2 qq(\n$qual);
            $firstprint_1++;
        }
    }
}
