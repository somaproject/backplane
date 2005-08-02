# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/buscontrol/esequence.vhd

-- simulation entities
vcom -93 -explicit esequencetest.vhd


vsim -t 1ps -L xilinxcorelib -lib work esequencetest
view wave
add wave *
view structure
