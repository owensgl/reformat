#!/usr/bin/perl
# also removes those barcodes
use warnings;
use strict;

# perl GBS_fastq_Demultiplexer_vX.pl barcodes.txt R1.fastq R2.fastq thenameIwantStuckonEveryfile
#This version is for when read 1 is barcoded. Single PstI enzyme

unless (@ARGV == 3) {
	print "usage perl scriptname.pl barcodes.txt R1.fastq R2.fastq\n";
	die;
}
my $delete_cutsite = "TRUE"; #Set to false if you don't want to delete the cutsites (which are real but can't be variable).
my $bar = $ARGV[0];
my $fastq_1 = $ARGV[1];
my $fastq_2 = $ARGV[2];
#make true to print R1 and R2 to separate files
my $print_mates = 1;
my $read1_enzyme = "TGCAG"; #Enzyme 1 cut site after cutting
my $read2_enzyme = "TGCAG"; #Enzyme 2 cut site after cutting
#my $print_mates;
# get the barcodes
my %bar1;
my %bar2;
my %c_fail;
my %ph;
my %bar1_permutations;
my %bar2_permutations;
my @bases = qw(A T C G N);
open IN, $bar;
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
	$bar1{$a[0]}=$a[1];
	#Make all possible permutations of barcodes:

	#this is to remove old ones
	#print "\t$a[1]\t$a[0]";
}
close IN;
my @samples = sort keys %bar1;
unless($fastq_1 =~ /\.gz$/){
	print "Input fastq files should be gzipped\n";
	exit;
}
open (FAST1, "gunzip -c $fastq_1 |");
open (FAST2, "gunzip -c $fastq_2 |");

my $c;
my $line_tracker;
my %read_info;
my %extra_barcode;
my %bar1_number;
while (my $seq1 = <FAST1>){
	my $seq2 = (<FAST2>);
	chomp $seq1;
	chomp $seq2;
	$c++;
	$line_tracker++;
	if ($line_tracker == 1){
		$read_info{"R1"}{"header"} = $seq1;
		$read_info{"R2"}{"header"} = $seq2;
	}
	if ($line_tracker == 2){
		$read_info{"R1"}{"seq"} = $seq1;
		$read_info{"R2"}{"seq"} = $seq2;
	}
	if ($line_tracker == 4){
		$line_tracker = '';
		$read_info{"R1"}{"qual"} = $seq1;
		$read_info{"R2"}{"qual"} = $seq2;

		my $read = $read_info{"R1"}{"seq"};
		my $qual = $read_info{"R1"}{"qual"};
       	 	my $read2 = $read_info{"R2"}{"seq"} ;
		my $qual2 = $read_info{"R2"}{"qual"};
		my $bar_number;
		my $bc1seq;
		my $bc1seq_real; #The observed barcode sequenced include possible errors
#		print STDERR "For this read:";
		foreach my $i (4..9){ #Check both reads to find sample identity
			my $tmp = $read;
			my $re_site = substr($tmp,($i),length($read1_enzyme));
			if ($re_site eq $read1_enzyme){
				my $bc = substr($tmp,0,$i);
				foreach my $sample (@samples){
					if ($bar1{$sample} eq $bc){
						$bar1_number{$sample}++;
						goto MOVEON;
					}
				}
				$extra_barcode{$bc}++;
			}
		}
		MOVEON:
#		print STDERR "\n";
	}
	#this waits for 1million lines to print out to save the HD some agony
	if ($c==400000) {
		goto PRINTTOTALS;
	}
}
PRINTTOTALS:
foreach my $sample (sort keys %bar1){
	unless($bar1_number{$sample}){
		$bar1_number{$sample} = 0;
	}
	my $percent = ($bar1_number{$sample} / 100000 ) * 100;
	my $state = "missing";
	if ($percent > 0.1){
		$state = "present";
	}
	print "Expected\t$bar1{$sample}\t$percent\t$state\n";
}
foreach my $barcode (sort {$extra_barcode{$b} <=> $extra_barcode{$a} }  keys %extra_barcode){
	my $percent = ($extra_barcode{$barcode} / 100000) * 100;
	if ($percent > 0.1){
		print "Unexpected\t$barcode\t$percent\n";
	}
}
