#!/usr/bin/perl

use warnings;
use strict;


my $pop = $ARGV[0];
my %pop;

my %samples;
my @samples;
my %popList;
my %pops;

open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	$pops{$a[1]}++;
	$popList{$a[1]}++;
}
close POP;

my %sample;
while (<STDIN>){
	chomp;
	my @a = split (/\t/,$_);
	if ($_ =~ m/##/){next;}
	if ($_ =~ m/#/){
		foreach my $i (9..$#a){
			$sample{$i} = $a[$i];
		}
		my $first_pop;
		foreach my $pop (sort keys %pops){
			unless($first_pop){
				print "$pop";
				$first_pop++;
			}else{
				print " $pop";
			}
		}
	}else{
		my %calls;
		foreach my $i (9..$#a){
			my @fields = split(/:/,$a[$i]);
			if (($fields[0] eq '.') or ($fields[0] eq './.')){next;}
			if ($fields[0] eq '0/0'){
				$calls{$pop{$sample{$i}}}{0}+=2;
			}elsif ($fields[0] eq '0/1'){
				$calls{$pop{$sample{$i}}}{0}+=1;
				$calls{$pop{$sample{$i}}}{1}+=1;
			}elsif ($fields[0] eq '1/1'){
				$calls{$pop{$sample{$i}}}{1}+=2;
			}
		}
		my $first_pop;
                foreach my $pop (sort keys %pops){
			foreach my $x (0..1){
				unless($calls{$pop}{$x}){
					$calls{$pop}{$x}=0;
				}
			}
                        unless($first_pop){	
                                print "\n$calls{$pop}{0},$calls{$pop}{1}";
                                $first_pop++;
                        }else{
                                print " $calls{$pop}{0},$calls{$pop}{1}";
                        }
                }
	}
}
