#!/bin/perl
use warnings;

my $infofile = $ARGV[0];
my $suffix = $ARGV[1];
my $min_dp = 3;
my $n_perm = 200;

open INFO, $infofile;

my %group;

while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  $group{$a[0]} = $a[1];
}
#AAAAA AAABA AABAA AABBA ABAAA ABABA ABBAA ABBBA BAAAA BAABA
#BABAA BABBA BBAAA BBABA BBBAA BBBBA
my @patterns = qw(AAAAA AAABA AABAA AABBA ABAAA ABABA ABBAA ABBBA BAAAA BAABA BABAA BABBA BBAAA BBABA BBBAA BBBBA);
my %perm_sample;
my @filehandles;
#Create permutations;
foreach my $i (1..$n_perm){
  foreach my $j (1..5){
    my $rand_sample = (keys %group)[rand keys %group];
    until ($group{$rand_sample} eq $j){
      $rand_sample = (keys %group)[rand keys %group];
    }
    $perm_sample{$i}{$j} = $rand_sample;
  }
  my $filename = ">$suffix.$i.txt";
  local *FILE;
  open(FILE, $filename) || die;
  push(@filehandles, *FILE);
  print FILE "#1\t$perm_sample{$i}{1}";
  foreach my $j (2..5){
    print FILE "\n#$j\t$perm_sample{$i}{$j}";
  }

}
close INFO;
my %name;
my $counter =0;
while(<STDIN>){
  chomp;
  my $line = $_;
  if ($line=~m/^##/){next;}
  if ($line=~m/^#/){
    my @a = split(/\t/,$line);
    foreach my $i (9..$#a){
      $name{$i} = $a[$i];
    }
  }else{
    my @a = split(/\t/,$line);
    my $chr = $a[0];
    my $pos = $a[1];
    my $ref = $a[3];
    my $alt = $a[4];
    if((length($alt) > 1) or (length($ref) > 1)){
      next;
    }
    $counter++;
    if ($counter % 100000 == 0){
      print STDERR "Processing $chr\t$pos\n";
    }
    my %data;
    foreach my $i (9..$#a){
      my @info = split(/:/,$a[$i]);
      my $call;
      if (($info[0] eq '.') or ($info[0] eq './.')){
        $call = "NA";
	$data{$name{$i}} = $call;
        next;
      }
      my $dp = $info[2];
      my $geno = $info[0];
      if ($dp < $min_dp){
	$data{$name{$i}} = "NA";
	next;
      }
      if ($geno eq '0/0'){
        $call = 0;
      }elsif ($geno eq '0/1'){
        $call = 1;
      }elsif ($geno eq '1/1'){
        $call = 2;
      }
      $data{$name{$i}} = $call;
    }
    foreach my $i (1..$n_perm){
      my $perm_file = $filehandles[$i-1];
      my $pattern;
      foreach my $j (1..5){
	unless(exists($data{$perm_sample{$i}{$j}})){ print "\n$i\t$j\t$perm_sample{$i}{$j}";}
	
        if ($data{$perm_sample{$i}{$j}} eq "NA"){
          #skip missing data
          goto NEXTPERM;
        }
        if ($data{$perm_sample{$i}{$j}} eq "1"){
          #Skip heterozygotes;
          goto NEXTPERM;
        }
	my $ancestral = $data{$perm_sample{$i}{5}};
        my $state;
        if ($data{$perm_sample{$i}{$j}} eq $ancestral){
          $state = "A";
        }else{
          $state = "B";
        }
        $pattern .= $state;
      }
      print $perm_file "\n$chr\t$pos";
      foreach my $possible_pattern (@patterns){
        if ($possible_pattern eq $pattern){
          print $perm_file "\t1";
        }else{
          print $perm_file "\t0";
        }
      }
      NEXTPERM:
    }
  }
}
