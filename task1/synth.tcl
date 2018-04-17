#------------------------------------------------------------------------------
#
# Synthesis script
# Create vivado project, synthesize, generate bitstream file
#
# -----------------------------------------------------------------------------
#
create_project -part xc7a100t -force vivado/task1
#
# -----------------------------------------------------------------------------
#
read_vhdl ../utils/utils_pkg.vhd
read_vhdl ../utils/debouncer.vhd
read_vhdl ../utils/edge_detector.vhd
read_vhdl ../utils/uart_tx.vhd
read_vhdl ../utils/seven_seg_display.vhd
read_vhdl ../utils/fifo/fifo.vhd

read_vhdl hdl/ring_osc.vhd
read_vhdl hdl/noise_source.vhd
read_vhdl hdl/rng.vhd
read_vhdl hdl/controller.vhd
read_vhdl hdl/top.vhd

read_xdc task1.xdc
#
# -----------------------------------------------------------------------------
#
synth_design -top top
#
# -----------------------------------------------------------------------------
#
opt_design
place_design
route_design
#
# -----------------------------------------------------------------------------
#
write_bitstream -force task1.bit
#
# -----------------------------------------------------------------------------
