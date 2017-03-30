#!/bin/perl

#This takes a gff3 file of repeat regions and makes a list of regions, excludes those regions and makes a list of regions to SNP call

my $current_chr = "NA";
my $current_start;
my $current_end;
my %chr_lengths;
print "chr\tstart\tstop\tlength";
while (<STDIN>){
  chomp;
  if ($_ =~ /^##sequence_region/){
    my @a = split(/\t/,$_);
    $chr_lengths{$a[1]} = $a[3];
  }
  next if /^#/;
  my @a = split(/\t/,$_);
  my $type = $a[2];
  if (($type eq "similarity") or ($type = "repeat_region")){
    #Load in info
    my $start = $a[3];
    my $end = $a[4];
    my $chr = $a[0];

    #check if we're on a new chromosome
    if ($chr ne $current_chr){
      #Print out end of previous chromosome
      if ($chr_lengths{$current_chr}){
	my $length = $chr_lengths{$current_chr} - $current_end;
        print "\n$current_chr\t$current_end\t$chr_lengths{$current_chr}\t$length";
      }
      #Refresh for a new chromosome, and print out starting window
      $current_chr = $chr;
      $current_start = "0";
      $current_end = ($start);
      my $length = $current_end - $current_start;
      print "\n$current_chr\t$current_start\t$current_end\t$length";
      $current_start = ($end);
    }else{
      #If the next repeat overlaps with the end of the last repeat
      if ($start <= $current_start){
        #Combine the exclusion window
        $current_start = ($end);
      }else{
        #If the next repeat does not overlap, then print out an interval between the repeats.
        $current_end = ($start);
	my $length = $current_end - $current_start;
        print "\n$current_chr\t$current_start\t$current_end\t$length";
        $current_start = ($end);
      }
    }
  }

}
