#!/bin/perl

my %syms=();

while (<>) {
	my $l = $_;
	chomp $l;

	if ($l =~ /^\s*(\w+):.*?,\s*value\s+(0x[0-9A-F]+)/i)
	{
		my $addr=$2;
		my $sym=$1;
		push @syms,{ sym=>$sym, addr=>$addr };
	} 
	elsif ($l =~ /^\s*0x([0-9A-F]+)\s+(\w+):/i)
	{
		my $addr=$1;

		if ($addr =~ /^f{8}(.){8}/) {
			$addr = $1;
		}

		my $sym=$2;
		$syms{$sym} = { sym=>$sym, addr=>$addr };
	}
}

foreach $k (sort({ hex($a->{addr}) <=> hex($b->{addr}) } keys(%syms))) {
	my $x = $syms{$k};
	print "DEF $x->{sym} $x->{addr}\n";
}