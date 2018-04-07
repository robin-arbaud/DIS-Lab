## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK];


## Switches
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports MODE];
#set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports DATA[1] ];
#set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports DATA[2] ];
#set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports DATA[3] ];
#set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports DATA[4] ];
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports DATA[5] ];
#set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports DATA[6] ];
#set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports DATA[7] ];


## Push buttons
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports RST];
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports REQ];


## UART
set_property -dict {PACKAGE_PIN D4  IOSTANDARD LVCMOS33} [get_ports UART_TX];


## 7 segments display
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[7] ];
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[6] ];
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[5] ];
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[4] ];
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[3] ];
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[2] ];
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[1] ];
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports DISPLAY_SEG[0] ];

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[0] ];
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[1] ];
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[2] ];
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[3] ];
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[4] ];
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[5] ];
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[6] ];
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports DISPLAY_AN[7] ];
