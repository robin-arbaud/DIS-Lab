#------------------------------------------------------------------------------
#
# Synthesis script
# Program FPGA with generated bitstream
#
# -----------------------------------------------------------------------------
#
open_hw
connect_hw_server
open_hw_target [lindex [get_hw_targets] 0]
set_property PROGRAM.FILE task1.bit [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
#
# -----------------------------------------------------------------------------
