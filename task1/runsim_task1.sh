#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a ../utils/utils_pkg.vhd
ghdl -a ../utils/debouncer.vhd
ghdl -a ../utils/edge_detector.vhd
ghdl -a ../utils/seven_seg_display.vhd
ghdl -a ../utils/uart_tx.vhd
ghdl -a ../utils/fifo/fifo.vhd

ghdl -a hdl/controller.vhd
ghdl -a hdl/top_noRNG_sim.vhd
ghdl -a hdl/tb_noRNG.vhd

ghdl -e tb_noRNG
ghdl -r tb_noRNG --vcd=sim.vcd

rm -f *.o *.cf
