#!/bin/perl
#This takes a list of ancestral sites and then a phased VCF and outputs a relate .haps file. It uses an unhpased vcf to get XRQ positions.
#zcat Annuus.tranche90.snp.env.90.bi.remappedHa412HO.beagle.vcf.gz | perl /home/owens/bin/reformat/pvcf2relate.pl /home/owens/ref/perennial_alleles.20190515.txt.gz Annuus.tranche90.snp.env.90.bi.remappedHa412HO.vcf.gz Annuus.tranche90.snp.env.90.bi.remappedHa412HO.beagle
use strict;
use warnings;

my $ancestral_file = $ARGV[0]; #perennial_alleles.20190515.txt.gz
my $vcf_unphased = $ARGV[1]; #Unphased vcf to get XRQ info
my $prefix = $ARGV[2]; #Prefix for multiple output files
my $chr_string = "Ha412HOChr";
open(ANC, "zcat $ancestral_file |") or die "gunzip $ancestral_file: $!";
open(VCF, "zcat $vcf_unphased |") or die "gunzip $vcf_unphased: $!";
my %anc;
while(<ANC>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $base = $a[2];
  $anc{$chr}{$pos} = $base;
}
close ANC;
my %site_hash;
my $counter;
my %chr_list;
#Pipe in a phased VCF
while(<VCF>){
  chomp;
  if ($. == 1){
    #print "$_";
    next;
  }
  if ($_ =~ m/^#/){
    #print "\n$_";
    next;
  }
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $chr_n = $chr;
  $chr_n =~ s/$chr_string//;
  $chr_list{$chr_n}++;
  my $pos = $a[1];
  my $ref = $a[3];
  my $alt = $a[4];
  $counter++;
  if ($counter % 100000 == 0){print STDERR "Processing $chr $pos...\n";}
  my @infos = split(/;/,$a[7]);
  my $xrq_full = $infos[$#infos];
  $xrq_full =~ s/XRQ=//;
  my @xrq_fields = split(/\./,$xrq_full);
  my $xrq_chr = $xrq_fields[0];
  my $xrq_pos = $xrq_fields[1];
  unless ($anc{$xrq_chr}{$xrq_pos}){
    $site_hash{$chr}{$pos} = "missing";
    next;
  }
  if ($anc{$xrq_chr}{$xrq_pos} eq $ref){
    $site_hash{$chr}{$pos} = "reg";
  }elsif ($anc{$xrq_chr}{$xrq_pos} eq $alt){
    $site_hash{$chr}{$pos} = "flip";
  }else {
    $site_hash{$chr}{$pos} = "missing";
  }
}
close VCF;
my %file_handle;
foreach my $chr (sort keys %chr_list){
  open ($file_handle{$chr}, '>', "$prefix.$chr.hap");
}
my $sites_cut;

my $sample_out;
open ($sample_out, '>', "$prefix.sample");

my %first_line;
my $sites_retained;
while(<STDIN>){
  chomp;
  if ($. == 1){
    #print "$_";
    next;
  }
  if ($_ =~ m/^##/){
    #print "\n$_";
    next;
  }
  if ($_ =~ m/^#/){
    print $sample_out "ID_1 ID_2 missing";
    my @a = split(/\t/,$_);
    foreach my $i (9..$#a){
      print $sample_out "\n$a[$i] $a[$i] 0";
    }
    close $sample_out;
    next;
  }
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $chr_n = $chr;
  $chr_n =~ s/$chr_string//;
  my $pos = $a[1];
  my $ref = $a[3];
  my $alt = $a[4];
  if ($site_hash{$chr}{$pos} eq "missing"){
    $sites_cut++;
    next;
  }
  $sites_retained++;
  if ($site_hash{$chr}{$pos} eq "reg"){
    if($first_line{$chr_n}){
      print {$file_handle{$chr_n}} "\n";
    }else{
      $first_line{$chr_n}++;
    }
    print {$file_handle{$chr_n}} "$chr_n ${chr}_$pos $pos $ref $alt";
    foreach my $i (9..$#a){
      my @genotypes = split(/\|/,$a[$i]);
      print {$file_handle{$chr_n}} " $genotypes[0] $genotypes[1]";
    }
  }elsif ($site_hash{$chr}{$pos} eq "flipped"){
    if($first_line{$chr_n}){
      print {$file_handle{$chr_n}} "\n";
    }else{
      $first_line{$chr_n}++;
    }
    print {$file_handle{$chr_n}} "$chr_n ${chr}_$pos $pos $alt $ref";
    foreach my $i (9..$#a){
      my @genotypes = split(/\|/,$a[$i]);
      my %flipped_genos;
      foreach my $x (0..1){
        if ($genotypes[$x] == 0){
          $flipped_genos{$x} = 1;
        }else{
          $flipped_genos{$x} = 0;
        }
      }
      print  {$file_handle{$chr_n}} " $flipped_genos{0} $flipped_genos{0}";
    }
  }
}

print STDERR "Sites retained = $sites_retained\nSites cut = $sites_cut\n";
