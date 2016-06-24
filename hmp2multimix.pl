#!/bin/perl
use warnings;
use Scalar::Util qw(looks_like_number);

my $pop = $ARGV[0];

my %pop;
open POP, $pop;
#This pop file should have only P1, P2 and H. Other pop names are ignored.
while (<POP>){
  chomp;
  my @a = split(/\t/,$_);
  $pop{$a[0]} = $a[1];
}
close POP;

#Make directory structure using bash scripts;
system("mkdir data");
system("mkdir data/haplotypes");
system("mkdir data/Samples");
system("mkdir data/haplotypes/genetic_maps");
system("mkdir data/haplotypes/legend_files");
system("mkdir data/haplotypes/P1");
system("mkdir data/haplotypes/P2");
system("mkdir data/Samples/genos");

my %group;
my $current_chr = "NA";
my $legend_fh = "legend_fh";
my $P1_geno_fh = "p1_fh";
my $P2_geno_fh = "p2_fh";
my $Samples_geno_fh = "samples_fh";
my $first_line;
my @used_sample_list;
#load in a hmp file
while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  if ($. == 1){
    my $count = 1;
    open (KEY, ">", "multimix_hybrids_keyfile.txt"); #This file is to link order to sample name
    foreach my $i (11..$#a){
      if ($pop{$a[$i]}){
        $group{$i} = $pop{$a[$i]};
        if ($group{$i} eq "H"){
          print KEY "$a[$i]\t$count\n";
          $count++;
        }
        push(@used_sample_list, $i);
      }
    }
    close KEY;
  }
  my $chr = $a[2];
  my $pos = $a[3];
  my $both_bases = $a[1];
  my @bases = split(/\//,$both_bases);
  my $rs = $a[0];
  $chr =~ s/Ha//g;
  unless (looks_like_number($chr)){ next;} #Skip the line if it's not a normal numbered chromosome
  if ($current_chr ne $chr){ #It's the start of a new chromosome
    #Close old files
    close $legend_fh;
    close $P1_geno_fh;
    close $P2_geno_fh;
    close $Samples_geno_fh;
    $current_chr = $chr;
    open($legend_fh, '>', "data/haplotypes/legend_files/chr$current_chr.legend") or die "Can't open legend file";
    open($P1_geno_fh, '>', "data/haplotypes/P1/chr$current_chr.genos") or die "Can't open P1_geno file";
    open($P2_geno_fh, '>', "data/haplotypes/P2/chr$current_chr.genos") or die "Can't open P2_geno file";
    open($Samples_geno_fh, '>', "data/Samples/genos/genos_chr$current_chr") or die "Can't open P2_geno file";
    print $legend_fh "rs position a0 a1";
    $first_line++; #This keeps track of whether its the first line printed to each file, for purposes of whether to put a newline
  }

  unless ($first_line){
    print $P1_geno_fh "\n";
    print $P2_geno_fh "\n";
    print $Samples_geno_fh "\n";
  }
  print $legend_fh "\n$rs $pos $bases[0] $bases[1]";
  print $Samples_geno_fh "$rs $pos $bases[0] $bases[1]";
  foreach my $i (@used_sample_list){ #Pull genotypes out of the file.
    if ($group{$i} eq "P1"){
      my @bp = split(//,$a[$i]);
      my $total_alleles = 0;
      if ($bp[0] eq $bases[1]){
        $total_alleles++;
      }
      if ($bp[1] eq $bases[1]){
        $total_alleles++;
      }
      if($bp[1] eq "N"){
        $total_alleles = 9;
      }
      print $P1_geno_fh " $total_alleles";
    }elsif ($group{$i} eq "P2"){
      my @bp = split(//,$a[$i]);
      my $total_alleles = 0;
      if ($bp[0] eq $bases[1]){
        $total_alleles++;
      }
      if ($bp[1] eq $bases[1]){
        $total_alleles++;
      }
      if($bp[1] eq "N"){
        $total_alleles = 9;
      }
      print $P2_geno_fh " $total_alleles";
    }elsif ($group{$i} eq "H"){
      my @bp = split(//,$a[$i]);
      my $total_alleles = 0;
      if ($bp[0] eq $bases[1]){
        $total_alleles++;
      }
      if ($bp[1] eq $bases[1]){
        $total_alleles++;
      }
      if($bp[1] eq "N"){
        $total_alleles = 9;
      }
      if ($total_alleles == 9){
        print $Samples_geno_fh " 9 9 9";
      }elsif ($total_alleles == 0){
        print $Samples_geno_fh " 0 0 1";
      }elsif ($total_alleles == 1){
        print $Samples_geno_fh " 0 1 0";
      }elsif ($total_alleles == 2){
        print $Samples_geno_fh " 1 0 0";
      }
    }
  }

  $first_line = 0;
}

close $legend_fh;
close $P1_geno_fh;
close $P2_geno_fh;
close $Samples_geno_fh;
