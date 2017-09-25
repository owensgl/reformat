#!/bin/perl
use warnings;
use strict;

#USAGE: cat inputfile.vcf | perl vcf2minhet.pl maximum_heterozygosity > output.vcf
#Example usage for gzipped: zcat catSNPs.vcf.gz | perl /home/bin/vcf2minhet.pl 0.6 > catSNPs.filtered.vcf



my $maxhet = $ARGV[0];

my $goodlines = 0;
my $cutlines = 0;
my $emptylines = 0;
while (<STDIN>){
  chomp;
  my $line = $_;
  if ($. == 1){
    print "$line";
  }
  else{
    if ($line=~m/^#/){
      print "\n$line";
    }
    else{
      my $homo = 0;
      my $het = 0;
      my @a = split(/\t/,$line);
      foreach my $i(9..$#a){
        my $info = $a[$i];
        my @infos = split(/:/,$info);
        if ($infos[0] eq "./."){
          next;
        }
        my @alleles = split(/\//, $infos[0]);
        if ($alleles[0] eq $alleles[1]){
          $homo++;
        }else{
          $het++;
        }
      }
      my $total = $homo + $het;
      if ($total == 0){
        print STDERR "Cut $a[0]_$a[1] because no data\n";
	$emptylines++;
        next;
      }
      my $hetperc = $het / $total;
      if ($hetperc < $maxhet){
        print "\n$line";
        $goodlines++;
      }
      else{
        print STDERR "Cut $a[0]_$a[1] because Het observed = $hetperc\n";
        $cutlines++;
      }
    }
  }
}

print STDERR "$goodlines printed sites.\n";
print STDERR "$cutlines cut due to heterozygosity.\n";
print STDERR "$emptylines cut due to no data.";
