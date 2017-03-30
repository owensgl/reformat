#!/bin/perl
#This script takes a list of sites, the name of window, list of variable sites and a fasta file
#It filters the fasta file for variable sites and keeps track of which ones those are.


#Load in fasta
my $sample_n;
my %title;
my %data;
while(<STDIN>){
  chomp;
  if (/^\>/){
    $sample_n++;
    $title{$sample_n} = $_;
  }else{
    my @data = split(//,$_);
    $data{$sample_n} = [ @data ];
  }
}



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
  }
}
#Print out new filtered fasta
foreach my $i (1..$sample_n){
  print "$title{$i}\n";
  foreach my $site (@good_sites){
    print "$data{$i}[$site]";
  }
  print "\n";
}
