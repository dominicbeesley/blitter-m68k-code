#!/bin/perl

my %regs = ();


my $lineno = 1;
while (<>) {
	my $l = $_;
	chomp $l;
	$l =~ s/[\r\n\s]+$//;

	while ($l =~ /\b((?:A|D)[0-7]\b)/gi) {
		my $r = uc($1);
		if (exists($regs{$r})) {
			$regs{$r}->{count}++;
		} else {
			$regs{$r} = { count => 1, line => $lineno};
		}
	}
	$lineno++;
}

foreach my $k (sort(keys(%regs))) {
	print "$k = $regs{$k}->{count} @ $regs{$k}->{line}\n";
}