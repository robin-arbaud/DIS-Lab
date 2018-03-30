#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a fifo.vhd
ghdl -a fifo_tb.vhd
ghdl -e fifo_tb
ghdl -r fifo_tb --vcd=wave.vcd

rm -f *.o *.cf
