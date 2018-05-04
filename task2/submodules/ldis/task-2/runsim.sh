#!/bin/bash

# Script to simulate a VHDL design for blake2b
# authors Dinka Milovancev and Benedikt Tutzer
#
# USAGE: fill a file named messages.txt with messages that are to be hashed.
# Each line is interpreted as a message and run through the design. The result
# is compared with the result of the reference implementation in ./testgen.
#

make -C testgen
rm hashes.txt
#cat messages.txt | while read line
while IFS='' read -r line || [[ -n "$line" ]]; do
	./testgen/bin_testgen $line >> hashes.txt
done < messages.txt

ghdl -s --std=08 design.vhd tb.vhd
ghdl -a --std=08 design.vhd tb.vhd
ghdl -e --std=08 tb
ghdl -r --std=08 tb --wave=tb.ghw #--vcd=tb.vcd # && gtkwave tb.vcd

