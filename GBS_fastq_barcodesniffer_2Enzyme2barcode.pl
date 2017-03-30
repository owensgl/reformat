#!/usr/bin/perl
# also removes those barcodes
use warnings;
use strict;

# perl GBS_fastq_Demultiplexer_vX.pl barcodes.txt R1.fastq R2.fastq thenameIwantStuckonEveryfile
#This version is for when both reads are barcoded.

unless (@ARGV == 2) {
	print "usage perl GBS_fastq_barcodesniffer_2Enzyme2barcode.pl R1.fastq.gz R2.fastq.gz\n";
	die;
}
my $fastq_1 = $ARGV[0];
my $fastq_2 = $ARGV[1];
#make true to print R1 and R2 to separate files
my $print_mates = 1;
my $read1_enzyme = "TGCAG"; #Enzyme 1 cut site after cutting
my $read2_enzyme = "CGG"; #Enzyme 2 cut site after cutting
#my $print_mates;
# get the barcodes
unless($fastq_1 =~ /\.gz$/){
	print "Input fastq files should be gzipped\n";
	exit;
}
open (FAST1, "gunzip -c $fastq_1 |");
open (FAST2, "gunzip -c $fastq_2 |");

my $c;
my $line_tracker;
my %read_info;
my %barcode_hash;
my $readcounter;
while (my $seq1 = <FAST1>){
	my $seq2 = (<FAST2>);
	chomp $seq1;
	chomp $seq2;
	$c++;
	$line_tracker++;
	if ($line_tracker == 1){
	}
	if ($line_tracker == 2){
		$read_info{"R1"}{"seq"} = $seq1;
		$read_info{"R2"}{"seq"} = $seq2;
	}
	if ($line_tracker == 4){
		$line_tracker = '';

		my $read = $read_info{"R1"}{"seq"};
       	 	my $read2 = $read_info{"R2"}{"seq"} ;
		my $barcode1 = "N";
		my $barcode2 = "N";
#		print STDERR "For this read:";
		#Check for barcode 1:
		foreach my $i (1..12){
			my $cutsite = substr($read, $i, length($read1_enzyme));
			if ($cutsite eq $read1_enzyme){
				$barcode1 = substr($read, 0, $i);
#				print STDERR "$read\n$barcode1\n";
				goto NEXTREAD;
			}
		}
		NEXTREAD:
		foreach my $i (1..12){
			my $cutsite = substr($read2, $i, length($read2_enzyme));
			if ($cutsite eq $read2_enzyme){
				$barcode2 = substr($read2, 0, $i);
#				print STDERR "$read2\n$barcode2\n";
				goto FINISHREAD;
			}
		}
		FINISHREAD:
		$barcode_hash{"$barcode1\t$barcode2"}++;
		$readcounter++;
		if ($readcounter > 1000000){ 
			goto PRINTOUT;
		}
	}
}
PRINTOUT:
print "barcode1\tbarcode2\tcount";
foreach my $barcode (sort { $barcode_hash{$b} <=> $barcode_hash{$a} } keys %barcode_hash) {
	if ($barcode_hash{$barcode} > 10){
		print "\n$barcode\t$barcode_hash{$barcode}";
	}
}

