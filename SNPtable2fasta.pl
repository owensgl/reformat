use warnings;
use strict;

my %x;
$x{"AG"} = "R";
$x{"GA"} = "R";
$x{"AA"} = "A";
$x{"TT"} = "T";
$x{"CC"} = "C";
$x{"GG"} = "G";
$x{"CT"} = "Y";
$x{"TC"} = "Y";
$x{"GC"} = "S";
$x{"CG"} = "S";
$x{"AT"} = "W";
$x{"TA"} = "W";
$x{"GT"} = "K";
$x{"TG"} = "K";
$x{"AC"} = "M";
$x{"CA"} = "M";
$x{"NN"} = "N";

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
	                $h{$samples{$i}}{$loc}=$x{$a[$i]};
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

