#!/bin/perl


sub Usage($$$) {
	my ($fh, $message, $die) = @_;
	print $fh "
getsymbols_gnu.pl <map> <listings files...>
	";

	if ($die) {
		if ($message) {
			die "$message";
		} else {
			die;
		}
	} else {
		if ($message) {
			print $fh $message;
			print $fh "\n";
		}
	}

}



my $fn_map = shift or Usage(STDERR, "Too few arguments", 1);

open(my $fh_m, "<", $fn_map) or die "Cannot open file \"$fn_map\" : $!";

my %areas = ();

while (<$fh_m>) {
	my $l = $_;
	$l =~ s/[\r\n\s]*$//;
	if ($l =~ /s*(\.\w+)\s*(0x[0-9A-F]+)\s*0x[0-9A-F]+\s*(.+?)(\s|$)/i) {
		my ($name, $base, $file) = ($1, $2, $3);
		$file =~ s/.*?\/([^\/]+)\.o$/$1/;
		$areas{"$file:$name"} = $base;
	}
}

close $fh_m;

while (my $fn = shift) {
	open (my $fh_s, "<", $fn) or die "Cannot open \"$fn\" : $!";

	my $sym = 0;
	while (<$fh_s>) {
		if ($_ =~ /^DEFINED SYMBOLS/) {
			last;
		}
	}

	while (<$fh_s>) {
		if ($_ =~ /^\s+([^:]+):\d+\s+(\.\w+):([0-9A-F]+)\s(\w+)/i) {

			my ($file, $area, $offs, $sym) = ($1, $2, $3, $4);
			$file =~ s/^(.*?)(.s|.asm)\s*$/\1/i;

			my $area = $areas{"$file:$area"};

			my $addr = hex($area) + hex($offs);

			printf "DEF %s 0x%08X\n", $sym, $addr;
		} elsif ($_ =~ /^(\s+([^:]+):\d+)?\s+\*ABS\*:([0-9A-F]+)\s(\w+)/i) {
			my ($sym, $addr) = ($4, $3);
			$addr = hex($addr);
			printf "DEF %s 0x%08X\n", $sym, $addr;
		}
	}



	close $fh_s;
}

