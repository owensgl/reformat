use warnings;
use strict;

my $in = $ARGV[0];
my $out = $ARGV[1];
my %x;

my %h;
my %samples;
my @samples;
my @loc;

open IN, "$in";
while (<IN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1){
                foreach my $i (5..$#a){
                        $samples{$i}=$a[$i];
                        push(@samples,$a[$i]);
                }
        }else{
                my $loc = "$a[1]\t$a[2]";
		push(@loc, $loc);
                foreach my $i (5..$#a){
			my @bases = split(/\//,$a[$i]);
			unless ($bases[1]){
				$h{$samples{$i}}{$loc}=$a[$i];
			}else{			
				my $rand = int(rand(2));
				$h{$samples{$i}}{$loc}=$bases[$rand];
			}
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

