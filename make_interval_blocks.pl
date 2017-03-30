#!/bin/perl
#This script takes a bed format list of intervals and selects intervals up to a specified total size.
#It also removes intervals below a minimum size.

my $max_size= 100000;
my $min_interval_size = 100;
my $number = 1;
$number = sprintf("%05d", $number);
my $first_line = 1;
my $current_dist;
while(<STDIN>){
  chomp;
  if ($. == 1){
    next;
  }
  my $line = $_;
  my @a = split(/\t/,$line);
  if ($a[3] < $min_interval_size){next;}
  if ($first_line){
    #If its the first line then open a new file
    open(OUTPUT, '>', "interval.$number.txt");
    print OUTPUT "$line";
    my $dist = $a[3];
    $current_dist+= $dist;
    $first_line = 0;
  }else{
    #If its not a new file, print the line.
    print OUTPUT "\n$line";
    my $dist = $a[3];
    $current_dist+= $dist;
  }
  if ($current_dist >= $max_size){
    #if the region is bigger than the max size then close the file.
    close OUTPUT;
    $current_dist = 0;
    $first_line = 1;
    $number++;
  }
}
