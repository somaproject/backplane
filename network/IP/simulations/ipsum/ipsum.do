# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/ipsum.vhd

-- simulation entities
vcom -93 -explicit ipsumtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work ipsumtest
view wave
add wave *
view structure
