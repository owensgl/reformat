#!/bin/perl
use warnings;
use strict;

#This script will parse through a vcf file and print out site quality information. It keeps sites that were preloaded as "good" snps, and otherwise grabs 0.1% of sites randomly
#It only keeps biallleic sites
my $good_file = "/media/owens/Copper/WGS_annuus/public_annuus_snps_sort.snpset";

open FILE, $good_file;

my %refset;
my %altset;
while(<FILE>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $ref = $a[2];
  my $alt = $a[3];
  $altset{$chr}{$pos} = $alt;
}
close FILE;
print "chr\tpos\tmatch\tAB\tAF\tDPRA\tEPP\tEPPR\tMEANALT\tMQM";
print "\tMQMR\tODDS\tPAIRED\tPAIREDR\tPAO\tPQA\tPQR\tPRO\t";
print "RPL\tRPR\tRPP\tRPPR\tSAF\tSRF\tSAP\tSRP";


while(<STDIN>){
  chomp;
  next if(/^#/);
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $alt = $a[4];
  if (length($alt) > 1){next;}
  my $keep;
  my $match = 0;
  if ($altset{$chr}{$pos}){
    $keep++;
    $match++;
    if ($altset{$chr}{$pos} eq $alt){
      $match++;
    }
  }
  my $rand = rand(1000);
  if ($rand <= 1){$keep++;}
  unless($keep){next;}
  #QUAL
  #AB,AF,DP,DPRA,EPP, EPPR, MEANALT, MQM, MQMR, ODDS, PAIRED, PAIREDR, PAO, PQA,
  #PQR,PRO, RPL, RPR, RPP, RPPR, SAF, SRF, SAP, SRP
  my $qual = $a[5];
  my $info = $a[7];
  my $AB = "NA";
  my $AF = "NA";
  my $DP = "NA";
  my $DPRA = "NA";
  my $EPP = "NA";
  my $EPPR = "NA";
  my $MEANALT = "NA";
  my $MQM = "NA";
  my $MQMR = "NA";
  my $ODDS = "NA";
  my $PAIRED = "NA";
  my $PAIREDR = "NA";
  my $PAO = "NA";
  my $PQA = "NA";
  my $PQR = "NA";
  my $PRO = "NA";
  my $RPL = "NA";
  my $RPR = "NA";
  my $RPP = "NA";
  my $RPPR = "NA";
  my $SAF = "NA";
  my $SRF = "NA";
  my $SAP = "NA";
  my $SRP = "NA";
  if($info=~m/AB=(\d*\.?\d*)/){
                $AB = "$1";
    }
  if($info=~m/AF=(\d*\.?\d*)/){
        $AF = "$1";
  }
  if($info=~m/DP=(\d*\.?\d*)/){
        $DP = "$1";
  }
  if($info=~m/DPRA=(\d*\.?\d*)/){
        $DPRA = "$1";
  }
  if($info=~m/EPP=(\d*\.?\d*)/){
        $EPP = "$1";
  }
  if($info=~m/EPPR=(\d*\.?\d*)/){
        $EPPR = "$1";
  }
  if($info=~m/MEANALT=(\d*\.?\d*)/){
        $MEANALT = "$1";
  }
  if($info=~m/MQM=(\d*\.?\d*)/){
        $MQM = "$1";
  }
  if($info=~m/MQMR=(\d*\.?\d*)/){
        $MQMR = "$1";
  }
  if($info=~m/ODDS=(\d*\.?\d*)/){
        $ODDS = "$1";
  }
  if($info=~m/PAIRED=(\d*\.?\d*)/){
        $PAIRED = "$1";
  }
  if($info=~m/PAIREDR=(\d*\.?\d*)/){
        $PAIREDR = "$1";
  }
  if($info=~m/PAO=(\d*\.?\d*)/){
        $PAO = "$1";
  }
  if($info=~m/PQA=(\d*\.?\d*)/){
        $PQA = "$1";
  }
  if($info=~m/PQR=(\d*\.?\d*)/){
        $PQR = "$1";
  }
  if($info=~m/PRO=(\d*\.?\d*)/){
        $PRO = "$1";
  }
  if($info=~m/RPL=(\d*\.?\d*)/){
        $RPL = "$1";
  }
  if($info=~m/RPR=(\d*\.?\d*)/){
        $RPR = "$1";
  }
  if($info=~m/RPP=(\d*\.?\d*)/){
        $RPP = "$1";
  }
  if($info=~m/RPPR=(\d*\.?\d*)/){
        $RPPR = "$1";
  }
  if($info=~m/SAF=(\d*\.?\d*)/){
        $SAF = "$1";
  }
  if($info=~m/SRF=(\d*\.?\d*)/){
        $SRF = "$1";
  }
  if($info=~m/SAP=(\d*\.?\d*)/){
        $SAP = "$1";
  }
  if($info=~m/SRP=(\d*\.?\d*)/){
        $SRP = "$1";
  }
  if($info=~m/AF=(\d*\.?\d*)/){
        $AF = "$1";
  }
  #AB,AF,DP,DPRA,EPP, EPPR, MEANALT, MQM, MQMR, ODDS, PAIRED, PAIREDR, PAO, PQA,
  #PQR,PRO, RPL, RPR, RPP, RPPR, SAF, SRF, SAP, SRP

  print "\n$chr\t$pos\t$match\t$AB\t$AF\t$DPRA\t$EPP\t$EPPR\t$MEANALT\t$MQM";
  print "\t$MQMR\t$ODDS\t$PAIRED\t$PAIREDR\t$PAO\t$PQA\t$PQR\t$PRO\t";
  print "$RPL\t$RPR\t$RPP\t$RPPR\t$SAF\t$SRF\t$SAP\t$SRP";

}

