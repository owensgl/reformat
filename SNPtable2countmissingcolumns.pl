#!/usr/bin/perl
use warnings;
use strict;
my $real_value;
while(<STDIN>){
    my @a = split(/\t/,$_);
    if ($. == 1){
        $real_value = $#a;
    }
    my $current_dif = $real_value - $#a;
    print "$current_dif\n";
}
