#!/bin/perl
use warnings;

my $infofile = $ARGV[0];
my $min_dp = 3;

open INFO, $infofile;

my %group;

while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  $group{$a[0]} = $a[1];
}
print "#$infofile is the info file.";
#AAAAA AAABA AABAA AABBA ABAAA ABABA ABBAA ABBBA BAAAA BAABA
#BABAA BABBA BBAAA BBABA BBBAA BBBBA
my @patterns = qw(AAAA AABA ABAA ABBA BAAA BABA BBAA BBBA);
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
      unless($group{$name{$i}}){next;}
      my @info = split(/:/,$a[$i]);
      my $call;
      if (($info[0] eq '.') or ($info[0] eq './.')){
#print STDERR "\nNo call";
        next;
      }
      my $dp = $info[2];
      my $geno = $info[0];
      if ($dp eq '.'){
#print STDERR "\nDP = .";
	next;
      }
      if ($dp < $min_dp){
#print STDERR "\nDP < min_dp";
	next;
      }
      if ($geno eq '0/0'){
        $call = 0;
      }elsif ($geno eq '0/1'){
        $call = 1;
      }elsif ($geno eq '1/1'){
        $call = 2;
      }
      push( @{$data{$group{$name{$i}}}},  $call);
    }
    my $pattern;
    my %state;
    foreach my $j (1..4){
      unless (exists($data{$j}[0])){
        goto SKIPLINE;
      }
      $state{$j} = $data{$j}[rand @{$data{$j}}];
      if ($state{$j} == 1){
        goto SKIPLINE;
      }
    }
    my $ancestral = $state{4};
    foreach my $j (1..4){
      my $code;
      if ($state{$j} eq $ancestral){
        $code = "A";
      }else{
        $code = "B";
      }
      $pattern .= $code;
    }
    print "\n$chr\t$pos";
    foreach my $possible_pattern (@patterns){
      if ($possible_pattern eq $pattern){
        print "\t1";
      }else{
        print "\t0";
      }
    }
  SKIPLINE:
  }
}
