#!/bin/perl

#NOTE: if removes directory information from .o/.s filenames and may get
#confused if same symbols in multiple files with same name!

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
	if ($l =~ /s*(\.(?:\.|\w)+)\s*(0x[0-9A-F]+)\s*0x[0-9A-F]+\s*(.+?)(\s|$)/i) {
		my ($name, $base, $file) = ($1, $2, $3);
		$areas{"$file:$name"} = $base;
	} elsif ($l =~ /^\s*(0x[0-9A-F]+)\s*(\w+?)\s*$/i) {
		my ($base, $symbol) = ($1, $2);
		$areas{"*COM*:$symbol"} = $base;
	}
}


print "; =====\n; AREAS\n; =====\n";
for my $k (sort keys %areas) {
	printf "; %08X <= %s\n", $areas{$k}, $k;
}

print "; \n";

close $fh_m;

my $input_file="";
my $output_file="";

while (my $fn = shift) {
	open (my $fh_s, "<", $fn) or die "Cannot open \"$fn\" : $!";

	my $sym = 0;
	while (<$fh_s>) {
		my $l = $_;
		$l =~ s/[\s\r\n]+$//;

		if ($l =~ /^DEFINED SYMBOLS/) {
			last;
		} elsif ($l =~ /^\s*input file\s*:\s*(.+?)\s*$/) {			
			$input_file = $1;
		} elsif ($l =~ /^\s*output file\s*:\s*(.+?)\s*$/) {
			$output_file = $1;
		} 

	}

	while (<$fh_s>) {
		my $l = $_;
		$l =~ s/[\s\r\n]+$//;
		if ($l =~ /^\s+([^:]+):\d+\s+(\.(?:\.|\w)+):([0-9A-F]+)\s(\w+)/i) {

			my ($file, $area, $offs, $sym) = ($1, $2, $3, $4);

			if ($input_file && $output_file) {
				$file =~ s/\Q$input_file/$output_file/;
			}

			my $base = $areas{"$file:$area"};

			if (!$base) {
				die "Cannot find area $file:$area"
			}

			my $addr = (hex($base) + hex($offs)) & 0xFFFFFFFF;

			printf "DEF %s 0x%08X\n", $sym, $addr;
		} elsif ($l =~ /^(\s+([^:]+):\d+)?\s+\*ABS\*:([0-9A-F]+)\s(\w+)/i) {
			my ($sym, $addr) = ($4, $3);
			$addr = hex($addr) & 0xFFFFFFFF;
			printf "DEF %s 0x%08X\n", $sym, $addr;
		} 

# output all common symbols later
##		elsif ($l =~ /^(\s+([^:]+):\d+)?\s+\*COM\*:([0-9A-F]+)\s(\w+)/i) {
##			my ($sym) = ($4);
##
##			my $addr = $areas{"*COM*:$sym"};
##
##			if (!$addr) {
##				die "Cannot find common symbol $sym";
##			}
##
##
##			$addr = hex($addr) & 0xFFFFFFFF;
##			printf "DEF %s 0x%08X\n", $sym, $addr;
##		}
	}

	for my $k (sort map { $_ =~ /^\*COM\*:/ ? ($_) : () } keys(%areas))
	{
		$k =~ /:(.*)/;
		my $sym = $1;
		$addr = hex($areas{$k}) & 0xFFFFFFFF;

		printf "DEF %s %08X\n", $sym, $addr;
	}


	close $fh_s;
}

