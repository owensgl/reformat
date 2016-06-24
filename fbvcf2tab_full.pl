#!/bin/perl
#This script takes a freebayes vcf and outputs a tab separated cold genotype file
#It only outputs SNPs and invariant sites, no indels or complex
#It requires a minimum genotype depth to call a variant.
#It does a QUAL filter for variable sites

my $min_dp = 5;
my $min_qual = 20;
my %names;
while(<STDIN>){
    chomp;
    my $line = $_;
    if ($line=~m/^##/){
        next;
    }elsif ($line=~m/^#/){
        print "chr\tpos";
        my @a = split(/\t/,$line);
        foreach my $i (9..$#a){
            print "\t$a[$i]";
            $name{$i} = $a[$i];
        }
    }else{
        my %data;
        my @a = split(/\t/,$line);
        my $chr = $a[0];
        my $pos = $a[1];
        my $ref = $a[3];
        my @alt = split(/,/,$a[4]);
        my $qual = $a[5];
        my $info = $a[7];
        my @fields = split(/;/,$info);
        my $type = $fields[($#fields-1)];
        #Filter for variant sites;
        if ($alt[0] ne "."){
            if ($qual < $min_qual){
                next;
            }
            if ($type ne "TYPE=snp"){
                next;
            }
        }
        #Grab genotype info
        foreach my $i (9..$#a){
            if ($a[$i] eq "."){
                next;
            }
            my @geno_info = split(/:/,$a[$i]);
            my $depth = $geno_info[1];
            my $genotype = $geno_info[0];
            if ($depth >= $min_dp){
                $data{$i} = $genotype;
            }
        }
	#Print out genotypes
        print "\n$chr\t$pos";
        foreach my $i (9..$#a){
            if ($data{$i}){
                my @alleles = split('/',$data{$i});
                print "\t";
                foreach my $n (0..1){
                    if ($alleles[$n] eq "0"){
                        print "$ref";
                    }else{
                        print "$alt[($alleles[$n] - 1)]";
                    }
                }
            }else{
                print "\tNN";
            }
        }
    }
}
