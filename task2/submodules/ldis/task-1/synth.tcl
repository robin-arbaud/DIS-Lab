
# Synthesis script for task-1 using Digilent Nexys 4 DDR board

create_project -part xc7a100t -force rng

read_vhdl uart_tx/uart_tx.vhd
read_vhdl uart_tx/uart_tx_pkg.vhd
read_vhdl design.vhd
read_xdc design.xdc

synth_design -top rng

opt_design
place_design
route_design

write_bitstream -force rng.bit
