#!/usr/bin/env perl

my $print_percent = $ARGV[0];

while (<STDIN>) {
    if (/^#/) {
        print;
    } else {
      my $rand = rand(1);
        if ($rand < $print_percent) {
            print;
        }
    }

}
