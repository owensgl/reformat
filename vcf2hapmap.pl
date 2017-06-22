#!/bin/perl
use strict;
use warnings;

#This file outputs to hapmap format. 

while(<STDIN>){
 if(eof()){
  #print "\n"; 
 }
 else{
  my $line = "$_";
  chomp $line;
  my @fields = split /\t/,$line;
  if($line=~m/^##/){
   next;
  }
  if ($line =~m/^#CHROM/){
   print "rs\talleles\tchrom\tpos\tstrand\tassembly\tcentre\tprotLSID\tpanel\tQcode";
   foreach my $i (9..$#fields){
    print "\t$fields[$i]";
   }
  }
  else{
   my $chr = $fields[0];
   my $pos = $fields[1];
   my $ref = $fields[3];
   my $alt = $fields[4];
   my $multi_alt;
   my @alts;
   @alts = split(/,/,$alt);
   if (length($alt) > 1){
    $multi_alt++;
   }
   print "\n${chr}_$pos\t$ref";
   if ($multi_alt){
    foreach my $i (@alts){
     print "/$i";
    }
   }else{
    print "/$alt";
   }
   print "\t$chr\t$pos\t+\tNA\tNA\tNA\tNA\tNA";
   foreach my $i (9..$#fields){
    my $genotype;
    if ($fields[$i] ne '.'){
     my @info = split(/:/,$fields[$i]);
     my $call = $info[0];
     my @bases = split(/\//,$call);
     foreach my $j (0..1){
      if ($bases[$j] eq "0"){
       $genotype .= $ref;
      }elsif ($bases[$j] eq "1"){
       $genotype .= $alts[0];
      }elsif ($bases[$j] eq "2"){
       $genotype .= $alts[1];
      }elsif ($bases[$j] eq "3"){
       $genotype .= $alts[2];
      }elsif ($bases[$j] eq "."){
       $genotype = "NN";
       goto PRINTGENOTYPE;
      }
     }
    }else{
     $genotype = "NN";
    }
    PRINTGENOTYPE:
unless($genotype){ print STDERR "$chr\t$pos\n";}
    print "\t$genotype";
   }
   
  }
 }
}

