#!/bin/perl

#This script takes a phased vcf, a list of gene locations, and outputs one fasta file per gene.
use warnings;
use strict;
my $genefile = $ARGV[0];

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
open GENEFILE, $genefile;
while (<GENEFILE>){
        chomp;
        if ($_ =~/^\>/g){
                my @a = split(/\ /, $_);
                my $begin = $a[2];
                $begin =~ s/begin=//g;
                my $end = $a[3];
                $end =~ s/end=//g;
                my $name = $a[0];
                $name =~ s/>//g;
                my $chr = $a[5];
                $chr =~ s/chr=//g;
                $genestart{$name} = $begin;
                $geneend{$name} = $end;
                $genechr{$name} = $chr;
                push (@{$gene_array_name{$chr}}, $name);
		push(@{$gene_array_start{$chr}}, $begin);
		push(@{$gene_array_end{$chr}}, $end);
        }
}
close GENEFILE;

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
	$counter++;
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
		if ($alt eq '.'){
			$invariant_site++;
		}elsif($alts[2]){
			$multiallelic_site++;
		}elsif($alts[1]){
			$triallelic_site++;
		}else{
			$biallelic_site++;
		}
		if ($qual < $min_qual){
			$multiallelic_site++ #Prints only N
		}
		if (($counter % 100000)== 0){
			print "Processing $chrom $pos...\n";
		}
		#Check to see if this is the start of a gene
		REPEAT:
		my $num = @{$gene_array_start{$chrom}} -1;
		unless($current_gene){
			foreach my $j ($current_start_search..$num){
#				print "For $pos I'm trying $gene_array_name{$chrom}[$j] that starts at $gene_array_start{$chrom}[$j]\n";
				if (($gene_array_start{$chrom}[$j] <= $pos) and ($gene_array_end{$chrom}[$j] >= $pos)){
					$current_gene = $gene_array_name{$chrom}[$j];
					$current_start_search = $j;
					goto GOTGENE;
				}elsif ($gene_array_start{$chrom}[$j] > $pos){
					$current_start_search = $j;
#					print "START SEARCH AT $current_start_search\n";
					goto SKIP;
				}
			}
			SKIP:
			next;
		}else{
			#it's not in the same gene or in the next chromosome
			if (($geneend{$current_gene} < $pos) or ($genechr{$current_gene} ne $chrom)){
#				print "Processing $pos which is after $current_gene ($genestart{$current_gene} - $geneend{$current_gene})\n";
				if (%sequence){
					&print_fastas();
				}
				undef($current_gene);
				undef(%sequence);
				undef(%haplotype_count);
				undef(%haplotype_strand);
				goto REPEAT;
			}
		}
		GOTGENE:		
		if ($biallelic_site){
			&call_biallelic($line);
		}elsif($invariant_site){
			&call_invariants($line);
		}elsif($triallelic_site){
			&call_triallelic($line);
		}elsif($multiallelic_site){
			&call_multiallelic($line);
		}
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
  	        	for my $strand (1..2){
                                $sequence{$i}{$strand}.= "N";
                        }
		}
		elsif ($dp > $min_dp){
			if ($fields[0] eq '0/0'){
				for my $strand(1..2){
					$sequence{$i}{$strand}.=$ref;
				}
			}elsif($fields[0] eq '1/1'){
				for my $strand(1..2){
					$sequence{$i}{$strand} .= $alt;
				}
			}elsif($fields[0] eq '0/1'){
				my $phase;
				my $random_draw = int(rand(2)); #Draw a random value 0 or 1 to decide which strand
				if ($formats[4] eq "HP"){
					my $hp = $fields[4];
					my @hps = split(/,/, $hp);
					my @tmp = split(/-/,$hps[0]);
					my $hp_number = $tmp[0]; #This number is the position of the start of the haplotype
					$haplotype_count{$i}{$hp_number}++; #count number of different haplotypes per gene
					unless($haplotype_strand{$i}{$hp_number}){ #If this haplotype doesn't already have a picked strand, then assign a random one
						$haplotype_strand{$i}{$hp_number} = $random_draw;
					}
					$phase = $tmp[1];
					if ($haplotype_strand{$i}{$hp_number} == 1){ #If the random value is 1 then the alleles are reverse from the vcf
						$phase = &flip_strand($phase);
					}
				}else{
					$phase = $random_draw+1;
					$haplotype_count{$i}{$pos}++;
				}
				if ($phase eq 1){
					$sequence{$i}{1}.=$ref;
					$sequence{$i}{2}.=$alt;
				}elsif($phase eq 2){
					$sequence{$i}{1}.=$alt;
					$sequence{$i}{2}.=$ref;
				}
				else{ print "The phase is $phase for 0/1bi on $pos, in $samplelist{$i}.\n";}
			}elsif($fields[0] eq './.'){
				for my $strand (1..2){
                                	$sequence{$i}{$strand}.= "N";
				}
                        }else{
				print "A sample has >5 reads but no call? It's call is $fields[0]\n";
			}
				
		}else{
			for my $strand (1..2){
				$sequence{$i}{$strand}.= "N";
			}
		}
	}
}

sub flip_strand{
	my $phase = shift;
	if ($phase == 1){
		return "2";
	}elsif ($phase == 2){
		return "1";
	}else{
		return "PROBLEM";
	}
}

sub call_triallelic {
	my $line = shift;
	my @a = split(/\t/,$line);
        my $pos = $a[1];
       	my $chrom = $a[0];
        my $ref = $a[3];
	my $alt = $a[4];
	my $info = $a[7];
	my $format = $a[8];
	my @alts = split (/,/,$alt);
	
	my @formats = split(/:/, $format); 
	foreach my $i (9..$final_sample){
		my @fields = split(/:/, $a[$i]);
		my $dp = $fields[2];
		if ($dp eq '.'){
  	        	for my $strand (1..2){
                                $sequence{$i}{$strand}.= "N";
                        }
		}
		elsif ($dp > $min_dp){
			if ($fields[0] eq '0/0'){
				for my $strand(1..2){
					$sequence{$i}{$strand}.=$ref;
				}
			}elsif($fields[0] eq '1/1'){
				for my $strand(1..2){
					$sequence{$i}{$strand} .= $alts[0];
				}
			}elsif($fields[0] eq '2/2'){
				for my $strand(1..2){
					$sequence{$i}{$strand} .=$alts[1];
				}
			}elsif($fields[0] eq '0/1'){
				my $phase;
				my $random_draw = int(rand(2));
				if ($formats[4] eq "HP"){
					my $hp = $fields[4];
					my @hps = split(/,/, $hp);
					my @tmp = split(/-/,$hps[0]);
					my $hp_number = $tmp[0];
					$haplotype_count{$i}{$hp_number}++;
					unless($haplotype_strand{$i}{$hp_number}){ #If this haplotype doesn't already have a picked strand, then assign a random one
                                                $haplotype_strand{$i}{$hp_number} = $random_draw;
                                        }
                                        $phase = $tmp[1];
                                        if ($haplotype_strand{$i}{$hp_number} == 1){ #If the random value is 1 then the alleles are reverse from the vcf
                                                $phase = &flip_strand($phase);
                                        }
				}else{
					$phase = $random_draw+1;
					$haplotype_count{$i}{$pos}++;
				}
				if ($phase eq 1){
					$sequence{$i}{1}.=$ref;
					$sequence{$i}{2}.=$alts[0];
				}elsif($phase eq 2){
					$sequence{$i}{1}.=$alts[0];
					$sequence{$i}{2}.=$ref;
				}
				else{ print "The phase is $phase for 0/1 on $pos, in $samplelist{$i}\n";}
			}elsif($fields[0] eq '0/2'){
				my $phase;
				my $random_draw = int(rand(2));
				if ($formats[4] eq "HP"){
					my $hp = $fields[4];
					my @hps = split(/,/, $hp);
					my @tmp = split(/-/,$hps[0]);
					my $hp_number = $tmp[0];
					$haplotype_count{$i}{$hp_number}++;
					unless($haplotype_strand{$i}{$hp_number}){ #If this haplotype doesn't already have a picked strand, then assign a random one
                                                $haplotype_strand{$i}{$hp_number} = $random_draw;
                                        }
                                        $phase = $tmp[1];
                                        if ($haplotype_strand{$i}{$hp_number} == 1){ #If the random value is 1 then the alleles are reverse from the vcf
                                                $phase = &flip_strand($phase);
                                        }
				}else{
					$phase = $random_draw+1;
					$haplotype_count{$i}{$pos}++;
				}
				if ($phase eq 1){
					$sequence{$i}{1}.=$ref;
					$sequence{$i}{2}.=$alts[1];
				}elsif($phase eq 2){
					$sequence{$i}{1}.=$alts[1];
					$sequence{$i}{2}.=$ref;
				}
				else{ print "The phase is $phase for 0/2 on $pos, in $samplelist{$i}\n";}
			}elsif($fields[0] eq '1/2'){
				my $phase;
				my $random_draw = int(rand(2));
				if ($formats[4] eq "HP"){
					my $hp = $fields[4];
					my @hps = split(/,/, $hp);
					my @tmp = split(/-/,$hps[0]);
					my $hp_number = $tmp[0];
					$haplotype_count{$i}{$hp_number}++;
					unless($haplotype_strand{$i}{$hp_number}){ #If this haplotype doesn't already have a picked strand, then assign a random one
                                                $haplotype_strand{$i}{$hp_number} = $random_draw;
                                        }
                                        $phase = $tmp[1];
                                        if ($haplotype_strand{$i}{$hp_number} == 1){ #If the random value is 1 then the alleles are reverse from the vcf
                                                $phase = &flip_strand($phase);
                                        }
				}else{
					$phase = $random_draw+1;
					$haplotype_count{$i}{$pos}++;
				}
				if ($phase eq 1){
					$sequence{$i}{1}.=$alts[0];
					$sequence{$i}{2}.=$alts[1];
				}elsif($phase eq 2){
					$sequence{$i}{1}.=$alts[1];
					$sequence{$i}{2}.=$alts[0];
				}
				else{ print "The phase is $phase for 1/2 on $pos, in $samplelist{$i}\n";}
			}elsif($fields[0] eq './.'){
				for my $strand (1..2){
                                	$sequence{$i}{$strand}.= "N";
				}
                        }else{
				print "A sample has >5 reads but no call? It's call is $fields[0]\n";
			}
				
		}else{
			for my $strand (1..2){
				$sequence{$i}{$strand}.= "N";
			}
		}
	}
}


sub call_multiallelic{
	my $line = shift;
        my @a = split(/\t/,$line);
	foreach my $i (9..$final_sample){
		for my $strand (1..2){
                	$sequence{$i}{$strand}.= "N";
                }
	}
}
sub call_invariants{
        my $line = shift;
        my @a = split(/\t/,$line);
        my $pos = $a[1];
        my $chrom = $a[0];
        my $ref = $a[3];
        my $alt = $a[4];
        my $info = $a[7];
	my $format = $a[8];
	if ($format eq "GT:DP"){
		foreach my $i (9..$final_sample){
			my @fields = split(/:/, $a[$i]);
			my $dp = $fields[1];
			if ($dp > $min_dp){
				for my $strand(1..2){
					$sequence{$i}{$strand}.=$ref;
				}
			}else{
				for my $strand (1..2){
					$sequence{$i}{$strand}.= "N";
				}
			}
		}
	}elsif ($format eq "GT:AD:DP"){
		foreach my $i (9..$#a){
			my @fields = split(/:/, $a[$i]);
			my $dp = $fields[2];
			if ($dp > $min_dp){
				for my $strand(1..2){
					$sequence{$i}{$strand}.=$ref;
				}
			}else{
				for my $strand (1..2){
					$sequence{$i}{$strand}.= "N";
				}
			}
		}
	}
}

sub print_fastas{
	my $outfile = "$folder/$current_gene.fasta";
	open (OUTFILE, "> $outfile");
	foreach my $i (9..$final_sample){
		my $haplotypes = (keys %{$haplotype_count{$i}})+1;
#		print "$current_gene has $haplotypes haplotypes in $samplelist{$i}\n";
		print OUTFILE ">$samplelist{$i}:1 gene=$current_gene haplotypes=$haplotypes\n";
		print OUTFILE "$sequence{$i}{1}\n";
		print OUTFILE ">$samplelist{$i}:2 gene=$current_gene haplotypes=$haplotypes\n";
		print OUTFILE "$sequence{$i}{2}\n";
	}
	close OUTFILE;
}

