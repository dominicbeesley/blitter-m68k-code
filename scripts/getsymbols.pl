#!/bin/perl

my @syms=();

while (<>) {
	my $l = $_;
	chomp $l;

	if ($l =~ /^\s*(\w+):.*?,\s*value\s+(0x[0-9A-F]+)/i)
	{
		my $addr=$2;
		my $sym=$1;
		push @syms,{ sym=>$sym, addr=>$addr };
	}
}

foreach $x (sort({ hex($a->{addr}) <=> hex($b->{addr}) } @syms)) {
	print "DEF $x->{sym} $x->{addr}\n";
}