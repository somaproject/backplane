-- VHDL initialization records.
--
-- Release 9.2.03i - Data2MEM J.39, build 1.5.4 Aug 14, 2007
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--
-- Command: data2mem -bm nettest_bd.bmm -bd nettest.mem -bt build/nettest.bit -o h nettest_mem.vhd -o b nettest.postmem.bit
--
-- Created on 01/17/08 11:05 am, from:
--
--     Map file     - nettest_bd.bmm
--     Data file(s) - nettest.mem
--
-- Address space 'destmask' [0x00000000:0x000007FF], 2048 bytes in size.
--
-- Bus width = 18 bits, bit lane width = 18 bits, number of bus blocks = 1.

library ieee;
use ieee.std_logic_1164;

package nettest_mem_pkg is

-- BRAM 0 in address space [0x00000000:0x000007FF], bit lane [17:0]
-- INST syscontrol_inst/instruction_ram LOC = RAMB16_X1Y18;
	constant syscontrol_inst_instruction_ram_INIT_00  : bit_vector(0 to 255) := x"16708440300014C084203FF01000841036501650840030001430888030001420";
	constant syscontrol_inst_instruction_ram_INIT_01  : bit_vector(0 to 255) := x"3000150084A03FF010008490366016608480300014E084603FF0100084503670";
	constant syscontrol_inst_instruction_ram_INIT_02  : bit_vector(0 to 255) := x"101085D0101085901010855010108510101084E03FF0100084D03640164084C0";
	constant syscontrol_inst_instruction_ram_INIT_03  : bit_vector(0 to 255) := x"101087D0101087901010875010108710101086D0101086901010865010108610";
	constant syscontrol_inst_instruction_ram_INIT_04  : bit_vector(0 to 255) := x"04F080B004D080C004B080A00D5080A00C4080A00B3080A00A20042004108890";
	constant syscontrol_inst_instruction_ram_INIT_05  : bit_vector(0 to 255) := x"000000000000000000000000000000000000000000000540809180800B310A20";
	constant syscontrol_inst_instruction_ram_INIT_06  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_07  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_08  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_09  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_0F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_10  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_11  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_12  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_13  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_14  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_15  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_16  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_17  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_18  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_19  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_1F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_20  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_21  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_22  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_23  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_24  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_25  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_26  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_27  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_28  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_29  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_2F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_30  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_31  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_32  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_33  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_34  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_35  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_36  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_37  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_38  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_39  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INIT_3F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_00 : bit_vector(0 to 255) := x"00000000000000000000800FEECECCE8DDDDDDDDDDDD5DD7755DD7755DD7755D";
	constant syscontrol_inst_instruction_ram_INITP_01 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_02 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_03 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_04 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_05 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_06 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_07 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";

end nettest_mem_pkg;
