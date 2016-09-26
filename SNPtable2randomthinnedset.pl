#!/bin/perl
use warnings;
use strict;

#This script reduces a snp table to one snp every 1000 bp at max. It runs a thousand bp window and picks a random snp in each window.
my $dist = 1000; #Minimum distance between SNPs

my $previous_chr;
my $previous_pos;
my $current_end_bp = $dist;
my @snp_array;
while (<STDIN>){
	chomp;
	if ($. == 1){
		print "$_";
	}else{
		my @a = split(/\t/,$_);
		my $chr = $a[0];
		my $pos = $a[1];
		unless ($previous_chr){
			$previous_chr = $chr;
			until ($pos < $current_end_bp){
				$current_end_bp+= $dist;
			}
			push(@snp_array, $_);
			next;
		}
		if ($chr ne $previous_chr){
			$previous_chr = $chr;
			my $length = scalar(@snp_array);
			my $rand = rand(int(@snp_array));
			print "\n$snp_array[$rand]";
			undef(@snp_array);
			$current_end_bp = $dist;
                        until ($pos < $current_end_bp){
                                $current_end_bp+= $dist;
                        }
			push(@snp_array, $_);
			next;
		}elsif ($current_end_bp >= $pos){
			push(@snp_array, $_);
			next;
		}elsif ($current_end_bp < $pos){
			my $length = scalar(@snp_array);
                        my $rand = rand(int(@snp_array));
                        print "\n$snp_array[$rand]";
                        undef(@snp_array);
                        until ($pos < $current_end_bp){
                                $current_end_bp+= $dist;
                        }
                        push(@snp_array, $_);
                        next;
		}
	}
}

