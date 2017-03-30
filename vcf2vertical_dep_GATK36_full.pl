#!/bin/perl
use warnings;
use strict;
use File::Basename;
my $min_gt_qual = 20;
my $min_mq = 20;
my $min_qual = 20;
my $min_dp = 5;
my $max_dp =100000;
my $print_ref = 0; #MAke it print_ref = 0 to make it not print the reference as it's own column.
#old VCF2VERTICAL had format from mpileup: GT:PL:DP:GQ
#THIS VERSION:    has format from GATK-UG: GT:AD:DP:GQ:PL
#GLO VERSION Sept2014: includes ./.:
while(<STDIN>){
	if(eof()){
		#print "\n";	
	}
	else{
		my $line = "$_";
		chomp $line;
		my @fields = split /\t/,$line;
	    	if($line=~m/^##/){
			next;
		}
		elsif($fields[7]=~m/^NCC/) {
			next;
		} 
		else{
			my $chrome = shift @fields;
			my $pos =    shift @fields;
			my $id =     shift @fields;
			my $ref =    shift @fields;
			my $alt =    shift @fields;
			my $qual =   shift @fields;
			my $filter = shift @fields;
			my $info =   shift @fields;
			my $format = shift @fields;
			my $mq = "NA";
			if($info=~m/MQ=(\d+)/){
				$mq = "$1";	
			}else{
			#	print STDERR "$pos\t$alt\n";
			}
			if ($qual eq '.'){
				$qual = 0;
			}
			my $meta = "$chrome\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
			my @alts = split(/,/, $alt);
			if($line=~m/^#CHROM/){
				print "CHROM\t$pos";
				foreach(@fields){
					my $long = "$_";
					my $name = basename($long,'.bam');
					print "\t$name";
				}
				if ($print_ref){
					print "\tREF";
				}
				print "\n";
			}
			if ($alts[0] eq "<NON_REF>"){

			}elsif ((length($ref) > 1) or (length($alts[0]) > 1)){ #If its an indel, skip the line
#				print STDERR "$pos\tSkipped because of ref or alt 1\n";
                                next;
                        }
			if ($alt eq "*"){next;}
			if ($alt eq "\."){next;}
			if($alts[1]){
				if (length($alts[1]) > 1){
#					print STDERR "$pos\tSkipped because of alt 2\n";
					next;
				}
			}
			if($alts[2]){
				if (length($alts[2]) > 1){
#					print STDERR "$pos\tSkipped because of alt 3\n";
					next;
				}
			}
			if($alts[3]){
				next;
			}
			if ($alt eq "<NON_REF>"){
				print "$chrome\t$pos";
				if ($format eq "GT:DP"){
					foreach(@fields){
						my @genotype = split (/:/, $_);
						if ($genotype[1]){
							if ($genotype[1] eq '.'){
								print "\tNN";
							}
							elsif ($genotype[1] >= $min_dp){
								print "\t$ref$ref";
							}else{				
								print "\tNN";
							}
						}else{
							print "\tNN";
						}
					}
				}
				elsif ($format eq "GT:AD:DP"){
					foreach(@fields){
                                                my @genotype = split (/:/, $_);
						if ($genotype[2]){
	                                                if ($genotype[2] eq '.'){
        	                                                print "\tNN";
               	                                	}
	                                                elsif ($genotype[2] >= $min_dp){
	                                                        print "\t$ref$ref";
	                                                }else{
	                                                        print "\tNN";
							}

                                                }else{
							print "\tNN";
						}
					}
				}
				elsif ($format eq "GT:DP:PGT:PID"){
					foreach(@fields){
						my @genotype = split(/:/,$_);
						if ($genotype[1]){
							if ($genotype[1] eq '.'){
								print "\tNN";
							}elsif ($genotype[1] >= $min_dp){
								print "\t$ref$ref";
							}else{
								print "\tNN";
							}
						}else{
							print "\tNN";
						}
					}
				}
				else{
					foreach(@fields){
						my @genotype = split(/:/, $_);
						if ($genotype[2]){
							if ($genotype[2] eq '.'){
	                                                	print "\tNN";
        	                                        }
                	                                elsif ($genotype[2] >= $min_dp){
                        	                                print "\t$ref$ref";
                                	                }else{
                                        	                print "\tNN";
                                        	        }

                                       	 	}else{
                                                        print "\tNN";
                                                }
                                        }
                                }
				if ($print_ref){
					print "\t$ref$ref";
				}
				print "\n";
			}
			else{
				if ($mq eq "NA"){print STDERR "\n$chrome\t$pos\tWEIRD mq skipped";next;}
                                if ($qual eq "NA"){print STDERR "\n$chrome\t$pos\tWEIRD qual";}
	                        if(($qual < $min_qual) or ($mq < $min_mq)){
#	                                print STDERR "$pos\tSkipped because of qual or mq\n";
					next;
        	                }
				print "$chrome\t$pos";
				foreach(@fields){
					my $fourbasename = "$_";
					my $allele0 = &GT($ref,$alt,$fourbasename);
					print "\t$allele0";


				}
				if ($print_ref){
					print "\t$ref$ref";
				}
				print "\n";
			}
		}
	}
}
sub GT{
	my $ref =shift;
	my $alt =shift;
	my $alt2;
	my $alt3;
   	#if there are two alternate alleles:
	if($alt=~m/,/){
		my @alts= split /,/, $alt;
	        my $alts_length = @alts;
		$alt=$alts[0];
		$alt2=$alts[1];
       		if ($alts_length == 3){
           		$alt3=$alts[2];
	        }
	}
	my $fourbasename = shift;
	
	if ($fourbasename eq "./."){
        	return 'NN';
    	}
	my @gtdata = split /:/, $fourbasename;

	if ($gtdata[0] eq "./."){
		return 'NN';
	}  
    
    
    #genotype data (PL) is now in the 5th array entry:
	my @genoP;
	if ($#gtdata eq "4"){
		@genoP = split /,/, $gtdata[4];
	}elsif ($#gtdata eq "6"){
		@genoP = split /,/, $gtdata[6];
	}
    #gq is now 4th:
	my $gq = $gtdata[3];
    #depth is 3rd:
  	my $dp = $gtdata[2];
	if ($gq eq '.' || $dp eq '.' ){
		return 'NN';
	}	
	elsif ($gq <= $min_gt_qual || $dp < $min_dp || $dp > $max_dp  ){
		return 'NN';	
	}else{
		my $i =1;
		my $n_match =0;
		my %types = ( 1 => '00', 2 => '01', 3 => '11', 4 => '02', 5 => '12', 6 => '22', 7 => '03', 8 => '13', 9 => '23', 10 => '33');
	
		my $genotype = 'NN';
		#go through each genotype liklihood - they are in order ref/ref, ref/alt1, alt1/alt1, ref/alt2, alt1/alt2, alt2/alt2 
		foreach(@genoP){
			my $prob = "$_";
			#PL is L(data given that the true genotype is X/Y) so, bigger is LESS confident
			if($prob==0){
				++$n_match;
				#Get the genotype based on the position of the 0 
				if(exists $types{$i}){
					$genotype = $types{$i};
				}
				else{
					$genotype = 'XX';	
				}
			}
			++$i;
		
		}
	# 00,01,11,02,12,22
	#P(D|CC)=10^{-0.7}, P(D|CA)=1, P(D|AA)=10^{-3.7}, P(D|CG)=10^{-1.3}, P(D|AG)=1e-4 and P(D|GG)=10^{-4.9}.
		#my $genotypequal = $gtdata[2];
		#if($genotypequal<$min_gt_qual){
		#if more than one 0 than return an N
		if($n_match!=1){
			return 'NN';
		}
		else{
			$genotype =~ s/0/$ref/eg;
			$genotype =~ s/1/$alt/eg;
			$genotype =~ s/2/$alt2/eg;
            		$genotype =~ s/3/$alt3/eg;
			$genotype =~ s/\///;
			#if ($genotype eq 'AA'){
			#	$genotype = "A";	
			#}
			#elsif ($genotype eq 'TT'){
			#	$genotype = "T";
			#}
			#elsif ($genotype eq 'CC'){
			#	$genotype = "C";
			#}
			#elsif ($genotype eq 'GG'){
			#	$genotype = "G";
			#}
			#elsif (($genotype eq 'AC') || ($genotype eq 'CA')){
			#	$genotype = "M";
			#}
			#elsif (($genotype eq 'AG') || ($genotype eq 'GA')){
			#	$genotype = "R";
			#}
			#elsif (($genotype eq 'AT') || ($genotype eq 'TA')){
			#	$genotype = "W";
			#}
			#elsif (($genotype eq 'CG') || ($genotype eq 'GC')){
			#	$genotype = "S";
			#}
			#elsif (($genotype eq 'CT') || ($genotype eq 'TC')){
			#	$genotype = "Y";
			#}
			#elsif (($genotype eq 'GT') || ($genotype eq 'TG')){
			#	$genotype = "K";
			#}
			#else{
			#	$genotype = "N";	
			#}
			if ($genotype eq 'N'){
				$genotype = "NN"
			}
			return $genotype;
		}

	}
}
