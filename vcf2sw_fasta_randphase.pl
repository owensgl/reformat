#!/bin/perl

#This script takes a regular vcf, a list of samples, and outputs one fasta file per vcf. It uses a sliding window and prints out one fasta per X physical distance. It only prints biallelic sites.
use warnings;
use strict;
my $samplefile = $ARGV[0];

my $min_dp = 5;
my $min_qual = 20;

my $folder = "fasta";
my %genehash;
my %genestart;
my %geneend;
my %genechr;
my @genelist;
my %gene_array_name;
my %gene_array_start;
my %gene_array_end;
my $window_size = 1000000;
my $start = 0;
my $end = $start + $window_size;

my %printlist;
open SAMPLEFILE, $samplefile;
while(<SAMPLEFILE>){
	chomp;
	$printlist{$_}++;
}	
close SAMPLEFILE;

my %samplelist;
my $current_gene;
my %haplotype_count;
my %haplotype_strand;
my %sequence;
my $final_sample;
my $counter;
my $current_start_search = 0;
my $current_chrom = "NA";
my %phase;
#phased vcf file input piped from STDOUT
while(<STDIN>){
	chomp;
	my $line = "$_";
	if ($line =~m/^##/){
		next;
	}elsif ($line =~ m/^#CHROM/){
		my @a = split(/\t/,$line);
		foreach my $i (9..$#a){
			$samplelist{$i} = $a[$i];
		}
		$final_sample = $#a;
	}else{
		my @a = split(/\t/,$line);
		my $info = $a[7];
		my @infos = split(/:/, $info);
		if ($info =~ m/^NCC/){
			next;
		}
		my $pos = $a[1];
		my $chrom = $a[0];
		if ($current_chrom ne $chrom){
			$current_start_search = 0;
			$current_chrom = $chrom;
		}
		my $ref = $a[3];
		if ($ref eq "N"){
			next;
		}
		my $alt = $a[4];
		my @alts = split(/,/,$alt);
		my $qual = $a[5];
		my $lowqual_site;
		my $biallelic_site;
		my $triallelic_site;
		my $multiallelic_site;
		my $invariant_site;
		if ($qual eq "."){
			next;
		}
		if ($qual < $min_qual){
			next; 
		}
		if ($alt eq '.'){
			next;
		}elsif($alts[2]){
			next;
		}elsif($alts[1]){
			next;
		}else{
			$biallelic_site++;
		}
		$counter++;

		if (($counter % 1000)== 0){
			print "Processing $chrom $pos...\n";
		}
		#Check to see if this is the start of a gene
		REPEAT:
		if (($chrom ne $current_chrom) or ($pos > $end)){
			if (%sequence){
				&print_fastas();
			}
			undef(%sequence);
			if ($chrom ne $current_chrom){
				$current_chrom = $chrom;
				$start = 0;
				$end = $start + $window_size;
			}else{
				until ($pos < $end){
					$end+= $window_size;
					$start+=$window_size;
				}
			}
		}
			
		&call_biallelic($line);
#		print "The current sequence for the first sample is $sequence{9}{1}\n";
	}
}


sub call_biallelic {
	my $line = shift;
	my @a = split(/\t/,$line);
	my $pos = $a[1];
	my $chrom = $a[0];
	my $ref = $a[3];
	my $alt = $a[4];
	my $info = $a[7];
	my $format = $a[8];
	my @multi = split (/,/,$alt);
	if ($multi[2]){
		print "There are three alleles in $chrom $pos\n";
	}
	my @formats = split(/:/, $format); 
	foreach my $i (9..$final_sample){
		my @fields = split(/:/, $a[$i]);
		my $dp = $fields[2];
		if ($dp eq '.'){
			$sequence{$i}.= "N";
		}
		elsif ($dp > $min_dp){
			if ($fields[0] eq '0/0'){
				$sequence{$i}.=$ref;
			}elsif($fields[0] eq '1/1'){
				$sequence{$i}.= $alt;
			}elsif($fields[0] eq '0/1'){
				my $random_draw = int(rand(2)) +1;
				if ($random_draw == 1){
					$sequence{$i}.=$ref;
				}else{
					$sequence{$i}.=$alt;
				}
			}else{
				$sequence{$i}.="N";
		}
		}else{
			$sequence{$i}.="N";
		}
	}
}



sub print_fastas{
	my $outfile = "$folder/${current_chrom}_$start-$end.fasta";
	open (OUTFILE, "> $outfile");
	foreach my $i (9..$final_sample){
		if($printlist{$samplelist{$i}}){
#			print "$current_gene has $haplotypes haplotypes in $samplelist{$i}\n";
			print OUTFILE ">$samplelist{$i} start=$start end=$end\n";
			print OUTFILE "$sequence{$i}\n";

		}
	}
	close OUTFILE;
}

