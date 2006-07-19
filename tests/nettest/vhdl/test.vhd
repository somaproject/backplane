-- VHDL initialization records.
--
-- Release 8.1i - Data2MEM I.24, build 1.4 Jul 06, 2005
-- Copyright (c) 1995-2006 Xilinx, Inc.  All rights reserved.
--
-- Command: data2mem -bm test.bmm -bd test.mem -bt nettest.bit -o h test.vhd
--
-- Created on 06/08/06 09:54 am, from:
--
--     Map file     - test.bmm
--     Data file(s) - test.mem
--
-- Address space 'my_bram' [0x00000000:0x000007FF], 2048 bytes in size.
--
-- Bus width = 32 bits, bit lane width = 32 bits, number of bus blocks = 1.

library ieee;
use ieee.std_logic_1164;

package test_pkg is

-- BRAM 0 in address space [0x00000000:0x000007FF], bit lane [31:0]
-- INST syscontrol_inst/destmask_ram LOC = RAMB16_X1Y1;
	constant syscontrol_inst_destmask_ram_INIT_00  : bit_vector(0 to 255) := x"000000000000000000000000000000000000000000000000ABCDEF0012345678";
	constant syscontrol_inst_destmask_ram_INIT_01  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_02  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_03  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_04  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_05  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_06  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_07  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_08  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_09  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_0F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_10  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_11  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_12  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_13  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_14  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_15  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_16  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_17  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_18  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_19  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_1F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_20  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_21  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_22  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_23  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_24  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_25  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_26  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_27  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_28  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_29  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_2F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_30  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_31  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_32  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_33  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_34  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_35  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_36  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_37  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_38  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_39  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_destmask_ram_INIT_3F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";

end test_pkg;