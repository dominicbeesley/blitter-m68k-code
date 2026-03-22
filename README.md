# Blitter M68K Code

This repository contains test code and an operating system for the Motorola 
68000 series CPUs used as a main CPU in a BBC Micro type system via the
[Dossytronics Blitter Board](https://stardot.org.uk/forums/viewtopic.php?p=332376#p332376)

See also:
* [API for Blitter registers and extra devices](https://github.com/dominicbeesley/blitter-vhdl-6502/blob/main/doc/API.md)
* [Mk.2 overview](https://github.com/dominicbeesley/blitter-vhdl-6502/blob/main/doc/hardware-overview-mk2.md)
* [Blitter Mk.3 hardware](https://github.com/dominicbeesley/blitter-vhdl-6502/wiki/Mk.3-Hardware-Overview)

## blit-test/test-mos

Builds a binary image that can be loaded as a boot-rom to test the memory
and screen.

## mos

A prototype operating system that provide MOS-like services for 68k programs.

