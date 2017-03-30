#!/bin/perl
#This script takes a list of sites, the name of window, list of variable sites and a fasta file
#It filters the fasta file for variable sites and keeps track of which ones those are.

my $keyfile = $ARGV[0];
my $window = $ARGV[1];
my $keyout = $ARGV[2];
my $fasta = $ARGV[3];

my $counter = 0;
my %chr_hash;
my %pos_hash;
open KEY, $keyfile;
while(<KEY>){
  chomp;
  my @a = split(/\t/,$_);
  unless($a[2] eq $window){
    next;
  }
  $chr_hash{$counter} = $a[0];
  $pos_hash{$counter} = $a[1];
  $counter++;
}
close KEY;

#Load in fasta
open FASTA, $fasta;
my $sample_n;
my %title;
my %data;
while(<FASTA>){
  chomp;
  if (/^\>/){
    $sample_n++;
    $title{$sample_n} = $_;
  }else{
    my @data = split(//,$_);
    $data{$sample_n} = [ @data ];
  }
}
close FASTA;

#Open keyoutfile
open $keyoutfile,">", $keyout;


#Check which sites are variable
my $len = $#{ $data{1} };
my @good_sites;
foreach my $n (0..($len-1)){
  my %tmp_hash;
  foreach my $i (1..$sample_n){
    $tmp_hash{$data{$i}[$n]}++;
  }
  my $n_alleles = scalar(keys %tmp_hash);
  if ($n_alleles > 1){
    push(@good_sites,$n);
    print $keyoutfile "$chr_hash{$n}\t$pos_hash{$n}\n";
  }
}
close $keyoutfile;
#Print out new filtered fasta
foreach my $i (1..$sample_n){
  print "$title{$i}\n";
  foreach my $site (@good_sites){
    print "$data{$i}[$site]";
  }
  print "\n";
}
