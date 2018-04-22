#!/bin/bash

rm -f *.o *.cf *.vcd

ghdl -a ../utils/utils_pkg.vhd
ghdl -a ../utils/debouncer.vhd
ghdl -a ../utils/edge_detector.vhd
ghdl -a ../utils/seven_seg_display.vhd
ghdl -a ../utils/uart_tx.vhd
ghdl -a ../utils/fifo/fifo.vhd

ghdl -a hdl/ring_osc.vhd
ghdl -a hdl/noise_source.vhd
ghdl -a hdl/rng.vhd
ghdl -a hdl/controller.vhd
ghdl -a hdl/controller_tb.vhd
ghdl -a hdl/top.vhd
ghdl -a hdl/top_sim.vhd

ghdl -e controller_tb
ghdl -r controller_tb --vcd=sim_controller.vcd

rm -f *.o *.cf
