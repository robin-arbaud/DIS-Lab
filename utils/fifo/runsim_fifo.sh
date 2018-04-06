#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a fifo.vhd
ghdl -a fifo_tb.vhd
ghdl -a fifo_tb2.vhd

ghdl -e fifo_tb
ghdl -r fifo_tb --vcd=sim1.vcd

ghdl -e fifo_tb2
ghdl -r fifo_tb2 --vcd=sim2.vcd

rm -f *.o *.cf
