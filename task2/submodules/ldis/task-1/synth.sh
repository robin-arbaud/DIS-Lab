#!/bin/bash

# Script to synthesise and flash VHDL designs

printf "verific -vhdl93 uart_tx/uart_tx.vhd uart_tx/uart_tx_pkg.vhd design.vhd
\nverific -import -all\nsynth_xilinx -edif rng.edif -top rng\n" | yosys
vivado -mode batch -source synth.tcl

vivado -mode batch -source prog.tcl
