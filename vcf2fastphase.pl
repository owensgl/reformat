#! /usr/bin/perl
use warnings;
use strict;
#Originally from Laurie Stevison
#Modified by Greg Owens
#program converts vcf file to fastPHASE input format. Outputs one per chromosome. It only outputs bialleleic sites, it also requires a depth of 5 for a genotype to be output (otherwise it is unknown). It also removes indels and ignores scaffold contigs, and invariant sites. 

my $vcf = $ARGV[0];
my $output = $ARGV[1];

unless ($#ARGV==1) {
    print STDERR "Please provide name of input vcf file, filename for output\n\n";
    die;
} #end unless

open(VCF, $vcf);

my @positions = ();
my @names = ();
my $sample_size;
my %genotypes = ();
my $Pline = "FALSE";
print STDERR "Reading in VCF file...\n";

my $currentchrom;
my %samplehash;
my $min_depth = 1; #minimum number of reads to call a site.
my $n_inds;
my $n_snps;
my $snpcount;
my @site_list;
my @samplenames;
my %snphash;
while(<VCF>) {
	chomp;
	if ($_=~/\#\#/) {
		next;
	} elsif ($_=~/\#/) {
		my @a = split(/\s+/, $_);
		foreach my $i (9..$#a){
			$samplehash{$i} = $a[$i];
			push (@samplenames, $a[$i]);
			$n_inds = ($#a - 8);
		}
	}else{
		my @a = split(/\s+/, $_);
		unless($currentchrom){
			$currentchrom = $a[0];
		}
		if ($a[0] ne "$currentchrom"){
			print STDERR "Printing out $currentchrom...\n";
			$n_snps = $snpcount;
			open(OUTPUT, ">$output.$currentchrom.fphase.in");
			open(LIST, ">$output.$currentchrom.locilist.txt");
			print OUTPUT "$n_inds\n$n_snps\n";
			if ($Pline eq "TRUE"){ 
				print OUTPUT "P";
				foreach my $site (@site_list){
					print OUTPUT"\t$site";
					print LIST "$site\n";
				}
				print OUTPUT "\n";
			}
			foreach my $samplename(@samplenames){
				print OUTPUT "# $samplename\n";
				foreach my $i (0..1){
					foreach my $site (@site_list){
						my @tmp = split (//, $snphash{$site}{$samplename});
						print OUTPUT "$tmp[$i]";
					}print OUTPUT "\n";
				}
			}
			$currentchrom = $a[0];
			%snphash = ();
			@site_list = ();
			$snpcount = 0;
		}
		if ($a[0] =~/scaffold/){
			exit;
		}
		if ((length($a[3]) ne "1") or (length($a[4]) ne "1")){
			goto SKIP;
		}
		if ($a[4] eq "."){
			goto SKIP;
		}
		$snpcount++;
                push (@site_list, $a[1]);
		foreach my $i (9..$#a){
			my @ind_data = split (/:/,$a[$i]);
			if ($ind_data[0] eq "./."){
		    		$snphash{$a[1]}{$samplehash{$i}} = "??";
			}else{
				my $depth= $ind_data[2];
				if ($depth eq "."){
					$snphash{$a[1]}{$samplehash{$i}} = "??";
				}elsif ($depth > $min_depth){
					$ind_data[0] =~ s/\///;
					$snphash{$a[1]}{$samplehash{$i}} = $ind_data[0];
				}else{
					$snphash{$a[1]}{$samplehash{$i}} = "??";
				}
			}
		}
	}
	SKIP:
}
                        print STDERR "Printing out $currentchrom...\n";
                        $n_snps = $snpcount;
                        open(OUTPUT, ">$output.$currentchrom.fphase.in");
                        open(LIST, ">$output.$currentchrom.locilist.txt");
                        print OUTPUT "$n_inds\n$n_snps\n";
                        if ($Pline eq "TRUE"){
                                print OUTPUT "P";
                                foreach my $site (@site_list){
                                        print OUTPUT"\t$site";
                                        print LIST "$site\n";
                                }
                                print OUTPUT "\n";
                        }
                        foreach my $samplename(@samplenames){
                                print OUTPUT "# $samplename\n";
                                foreach my $i (0..1){
                                        foreach my $site (@site_list){
                                                my @tmp = split (//, $snphash{$site}{$samplename});
                                                print OUTPUT "$tmp[$i]";
                                        }print OUTPUT "\n";
                                }
                        }


