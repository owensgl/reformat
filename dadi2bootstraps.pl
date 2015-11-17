#!/bin/perl

#This script takes a dadi snp input and bootstraps it in 1MB blocks. It assumes the last two columns in the dadi file are chromosome and position
#It also assumes the dadi file SNPs are in order.
#Give it the prefix to bootstrapped replicates filename
my $outfile = $ARGV[0];


my $n_reps = 300;
my $block_size = 1000000;
my $header;
my $block_counter = 0;
my $current_chrom;
my $current_pos_end = $block_size;
my $first_line;
my %block_hash;
while (<STDIN>){
	chomp;
	my $line = $_;
	if ($. == 1){
		$header = $line;
		next;
	}
	my @a = split(/\t/,$line);
	my $chrom = $a[($#a - 1)];
	my $pos = $a[$#a];
	unless ($first_line){
		$current_chrom = $chrom;
		until($pos < $current_pos_end){
			$current_pos_end+= $block_size;
		}
		$first_line++;
	}
	if (($current_chrom eq $chrom) and ($pos < $current_pos_end)){
		$block_hash{$block_counter} .= "\n$line";
	}else{
		#If its the same chromosome
		if ($current_chrom eq $chrom){
			until($pos < $current_pos_end){
				$current_pos_end+= $block_size;
			}
			$block_counter++;
		}else{ #If its a new chromosome reset the block position
			$current_chrom = $chrom;
			$current_pos_end = $block_size;
			until($pos < $current_pos_end){
				$current_pos_end+= $block_size;
			}
			$block_counter++;
		}
		$block_hash{$block_counter} .= "\n$line";
	}
}

#Now print out the bootstrapped replicates

foreach my $n(1..$n_reps){
	my $number = sprintf("%03d",$n);
	open(my $out, '>', "${outfile}.$number.txt");
	print $out "$header";
	foreach my $i (0..$block_counter){
		my $random = int(rand($block_counter+1));
		print $out "$block_hash{$random}";
	}
}
