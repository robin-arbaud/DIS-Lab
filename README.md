# DIS-Lab
HDL tasks for the Digital Integrated Circuits course at TU Wien.

Toolchain: GHDL for simulation, Vivado for implementation.
Target platform: Nexys 4 DDR board from Digilent.

Task 1: Random Number Generator

The RNG itself is based on the design proposed in the paper "FPGA Vendor Agnostic True Random Number Generator" by D. Schellekens et al. (copyright 2006 IEEE, doi: 10.1109/FPL.2006.311206). However, the post-processing part is not implemented, since I could not find a generator matrix for a (256, 16, 113) linear code, which is needed for this step. The noise source is based on ring-oscillators.
	
The top file contains the RNG, a UART core for sending generated numbers to a host PC, a seven-segments display controller for displaying the LSB of the generated number on board, and debouncers for cleaning user inputs.
	
Additionally, a top_sim file is provided for simulation, which does not include debouncers.
	
The runsim_task1.sh script will simulate the behavior of the controller. The synth.tcl and prog.tcl are vivado scripts for synthesis and programming of the whole system.
