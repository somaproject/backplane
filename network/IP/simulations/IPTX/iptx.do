# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/ARPreq.vhd
vcom -93 -explicit ../../vhdl/iptx.vhd

-- simulation entities
vcom -93 -explicit iptxtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work iptxtest
view wave
add wave *
view structure
