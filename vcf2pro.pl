#!/bin/perl
#use strict;
use warnings;

my $pop = $ARGV[0]; #list of the species assignment for each sample to be used.
my $out = $ARGV[1]; #outfile

my %poplist;
my %pophash;
my @bases = qw(A C G T);
my $current_chr = "NA";
my %name;
open POP, $pop;
while (<POP>){
	chomp;
	my @a = split(/\t/, $_);
	$pophash{$a[0]} = $a[1];
	$poplist{$a[1]}++;
}
close POP;
foreach my $pop (sort keys %poplist){
	open $pop, '>', "${out}.$pop.pro";
}

while(<STDIN>){
		my $line = "$_";
		chomp $line;
		my @fields = split /\t/,$line;
	    	if($line=~m/^##/){
			next;
		}
		my $chrome = shift @fields;
		my $pos =    shift @fields;
		my $loc = "${chrome}_$pos";
		my $id =     shift @fields;
		my $ref =    shift @fields;
		my $alt =    shift @fields;
		my @alts = split (/,/, $alt);
		my $qual =   shift @fields;
		my $filter = shift @fields;
		my $info =   shift @fields;
		my $format = shift @fields;
		
		if($line=~m/^#/){
			foreach my $i (0..$#fields){
				$name{$i} = $fields[$i];
			}
			next;
		}
                if ($current_chr ne $chrome){
                        foreach my $pop (sort keys %poplist){
                                print $pop ">$chrome";
                        }
                        $current_chr = $chrome;
                }
		my %readcounts;
		foreach my $i (0..$#fields){
			if ($fields[$i] eq './.'){
#				print "FOUND MISSING DATA in $name{$i}\n";
				next;
			}elsif($pophash{$name{$i}}){
				#print "$pophash{$name{$i}}\n";
				my @data = split(/:/, $fields[$i]);
				my @reads = split(/,/, $data[1]);
				if ($#alts == 0){
					$readcounts{$pophash{$name{$i}}}{$ref} += $reads[0];
					$readcounts{$pophash{$name{$i}}}{$alt} += $reads[1];
				}elsif ($#alts == 1){
					$readcounts{$pophash{$name{$i}}}{$ref} += $reads[0];
					$readcounts{$pophash{$name{$i}}}{$alts[0]} += $reads[1];
					$readcounts{$pophash{$name{$i}}}{$alts[1]} += $reads[2];				
				}elsif ($#alts == 2){
					$readcounts{$pophash{$name{$i}}}{$ref} += $reads[0];
					$readcounts{$pophash{$name{$i}}}{$alts[0]} += $reads[1];
					$readcounts{$pophash{$name{$i}}}{$alts[1]} += $reads[2];
					$readcounts{$pophash{$name{$i}}}{$alts[2]} += $reads[3];
				}
			}
		}
		foreach my $pop (sort keys %poplist){
			foreach my $base (@bases){
				unless ($readcounts{$pop}{$base}){
					$readcounts{$pop}{$base} = 0;
				}
			}
			print $pop "\n$pos";
			foreach my $base (@bases){
				print $pop "\t$readcounts{$pop}{$base}";
			}
		}
}
