#/usr/perl
use warnings;
use strict;

#This script takes a sam file and converts it to fastq. It does not pass on reads where both reads align to the reference (i.e., the repetitive elements)
my $out = $ARGV[0]; #The outfile prefix. Gets appended with _slim_R1.fastq and _slim_R2.fastq
my $outfile1 = "${out}_slim_R1.fastq";
my $outfile2 = "${out}_slim_R2.fastq";
open(my $out1, '>', $outfile1);
open(my $out2, '>', $outfile2);
my $pair = 0;
my $good;
my %prev;
my $firstprint_1;
my $firstprint_2;
while(<STDIN>){
    chomp;
    if ($_ =~m/^@/){next;}
    my @a = split(/\t/,$_);
    my $header = "@".$a[0];
    my $match = $a[2];
    if ($match eq '*'){
        $good++
    }
    my $seq = $a[9];
    my $qual = $a[10];
    $pair++;
    if ($pair == 1){ #if it's the first read of a pair
        $prev{"header"} = $header;
        $prev{"seq"} = $seq;
        $prev{"qual"} = $qual;
    }elsif ($pair == 2){
        if ($good){
            if ($firstprint_1){
                print $out1 qq(\n$prev{"header"});
                print $out1 qq(\n$prev{"seq"});
                print $out1 qq(\n+);
                print $out1 qq(\n$prev{"qual"});
            }else{
                print $out1 qq($prev{"header"});
                print $out1 qq(\n$prev{"seq"});
                print $out1 qq(\n+);
                print $out1 qq(\n$prev{"qual"});
                $firstprint_1++;
            }
            if($firstprint_2){
                print $out2 qq(\n$header);
                print $out2 qq(\n$seq);
                print $out2 qq(\n+);
                print $out2 qq(\n$qual);
            }else{
                print $out2 qq($header);
                print $out2 qq(\n$seq);
                print $out2 qq(\n+);
                print $out2 qq(\n$qual);
                $firstprint_2++;
            }
        }
        #Reset information for next pair
        undef($good);
        undef($pair);
        undef(%prev);
    }
}
