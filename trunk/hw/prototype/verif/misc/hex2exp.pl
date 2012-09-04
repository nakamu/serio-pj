#!/usr/bin/env perl

while(<>) {
	if(/^([0-9a-fA-F]{6})/) {
		my $hex = $1;
		my $red   = hex("0x". substr($hex, 0, 2));
		my $green = hex("0x". substr($hex, 2, 2));
		my $blue  = hex("0x". substr($hex, 4, 2));
		my $p1 = ($red & 0xF8)|($green >> 5);
		my $p2 = (($green << 3) & 0xE0) | ($blue >> 3);
		printf "# %02x%02x%02x\n", $red, $green, $blue;
		printf "0x%02x\n", $p1;
		printf "0x%02x\n", $p2;
	}
}


