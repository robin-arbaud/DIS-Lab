#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a ../utils/utils_pkg.vhd
ghdl -a ../utils/debouncer.vhd
ghdl -a ../utils/edge_detector.vhd
ghdl -a ../utils/seven_seg_display.vhd
ghdl -a ../utils/uart_tx.vhd
ghdl -a ../utils/fifo/fifo.vhd

ghdl -a hdl/controller.vhd
ghdl -a hdl/top.vhd

#ghdl -e tb.vhd
#ghdl -r tb.vhd --vcd=sim.vcd

rm -f *.o *.cf
