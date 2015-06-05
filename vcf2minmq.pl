#!/bin/perl
use warnings;
use strict;
#This script cuts sites that have a MQ lower than the number specified. If there is no mapping quality, for example in invariant sites, then they are printed anyway.
#USAGE: cat inputfile.vcf | perl vcf2minmq.pl min_MQ > output.vcf
#Example usage for gzipped: zcat catSNPs.vcf.gz | perl /home/bin/vcf2minmq.pl 20 > catSNPs.filtered.vcf


my $minmq = $ARGV[0];

my $goodlines = 0;
my $cutlines = 0;

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
      my @a = split(/\t/,$line);
      my $info = $a[7];
      my @infos = split(/;/,$info);
      foreach my $field (@infos){
          if ($field=~m/^MQ=/){
              $field=~s/MQ=//g;
              if ($field < $minmq){
		print STDERR"Cut $a[0]_$a[1] because MQ=$field\n";
		$cutlines++;
		next;
		}
          }
      }
      $goodlines++;
      print "\n$line";
    }
  }
}

print STDERR "There were $goodlines printed sites and $cutlines cut sites.\n"
