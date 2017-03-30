while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $pos = $a[1];
  my $ref = $a[2];
  my $depth = $a[3];
  my $info = $a[4];
  if ($depth ne 2){next;}
  if (length($info) > 2){next;}
  my @bases = split(//,$info);
  my $dif = 0;
  my $alt;
  foreach my $i (0..1){
    if (($bases[$i] ne ',') and ($bases[$i] ne '.')){
      $dif++;
      $alt = uc($bases[$i]);
    }
  }
  if ($dif ne 1){next;}
  print "$chr\t$pos\t$ref\t$alt\n";
}
