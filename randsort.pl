#!/usr/bin/env perl

use strict;
use warnings;
use List::Util 'shuffle';

my @lines = ();
my $bufsize = 512;
while(<STDIN>) {
   push @lines, $_;
   if (@lines == $bufsize) {
      print shuffle(@lines);
      undef @lines;
   }
}
print shuffle(@lines);

