use warnings;
use strict;

my $in = $ARGV[0];
my $out = $ARGV[1];

my %h;
my %samples;
my @samples;
my @loc;

open IN, "$in";
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($a[0]=~/^contig/){
                foreach my $i (2..$#a){
                        $samples{$i}=$a[$i];
                        push(@samples,$a[$i]);
                }
        }else{
                my $loc = "$a[1]\t$a[2]";
		push(@loc, $loc);
                foreach my $i (2..$#a){
			my @tmp = split('',$a[$i]);        
	                $h{$samples{$i}}{$loc}=$tmp[0];
	        }
	}
}
close IN;
open OUT, ">$out";
foreach my $s (@samples){
	print OUT ">$s\n";
	foreach my $loc (@loc){
		print OUT "$h{$s}{$loc}";
	}
	print OUT "\n";
}

