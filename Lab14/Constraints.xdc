## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
# Bank = 34, Pin name = ,					Sch name = CLK100MHZ
		set_property PACKAGE_PIN W5 [get_ports Clk]
		set_property IOSTANDARD LVCMOS33 [get_ports Clk]
		create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports Clk]

set_property PACKAGE_PIN U18 [get_ports Instr]
set_property IOSTANDARD LVCMOS33 [get_ports Instr]
set_property PACKAGE_PIN W19 [get_ports Go]
set_property IOSTANDARD LVCMOS33 [get_ports Go]
set_property PACKAGE_PIN T17 [get_ports Step]
set_property IOSTANDARD LVCMOS33 [get_ports Step]
set_property PACKAGE_PIN T18 [get_ports Reset]
set_property IOSTANDARD LVCMOS33 [get_ports Reset]


set_property PACKAGE_PIN R2 [get_ports Display_Select[3]]
set_property IOSTANDARD LVCMOS33 [get_ports Display_Select[3]]
set_property PACKAGE_PIN T1 [get_ports Display_Select[2]]
set_property IOSTANDARD LVCMOS33 [get_ports Display_Select[2]]
set_property PACKAGE_PIN U1 [get_ports Display_Select[1]]
set_property IOSTANDARD LVCMOS33 [get_ports Display_Select[1]]
set_property PACKAGE_PIN W2 [get_ports Display_Select[0]]
set_property IOSTANDARD LVCMOS33 [get_ports Display_Select[0]]

set_property PACKAGE_PIN W17 [get_ports RF_Select[3]]
set_property IOSTANDARD LVCMOS33 [get_ports RF_Select[3]]
set_property PACKAGE_PIN W16 [get_ports RF_Select[2]]
set_property IOSTANDARD LVCMOS33 [get_ports RF_Select[2]]
set_property PACKAGE_PIN V16 [get_ports RF_Select[1]]
set_property IOSTANDARD LVCMOS33 [get_ports RF_Select[1]]
set_property PACKAGE_PIN V17 [get_ports RF_Select[0]]
set_property IOSTANDARD LVCMOS33 [get_ports RF_Select[0]]

set_property PACKAGE_PIN U16 [get_ports LED_Output[0]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[0]]
set_property PACKAGE_PIN E19 [get_ports LED_Output[1]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[1]]
set_property PACKAGE_PIN U19 [get_ports LED_Output[2]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[2]]
set_property PACKAGE_PIN V19 [get_ports LED_Output[3]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[3]]
set_property PACKAGE_PIN W18 [get_ports LED_Output[4]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[4]]
set_property PACKAGE_PIN U15 [get_ports LED_Output[5]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[5]]
set_property PACKAGE_PIN U14 [get_ports LED_Output[6]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[6]]
set_property PACKAGE_PIN V14 [get_ports LED_Output[7]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[7]]
set_property PACKAGE_PIN V13 [get_ports LED_Output[8]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[8]]
set_property PACKAGE_PIN V3 [get_ports LED_Output[9]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[9]]
set_property PACKAGE_PIN W3 [get_ports LED_Output[10]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[10]]
set_property PACKAGE_PIN U3 [get_ports LED_Output[11]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[11]]
set_property PACKAGE_PIN P3 [get_ports LED_Output[12]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[12]]
set_property PACKAGE_PIN N3 [get_ports LED_Output[13]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[13]]
set_property PACKAGE_PIN P1 [get_ports LED_Output[14]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[14]]
set_property PACKAGE_PIN L1 [get_ports LED_Output[15]]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Output[15]]




