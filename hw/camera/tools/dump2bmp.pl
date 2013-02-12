#!/usr/bin/env perl

use strict;
use warnings;

my @pixels = ();

while(<>){
	chomp;
	s/\s+/,/g;
	my @rgb565 = split(/,/, $_);
	for(my $i = 0; $i < @rgb565-1; $i=$i+2) {
		my $byte1 = hex('0x' . $rgb565[$i]);
		my $byte2 = hex('0x' . $rgb565[$i+1]);
		my $red   = ($byte1 & 0xf8);
		my $green = (($byte1 & 0x07) << 5) | (($byte2 & 0xe0) >> 3);
		my $blue  = ($byte2 & 0x1f) << 3;
		push(@pixels, $blue);
		push(@pixels, $green);
		push(@pixels, $red);
		push(@pixels, 0x00);
	}
}

open(BMP, ">out.bmp") or die "Cannot write out.bmp\n";
binmode(BMP);
# bitmap file header
print BMP pack("C2", 0x42, 0x4d); # bfType
print BMP pack("I1", 122854);     # bfSize
print BMP pack("S2", 0, 0);       # bfReserved
print BMP pack("I1", 54);          # bfOffset
# bitmap info header
print BMP pack("I1", 40);       # biSize
print BMP pack("I1", 640);      # biWidth
print BMP pack("I1", 480);      # biHeight
print BMP pack("S1", 1);        # biPlanes
print BMP pack("S1", 32);       # biBitCount
print BMP pack("I1", 0);        # biCompression
print BMP pack("I1", 0);        # biSizeImage
print BMP pack("I1", 0);        # biXPixPerMeter
print BMP pack("I1", 0);        # biYPixPerMeter
print BMP pack("I1", 0);        # biClrUsed
print BMP pack("I1", 0);        # biClrImportant
# pixel data
print BMP pack("C*", @pixels);
close(BMP);
