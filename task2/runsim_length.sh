#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a hdl/length.vhd
ghdl -a hdl/length_tb.vhd

ghdl -e length_tb
ghdl -r length_tb --vcd=sim.vcd

rm -f *.o *.cf
