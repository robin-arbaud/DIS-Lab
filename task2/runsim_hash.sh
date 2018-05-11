#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a submodules/ldis/task-2/design.vhd
ghdl -a hdl/le32.vhd
ghdl -a hdl/hashSeqOut.vhd
ghdl -a hdl/hash_tb.vhd

ghdl -e hash_tb
ghdl -r hash_tb --vcd=sim_hash.vcd

rm -f *.o *.cf
