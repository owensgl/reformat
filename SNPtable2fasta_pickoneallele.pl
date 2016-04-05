use warnings;
use strict;

my %h;
my %samples;
my @samples;
my @loc;

while (<STDIN>){
	chomp;
	my @a = split (/\t/,$_);
  	if ($. == 1){
                foreach my $i (2..$#a){
                        $samples{$i}=$a[$i];
                        push(@samples,$a[$i]);
                }
        }else{
                my $loc = "$a[1]\t$a[2]";
		push(@loc, $loc);
                foreach my $i (2..$#a){
			my $rand = int(rand(2));
			my @bases = split(//,$a[$i]);
		        $h{$samples{$i}}{$loc}=$bases[$rand];
	        }
	}
}
foreach my $s (@samples){
	print ">$s\n";
	foreach my $loc (@loc){
		print "$h{$s}{$loc}";
	}
	print "\n";
}

