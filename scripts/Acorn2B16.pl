#!/bin/perl


sub Usage($$$) {
	my ($fh, $message, $die) = @_;
	print $fh "
Acorn2B16.pl <input> <output>

  Converts an Acorn 8-bit BASIC file to the 16-bit version used on the Elk Homebrew BASIC:
  - All lines are word aligned
  - Line lengths are 16 bit
  - padding byte at end of line (after CR) for odd-lengthed lines

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


my %b16keys = (
	"AUTO" => 0x80,
	"BPUT#" => 0x81,
	"COLOUR" => 0x82,
	"CLEAR" => 0x83,
	"CLOSE#" => 0x84,
	"CLS" => 0x85,
	"CLG" => 0x86,
	"CALL" => 0x87,
	"CHAIN" => 0x88,
	"DELETE" => 0x89,
	"DRAW" => 0x8A,
	"DATA" => 0x8B,
	"DEF" => 0x8C,
	"DIM" => 0x8D,
	"ENVELOPE" => 0x8E,
	"ENDPROC" => 0x8F,
	"END" => 0x90,
	"ELSE" => 0x91,
	"ERROR" => 0x92,
	"FOR" => 0x93,
	"GOTO" => 0x94,
	"GOSUB" => 0x95,
	"GCOL" => 0x96,
	"INPUT" => 0x97,
	"IF" => 0x98,
	"LIST" => 0x99,
	"LOAD" => 0x9A,
	"LOCAL" => 0x9B,
	"LET" => 0x9C,
	"LINE" => 0x9D,
	"MODE" => 0x9E,
	"MOVE" => 0x9F,
	"NEXT" => 0xA0,
	"NEW" => 0xA1,
	"OLD" => 0xA2,
	"ON" => 0xA3,
	"OFF" => 0xA4,
	"OSCLI" => 0xA5,
	"PRINT" => 0xA6,
	"PROC" => 0xA7,
	"PLOT" => 0xA8,
	"REPEAT" => 0xA9,
	"RETURN" => 0xAA,
	"RESTORE" => 0xAB,
	"REPORT" => 0xAC,
	"REM" => 0xAD,
	"READ" => 0xAE,
	"RUN" => 0xAF,
	"RENUMBER" => 0xB0,
	"STEP" => 0xB1,
	"SAVE" => 0xB2,
	"STOP" => 0xB3,
	"SOUND" => 0xB4,
	"SPC" => 0xB5,
	"TRACE" => 0xB6,
	"THEN" => 0xB7,
	"TAB(" => 0xB8,
	"UNTIL" => 0xB9,
	"VDU" => 0xBA,
	"WIDTH" => 0xBB,
	"AND" => 0xBC,
	"OR" => 0xBD,
	"EOR" => 0xBE,
	"DIV" => 0xBF,
	"MOD" => 0xC0,
	"<=" => 0xC1,
	"<>" => 0xC2,
	">=" => 0xC3,
	"PTR" => 0xC4,
	"PAGE" => 0xC5,
	"TOP" => 0xC6,
	"LOMEM" => 0xC7,
	"HIMEM" => 0xC8,
	"TIME" => 0xC9,
	"CHR\$" => 0xCA,
	"GET\$" => 0xCB,
	"INKEY\$" => 0xCC,
	"LEFT\$(" => 0xCD,
	"MID\$(" => 0xCE,
	"RIGHT\$(" => 0xCF,
	"STR\$" => 0xD0,
	"STRING\$(" => 0xD1,
	"INSTR(" => 0xD2,
	"VAL" => 0xD3,
	"ASC" => 0xD4,
	"LEN" => 0xD5,
	"GET" => 0xD6,
	"INKEY" => 0xD7,
	"ADVAL" => 0xD8,
	"POS" => 0xD9,
	"VPOS" => 0xDA,
	"COUNT" => 0xDB,
	"POINT(" => 0xDC,
	"ERR" => 0xDD,
	"ERL" => 0xDE,
	"OPENIN" => 0xDF,
	"OPENOUT" => 0xE0,
	"OPENUP" => 0xE1,
	"EXT" => 0xE2,
	"BGET#" => 0xE3,
	"EOF" => 0xE4,
	"TRUE" => 0xE5,
	"FALSE" => 0xE6,
	"ABS" => 0xE7,
	"ACS" => 0xE8,
	"ASN" => 0xE9,
	"ATN" => 0xEA,
	"COS" => 0xEB,
	"DEG" => 0xEC,
	"EVAL" => 0xED,
	"EXP" => 0xEE,
	"FN" => 0xEF,
	"INT" => 0xF0,
	"LN" => 0xF1,
	"LOG" => 0xF2,
	"NOT" => 0xF3,
	"PI" => 0xF4,
	"RAD" => 0xF5,
	"RND" => 0xF6,
	"SGN" => 0xF7,
	"SIN" => 0xF8,
	"SQR" => 0xF9,
	"TAN" => 0xFA,
	"USR" => 0xFB,
	"TO" => 0xFC
);


my %bbctoks = (
	0x80 => "AND" ,
	0x94 => "ABS" ,
	0x95 => "ACS" ,
	0x96 => "ADVAL" ,
	0x97 => "ASC" ,
	0x98 => "ASN" ,
	0x99 => "ATN" ,
	0xC6 => "AUTO" ,
	0x9A => "BGET" ,
	0xD5 => "BPUT" ,
	0xFB => "COLOUR" ,
	0xD6 => "CALL" ,
	0xD7 => "CHAIN" ,
	0xBD => "CHR\$" ,
	0xD8 => "CLEAR" ,
	0xD9 => "CLOSE" ,
	0xDA => "CLG" ,
	0xDB => "CLS" ,
	0x9B => "COS" ,
	0x9C => "COUNT" ,
	0xFB => "COLOR" ,
	0xDC => "DATA" ,
	0x9D => "DEG" ,
	0xDD => "DEF" ,
	0xC7 => "DELETE" ,
	0x81 => "DIV" ,
	0xDE => "DIM" ,
	0xDF => "DRAW" ,
	0xE1 => "ENDPROC" ,
	0xE0 => "END" ,
	0xE2 => "ENVELOPE" ,
	0x8B => "ELSE" ,
	0xA0 => "EVAL" ,
	0x9E => "ERL" ,
	0x85 => "ERROR" ,
	0xC5 => "EOF" ,
	0x82 => "EOR" ,
	0x9F => "ERR" ,
	0xA1 => "EXP" ,
	0xA2 => "EXT" ,
	0xCE => "EDIT" ,
	0xE3 => "FOR" ,
	0xA3 => "FALSE" ,
	0xA4 => "FN" ,
	0xE5 => "GOTO" ,
	0xBE => "GET\$" ,
	0xA5 => "GET" ,
	0xE4 => "GOSUB" ,
	0xE6 => "GCOL" ,
	0x93 => "HIMEM" ,
	0xE8 => "INPUT" ,
	0xE7 => "IF" ,
	0xBF => "INKEY\$" ,
	0xA6 => "INKEY" ,
	0xA8 => "INT" ,
	0xA7 => "INSTR(" ,
	0xC9 => "LIST" ,
	0x86 => "LINE" ,
	0xC8 => "LOAD" ,
	0x92 => "LOMEM" ,
	0xEA => "LOCAL" ,
	0xC0 => "LEFT\$(" ,
	0xA9 => "LEN" ,
	0xE9 => "LET" ,
	0xAB => "LOG" ,
	0xAA => "LN" ,
	0xC1 => "MID\$(" ,
	0xEB => "MODE" ,
	0x83 => "MOD" ,
	0xEC => "MOVE" ,
	0xED => "NEXT" ,
	0xCA => "NEW" ,
	0xAC => "NOT" ,
	0xCB => "OLD" ,
	0xEE => "ON" ,
	0x87 => "OFF" ,
	0x84 => "OR" ,
	0x8E => "OPENIN" ,
	0xAE => "OPENOUT" ,
	0xAD => "OPENUP" ,
	0xFF => "OSCLI" ,
	0xF1 => "PRINT" ,
	0x90 => "PAGE" ,
	0x8F => "PTR" ,
	0xAF => "PI" ,
	0xF0 => "PLOT" ,
	0xB0 => "POINT(" ,
	0xF2 => "PROC" ,
	0xB1 => "POS" ,
	0xF8 => "RETURN" ,
	0xF5 => "REPEAT" ,
	0xF6 => "REPORT" ,
	0xF3 => "READ" ,
	0xF4 => "REM" ,
	0xF9 => "RUN" ,
	0xB2 => "RAD" ,
	0xF7 => "RESTORE" ,
	0xC2 => "RIGHT\$(" ,
	0xB3 => "RND" ,
	0xCC => "RENUMBER" ,
	0x88 => "STEP" ,
	0xCD => "SAVE" ,
	0xB4 => "SGN" ,
	0xB5 => "SIN" ,
	0xB6 => "SQR" ,
	0x89 => "SPC" ,
	0xC3 => "STR\$" ,
	0xC4 => "STRING\$(" ,
	0xD4 => "SOUND" ,
	0xFA => "STOP" ,
	0xB7 => "TAN" ,
	0x8C => "THEN" ,
	0xB8 => "TO" ,
	0x8A => "TAB(" ,
	0xFC => "TRACE" ,
	0x91 => "TIME" ,
	0xB9 => "TRUE" ,
	0xFD => "UNTIL" ,
	0xBA => "USR" ,
	0xEF => "VDU" ,
	0xBB => "VAL" ,
	0xBC => "VPOS" ,
	0xFE => "WIDTH" ,
	0xD0 => "PAGE" ,
	0xCF => "PTR" ,
	0xD1 => "TIME" ,
	0xD2 => "LOMEM" ,
	0xD3 => "HIMEM"
);


#print join " ", (map { sprintf "%02X", $_ } keys %bbctoks);


my $fn_in = shift or Usage(STDERR, "Too few arguments", 1);

open(my $fh_in, "<:raw:", $fn_in) or die "Cannot open file \"$fn_in\" : $!";

my $fn_out = shift or Usage(STDERR, "Too few arguments", 1);

open(my $fh_out, ">:raw:", $fn_out) or die "Cannot open file \"$fn_out\" : $!";


my $buf;
my $lineno = 1;
my $lastline = -1;

while (1) {
	read($fh_in, $buf, 1) == 1 or die "Unexpected end of file on line $lineno (after $lastline)";
	my ($ls) = unpack("C", $buf);
	$ls == 0x0D or die sprintf("Bad line start character %02X on line $lineno (after $lastline)", $ls);

	my $x = read($fh_in, $buf, 3);

	if ($x == 1 && substr($buf,0,1) == chr(255)) {
		last;
	}
	$x == 3 or die "Unexpected end of file on line $lineno (after $lastline) $x";

	my ($ln, $ll) = unpack("nC", $buf);

	my $datlen = $ll - 4;

	$ll >= 3 or die "Bad line length on line $lineno ($ln)";

	read($fh_in, $buf, $datlen) == $datlen or die "Unexpected end of file on line $lineno ($ln)";

	convert16($buf, $newbuf) or die "Error converting binary at $lineno ($ln)";

	my $newdatlen = length($newbuf);
	my $ll16 = 5+$newdatlen;
	if ($ll16 & 0x01) {
		$ll16++;
	}

	print $fh_out pack("nn", $ll16, $ln);



	print $fh_out $newbuf;
	print $fh_out chr(0x0D);
	if (!($newdatlen & 0x01)) {
		print $fh_out ".";
	}

	$lastline = $ln;
	$lineno++;
}

	print $fh_out pack("n", 0);

close $fh_in;
close $fh_out;



sub convert16($$) {
	my ($buf) = @_;
	my $ret = "";	
	my $kept = "";

	use constant {
		STATE_NORMAL => 0,
		STATE_LITERAL => 1
	};

	my $state = 0;

	while (length($buf)) {
		my $c = substr($buf, 0, 1);
		#printf "C=>%02X [%d]", ord($c), $state;
		$buf = substr($buf, 1);

		if ($state == STATE_NORMAL) {
			if (ord($c) & 0x80) {
				$ret .= checkfortokens($kept);
				$kept = "";
				if (ord($c) == 0x8D) {
					my @ll = unpack("C*", substr($buf, 0, 3));
					$buf = substr($buf, 3);
					if (scalar(@ll) != 3)
					{
						printf STDERR "Truncated tokenized line number";
						return 0;
					}

					$ret .= chr(0xFF);
					if (length($ret) & 0x01)
					{
						$ret .= chr(0);
					} 

					$ret .= pack("nN", 
						(((@ll[0] << 2) & 0xC0) ^ @ll[1]) |
						(((@ll[0] << 4) ^ @ll[2]) << 8)
						, 0
						);


				} else {
					my $key = $bbctoks{ord($c)};
					if (!$key) {
						printf STDERR "Cannot find a BBC keyword for token %02X\n", ord($c);
						return 0;
					}
					my $tok16 = $b16keys{$key};
					if (!$tok16)
					{	
						printf STDERR "Cannot find a b16 keyword \"%s\" = %02X\n", $key, ord($c); 
					}
					#printf "%02X=>%s=>%02X\n", ord($c), $key, $tok16;
					$ret .= chr($tok16);
					if (ord($c) == 0xF4) {
						$ret .= $buf;
						last;
					} elsif ($key eq "PROC" || $key eq "FN") {
						$ret .= chr(255);
						if (length($ret) & 0x01) {
							$ret .= ".";
						}
						$ret .= chr(0) x 6;
					}
				}

			} elsif ($c eq "\"") {
				$ret .= checkfortokens($kept);
				$kept = '"';
				$state = STATE_LITERAL;

			} else {
				$kept .= $c;
			}
		} elsif ($state == STATE_LITERAL) {
			$kept .= $c;
			if ($c eq "\"") {
				$ret .= $kept;
				$kept = "";
				$state = STATE_NORMAL;
			}
		} else {
			die "BAD STATE $state;"
		}

	}

	if ($state == STATE_NORMAL) {
		$ret .= checkfortokens($kept);
	} elsif ($state == STATE_LITERAL) {
		print STDERR "Unterminated string constant\n";
		return 0;
	}

	@_[1] = $ret;
	return 1;
}

sub checkfortokens($) {
	my ($buf) = @_;
	my $i = 0;
	while ($i < length($buf)) {
		for my $k (keys %b16keys) {
			if ($k eq substr($buf, $i, length($k))) {
				$buf = substr($buf, 0, $i) . chr($b16keys{$k}) . substr($buf, $i+length($k));
			}
		}
		$i++;
	}
	return $buf;
}