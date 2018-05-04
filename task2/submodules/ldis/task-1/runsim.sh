#!/bin/bash

# Script to simulate VHDL designs

ghdl -s uart_tx/uart_tx_pkg.vhd uart_tx/uart_tx.vhd design.vhd tb.vhd
ghdl -a uart_tx/uart_tx_pkg.vhd uart_tx/uart_tx.vhd design.vhd tb.vhd
ghdl -e tb
ghdl -r tb --vcd=tb.vcd # && gtkwave tb.vcd
