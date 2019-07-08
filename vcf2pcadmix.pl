#!/bin/perl

use warnings;
use strict;
#This script takes a beagle phased vcf and outputs the files for PCadmix. It outputs a SNP file for each population (2 per sample), a map file with SNP locations and a genetic map file containing cM position and rate.  
#USAGE: cat file.vcf | perl THISSCRIPT.pl map.txt sampleinfo.txt fileprefix 
my $map = $ARGV[0]; #In this, the chr is first col, bp is second, cm is third.
#/home/owens/ref/HanXRQr1.0-20151230.bp_to_cM.280x801.extradivisions.txt

my $sample_info = $ARGV[1]; #Sample_ID\tSample_pop
my $prefix; #Prefix for output files;
unless($ARGV[2]){
  $prefix = "TMP";
}else{
  $prefix = $ARGV[2]; 
}


#SNPfile piped in
my $tmp;
my %hash;
my %chrom;
open MAP, $map;
while(<MAP>){
  chomp;
  my @a = split(/\t/,$_);
  if ($. ne "1"){
    if ($a[2] ne "NA"){
      my $chrom = $a[0];
      $chrom =~ s/"//g;
      $hash{$chrom}{$a[1]} = $a[2];
      my $chr_n = $chrom;
      $chr_n =~ s/HanXRQChr//g;
      $chrom{$chr_n}++;
    }
  }
}
close MAP;
my %pop;
my %pop_list;
open INFO, $sample_info;
while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  $pop{$a[0]} = $a[1];
  $pop_list{$a[1]}++;
}
close INFO;

#Open files for writing SNPs to
my %file_handle;
foreach my $pop (sort keys %pop_list){
  foreach my $chrom (sort keys %chrom){
    open ($file_handle{$pop}{$chrom}, '>', "$prefix.$pop.$chrom.haplotypes.txt") or die;
  }
  
}
my %physical_map;
my %genetic_map;
#Open the physical map file;
foreach my $chrom (sort keys %chrom){
  open ($physical_map{$chrom}, '>', "$prefix.$chrom.physmap.txt") or die;
}
#Open the genetic map file;
foreach my $chrom (sort keys %chrom){
  open  ($genetic_map{$chrom}, '>', "$prefix.$chrom.genmap.txt") or die;
  print {$genetic_map{$chrom}} "position\tCOMBINED_rate(cm/Mb)\tGenetic_Map(cM)";
}

my %sample;
my %first_physicalmap_line;
while(<STDIN>){
  chomp;
  my $line = $_;
  my @a = split(/\t/,$line);
  if ($_ =~ m/^##/){next;
  }elsif ($_ =~ m/^#/){
    foreach my $i (9..$#a){
      $sample{$i} = $a[$i];
    }
    #print out the header for the haplotype files;
    foreach my $pop (sort keys %pop_list){
      foreach my $chrom (sort keys %chrom){
        print {$file_handle{$pop}{$chrom}} "I\trsID";
        foreach my $i (sort keys %sample){
          if ($pop{$sample{$i}} eq $pop){
            print {$file_handle{$pop}{$chrom}} "\t$sample{$i}.1\t$sample{$i}.2";
          }
        }
      }

    }
    next;
  }
  my $chrom = $a[0];
  if (($chrom =~ m/00/) or ($chrom =~ m/CP/) or ($chrom =~ m/MT/)){
    next;
  }
  my $bp = $a[1];
  my $ref = $a[3];
  my $alt = $a[4];
  my @alleles = ( $ref, $alt );
  my $chr_n = $chrom;
  $chr_n =~ s/HanXRQChr//g;
  my $name = "$chrom.$bp";
  my $previous_site;
  my $before_site;
  my $after_site;
  my $loci_cM;
  foreach my $site (sort  {$a <=> $b} keys %{$hash{$chrom}}){
    if ($site > $bp){
      if ($previous_site){
        $before_site = $previous_site;
        $after_site = $site;
        goto FOUNDPOS;
      }else{
        $loci_cM = "NA";
        goto BADSITE;
      }
    }
    $previous_site = $site;
  }
  $loci_cM = "NA";
  goto BADSITE;
  FOUNDPOS:
  my $cM_range = $hash{$chrom}{$after_site} - $hash{$chrom}{$before_site};
  my $bp_range = $after_site - $before_site;
  my $cM_rate = ($cM_range / $bp_range) * 1000000;
  my $percent_of_range = ($bp - $before_site)/$bp_range;
  $loci_cM = ($percent_of_range * $cM_range) + $hash{$chrom}{$before_site};

  #Print the physical map positions
  if ($first_physicalmap_line{$chr_n}){
    print {$physical_map{$chr_n}} "\n$chr_n\t$name\t0\t$bp";
  }else{
    print {$physical_map{$chr_n}} "$chr_n\t$name\t0\t$bp";
    $first_physicalmap_line{$chr_n}++;
  }

  #Print the genetic map positions;
  print {$genetic_map{$chr_n}} "\n$bp\t$cM_rate\t$loci_cM";
  
  #Print the row starter for each population;
  foreach my $pop (sort keys %pop_list){
    print {$file_handle{$pop}{$chr_n}} "\nM\t$name";
  }
  #Grab the haplotypes and output to population haplotype files
  foreach my $i (9..$#a){
    if ($pop{$sample{$i}}){
      my @genotypes = split(/\|/,$a[$i]);
      print {$file_handle{$pop{$sample{$i}}}{$chr_n}} "\t$alleles[$genotypes[0]]\t$alleles[$genotypes[1]]";
    }
  }
}
