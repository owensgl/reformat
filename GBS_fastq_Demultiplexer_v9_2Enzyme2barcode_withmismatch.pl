#!/usr/bin/perl
# also removes those barcodes
use warnings;
use strict;

# perl GBS_fastq_Demultiplexer_vX.pl barcodes.txt R1.fastq R2.fastq thenameIwantStuckonEveryfile
#This version is for when both reads are barcoded.

unless (@ARGV == 4) {
	print "usage perl GBS_fastq_Demultiplexer_vX.pl barcodes.txt R1.fastq R2.fastq thenameIwantStuckonEveryfile\n";
	die;
}
my $bar = $ARGV[0];
my $fastq_1 = $ARGV[1];
my $fastq_2 = $ARGV[2];
my $out = $ARGV[3];
#make true to print R1 and R2 to separate files
my $print_mates = 1;
my $read1_enzyme = "TGCAG"; #Enzyme 1 cut site after cutting
my $read2_enzyme = "CGG"; #Enzyme 2 cut site after cutting
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
	$bar2{$a[0]}=$a[2];
	#Make all possible permutations of barcodes:
	foreach my $i (0..length($a[1])-1){
		my @parts = split(//,$a[1]);
		foreach my $base (@bases){
			my $permutation;
			foreach my $j (0..length($a[1])-1){
				if ($j eq $i){
					$permutation .= $base;
				}else{
					$permutation .= $parts[$j];
				}
			}
			$bar1_permutations{$a[0]}{$permutation} = $a[0];
		}
	}
	if ($a[2]){
	        foreach my $i (0..length($a[2])-1){
        	        my @parts = split(//,$a[2]);
               		foreach my $base (@bases){
                        	my $permutation;
                        	foreach my $j (0..length($a[2])-1){
                                	if ($j eq $i){
                                        	$permutation .= $base;
                                	}else{
                                        	$permutation .= $parts[$j];
                                	}
                        	}
                        	$bar2_permutations{$a[0]}{$permutation} = $a[0];
				
                	}
        	}
	}

	#this is to remove old ones
	#print "\t$a[1]\t$a[0]";
	if ($print_mates){
		my $filenameR1 = "$out"."$a[0]"."_R1.fastq";
		my $filenameR2 = "$out"."$a[0]"."_R2.fastq";
		if (-e $filenameR1) {
			system ("rm $filenameR1");
		}
		if (-e $filenameR2) {
			system ("rm $filenameR2");
		}
	}else{
		if (-e "$out"."$a[0].fastq") {
			system ("rm $out"."$a[0].fastq");
		}
	}
}
system  ("rm $out"."nobar*.fastq");
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
		my %bar1_number;
		my %bar2_number;
		my $bar_number;
		my $bc1seq;
		my $bc2seq;
		my $singlebarcode;
#		print STDERR "For this read:";
		foreach my $i (4..9){ #Check both reads to find sample identity
			my $tmp = $read;
			my $re_site = substr($tmp,($i),length($read1_enzyme));
			if ($re_site eq $read1_enzyme){
				my $bc = substr($tmp,0,$i);
				foreach my $sample (@samples){
					if ($bar1_permutations{$sample}{$bc}){
						$bar1_number{$sample}++;
						$bc1seq = $bar1{$sample};
#						print STDERR " BC1=$sample";
						if ($bar2{$sample}){
							my $j = length($bar2{$sample}); #If you found the barcode on read one, check if the match is on read two.
							my $tmp2 = $read2;
       				           		my $bc2 = substr($tmp2,0,$j);
							if ($bar2_permutations{$sample}{$bc2}){
								if ($bar2_permutations{$sample}{$bc2} eq $sample){
									#my $re_site = substr($tmp2,($j),length($read2_enzyme));
									$bar2_number{$sample}++;
	        	                       	                 	$bc2seq = $bar2{$sample};
									goto MOVEON;
								}
							}
						}else{
							$bar2_number{$sample}++;
							$singlebarcode++;
							goto MOVEON;
						}
					}
				}
			}
		}
		MOVEON:
#		print STDERR "\n";
		foreach my $sample (@samples){
			if (($bar1_number{$sample}) and ($bar2_number{$sample})){
				$bar_number = $sample;
			}
		}
		if ($bar_number){
			unless($singlebarcode){
				$read =~ s/$bc1seq//; #Pull off barcode 1
				$read2 =~ s/$bc2seq//; #Pull off barcode 2
				my $l1 = length($bc1seq);
				$qual = substr($read_info{"R1"}{"qual"},$l1);
				my $l2 = length($bc2seq);
				$qual2 = substr($read_info{"R2"}{"qual"},$l2);
			}else{
				$read =~ s/$bc1seq//; #Pull off barcode 1
				my $l1 = length($bc1seq);
                                $qual = substr($read_info{"R1"}{"qual"},$l1);
			}
		}else{
			$bar_number = "nobar";
		}
		# clean the end of the first read
		# what might be there:
		# CTGCAAGATCGGAAGAGCGGTTCAGCAGGAATGCCGA
		if (($read=~/$read2_enzyme/) and ($bc2seq)){
			my $revBC2 = reverse $bc2seq;
			$revBC2 =~ tr/A|T|G|C|N/T|A|C|G|N/; #Reverse compliment the second barcode
			my $adapter = $revBC2."AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG";
			my @rd = split $read2_enzyme,$read; #If it goes into next
			my $end = $rd[1];
			if ($end){
        		if(length($end)>3){
					if (length($end)>length($adapter)){
						#subset the end and see if it matches
						my $tmp = substr($end,0,length($adapter));
						if ($tmp eq $adapter){
							# only use the start of the read
							$read = $rd[0];
							#trim al	so the qual
							my $tmp_qual = substr ($qual,0,length($read));
							$qual = $tmp_qual;
							$c_fail{"R1"}++;
						}
					}else{
						#subset the adapter and see if matches
						my $tmp  = substr($adapter,0,length($end));
		       	        if ($tmp eq $end){
		       	        	# only use the start of the read
		      	 	        $read = $rd[0];
		       		        my $tmp_qual = substr ($qual,0,length($read));
		       	        	$qual = $tmp_qual;
							$c_fail{"R1"}++;
		       	        }
					}
				}
			}
		}elsif ($read=~/$read2_enzyme/){
			my $adapter = "AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG";
			my @rd = split $read2_enzyme,$read; #If it goes into next
			my $end = $rd[1];
			if ($end){
        			if(length($end)>3){
					if (length($end)>length($adapter)){
						#subset the end and see if it matches
						my $tmp = substr($end,0,length($adapter));
						if ($tmp eq $adapter){
							# only use the start of the read
							$read = $rd[0];
							#trim al	so the qual
							my $tmp_qual = substr ($qual,0,length($read));
							$qual = $tmp_qual;
							$c_fail{"R1"}++;
						}
					}else{
						#subset the adapter and see if matches
						my $tmp  = substr($adapter,0,length($end));
		       	        		if ($tmp eq $end){
		       	        		# only use the start of the read
		      	 	        		$read = $rd[0];
		       		        		my $tmp_qual = substr ($qual,0,length($read));
		       	        			$qual = $tmp_qual;
							$c_fail{"R1"}++;
		       	        		}
					}
				}
			}
		}
		#highly redundant code, for the second read

		if (($read2=~/$read1_enzyme/)and($bc1seq)){
		#	print "befor:\t$read2\n";
			my $revBC = reverse $bc1seq;
			$revBC =~ tr/A|T|G|C/T|A|C|G/;
	#		print "after\t$revBC\n";
                        my $adapter = $revBC."AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT";
                        my @rd = split $read1_enzyme,$read2;
                        my $end = $rd[1];
		#	print "ad:\t\t$adapter\nend\t\t$end\n";
                        if ($end){
                                if(length($end)>3){
                                        if (length($end)>length($adapter)){
                                                #subset the end and see if it matches
                                                my $tmp = substr($end,0,length($adapter));
                                                if ($tmp eq $adapter){
                                                    # only use the start of the read
                                                	$read2 = $rd[0];
                                                	#trim also the qual
                                                    my $tmp_qual = substr ($qual2,0,length($read2));
                                                    $qual2 = $tmp_qual;
													$c_fail{"R2"}++;
                                                }
                                        }else{
                                                #subset the adapter and see if matches
                                                my $tmp  = substr($adapter,0,length($end));
                                                if ($tmp eq $end){
                                                      	# only use the start of the read
                                                      	$read2 = $rd[0];
                                                     	my $tmp_qual = substr ($qual2,0,length($read2));
                                                		$qual2 = $tmp_qual;
														$c_fail{"R2"}++;
                                                }
                                        }
                                }
                        }
                }

		my $outfile =  "$out"."$bar_number";
		$read =~ s/\./N/g;
		$read2 =~ s/\./N/g;
		if((length($read)>49) && (length($read2))>49){
			my $tmp = $read_info{"R1"}{"header"}."\n$read\n+\n$qual\n";
			if ($print_mates){
				push(@{$ph{$outfile."_R1.fastq"}},$tmp);
			}else{
				push(@{$ph{$outfile.".fastq"}},$tmp);
			}
			$tmp = $read_info{"R2"}{"header"}."\n$read2\n+\n$qual2\n";
                        if ($print_mates){
                                push(@{$ph{$outfile."_R2.fastq"}},$tmp);
                        }else{
                                push(@{$ph{$outfile.".fastq"}},$tmp);
                        }
		}# if it is smaller then you dont use it
		%read_info = ();
	}
	#this waits for 1million lines to print out to save the HD some agony
	if ($c==1000000) {
		foreach my $file (keys %ph){
			open OUT, ">>$file";
			foreach my $read (@{$ph{$file}}){
				print OUT "$read";
			}
		}
		%ph = ();
		$c = 0;
	}
}

foreach my $file (keys %ph){
    open OUT, ">>$file";
    foreach my $read (@{$ph{$file}}){
        print OUT "$read";
    }
}
