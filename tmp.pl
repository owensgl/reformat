#!/bin/perl
use warnings;
use strict;

my $in = $ARGV[0];

sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}

my $bit = dec2bin($in);
print "$bit\n";
