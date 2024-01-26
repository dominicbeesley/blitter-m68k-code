#!/bin/perl

my %syms=();

while (<>) {
	my $l = $_;
	chomp $l;

#	if ($l =~ /^\s*(\w+):.*?,\s*value\s+(0x[0-9A-F]+)/i)
#	{
#		my $addr=$2;
#		my $sym=$1;
	if ($l =~ /^\s*(0x[0-9A-F]+)\s+(\w+):/i) {
		my $addr=hex($1) & 0xFFFFFFFF;
		my $sym=$2;
		$syms{$sym} = { sym=>$sym, addr=>$addr };
	}
}

foreach $k (sort keys %syms) {
	my $x = $syms{$k};
	printf "DEF %-40s 0x%08X\n", $x->{sym}, $x->{addr};
}