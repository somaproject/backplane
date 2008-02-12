-- VHDL initialization records.
--
-- Release 9.3i - Data2MEM J.40, build 1.5.4 Aug 14, 2007
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--
-- Command: data2mem -bm backplane_bd.bmm -bd backplane.mem -bt build/backplane.bit -o h backplane_mem.vhd -o b backplane.postmem.bit
--
-- Created on 02/11/08 11:31 pm, from:
--
--     Map file     - backplane_bd.bmm
--     Data file(s) - backplane.mem
--
-- Address space 'syscontrolram' [0x00000000:0x000007FF], 2048 bytes in size.
--
-- Bus width = 18 bits, bit lane width = 18 bits, number of bus blocks = 1.

library ieee;
use ieee.std_logic_1164;

package backplane_mem_pkg is

-- BRAM 0 in address space [0x00000000:0x000007FF], bit lane [17:0]
-- INST syscontrol_inst/instruction_ram LOC = RAMB16_X0Y9;
	constant syscontrol_inst_instruction_ram_INIT_00  : bit_vector(0 to 255) := x"1929844930091FA9842930291029841939091909840930091F79888930091DE9";
	constant syscontrol_inst_instruction_ram_INIT_01  : bit_vector(0 to 255) := x"301910B984A93FF91009849932091209848930091FE984693029102984593929";
	constant syscontrol_inst_instruction_ram_INIT_02  : bit_vector(0 to 255) := x"101985D9101985991019855910198519101984E93029102984D93949194984C9";
	constant syscontrol_inst_instruction_ram_INIT_03  : bit_vector(0 to 255) := x"101987D9101987991019875910198719101986D9101986991019865910198619";
	constant syscontrol_inst_instruction_ram_INIT_04  : bit_vector(0 to 255) := x"1659102B191A809910098089101908C04720A00910194490A009100904108899";
	constant syscontrol_inst_instruction_ram_INIT_05  : bit_vector(0 to 255) := x"8819887B209930091019885936B912E9884936F91729883937491779882936E9";
	constant syscontrol_inst_instruction_ram_INIT_06  : bit_vector(0 to 255) := x"8819887B2099308910198859100988491009883937491009882936291699880A";
	constant syscontrol_inst_instruction_ram_INIT_07  : bit_vector(0 to 255) := x"16998839370912E9882936491739102B191A809910F980893FF91F0908C0880A";
	constant syscontrol_inst_instruction_ram_INIT_08  : bit_vector(0 to 255) := x"102908E0103780B008C0880A8819887B20993009101988593749100988493629";
	constant syscontrol_inst_instruction_ram_INIT_09  : bit_vector(0 to 255) := x"100A09E01FF78809192920991019887910291005100409401FF7880919098879";
	constant syscontrol_inst_instruction_ram_INIT_0A  : bit_vector(0 to 255) := x"88491009209910198879102990A580941089CB60B05BA04C102C103B88348825";
	constant syscontrol_inst_instruction_ram_INIT_0B  : bit_vector(0 to 255) := x"10470BE01057A09810194BF0A08910090B7010670B501FF78809193988591089";
	constant syscontrol_inst_instruction_ram_INIT_0C  : bit_vector(0 to 255) := x"4D30A00910090CC04D80A00910090C8010778809194920991019887910290C00";
	constant syscontrol_inst_instruction_ram_INIT_0D  : bit_vector(0 to 255) := x"A07910790DD0108788091319887910490D700D600D50100710104D60A0091019";
	constant syscontrol_inst_instruction_ram_INIT_0E  : bit_vector(0 to 255) := x"4B80A079105949F0A07910494950A07910394420A079101948F0A07910094C90";
	constant syscontrol_inst_instruction_ram_INIT_0F  : bit_vector(0 to 255) := x"881A001A0FD010470C420B330F9010170B310F604CD0A07910894C10A0791069";
	constant syscontrol_inst_instruction_ram_INIT_10  : bit_vector(0 to 255) := x"0D5980A90C4980A90B3910A0880B120B887B091B884903298839002988290009";
	constant syscontrol_inst_instruction_ram_INIT_11  : bit_vector(0 to 255) := x"00000000000000000000000000000000000011601057106880C080A90E6980A9";
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
	constant syscontrol_inst_instruction_ram_INITP_00 : bit_vector(0 to 255) := x"5D57DDE54FDC5DD74F5CD775D59D92E4DDDDDDDDDDDD5DD7755DD7755DD7755D";
	constant syscontrol_inst_instruction_ram_INITP_01 : bit_vector(0 to 255) := x"6F6028499224499264776A4992921D9C19496677070709F0D9C195DDD9FEC475";
	constant syscontrol_inst_instruction_ram_INITP_02 : bit_vector(0 to 255) := x"000000000000000000000000000000000000000000000000000058CFCC78F3FF";
	constant syscontrol_inst_instruction_ram_INITP_03 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_04 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_05 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_06 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant syscontrol_inst_instruction_ram_INITP_07 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";

end backplane_mem_pkg;
-- VHDL initialization records.
--
-- Release 9.3i - Data2MEM J.40, build 1.5.4 Aug 14, 2007
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--
-- Command: data2mem -bm backplane_bd.bmm -bd backplane.mem -bt build/backplane.bit -o h backplane_mem.vhd -o b backplane.postmem.bit
--
-- Created on 02/11/08 11:31 pm, from:
--
--     Map file     - backplane_bd.bmm
--     Data file(s) - backplane.mem
--
-- Address space 'netcontrolram' [0x10000000:0x100007FF], 2048 bytes in size.
--
-- Bus width = 18 bits, bit lane width = 18 bits, number of bus blocks = 1.

library ieee;
use ieee.std_logic_1164;

package backplane_mem_pkg is

-- BRAM 0 in address space [0x10000000:0x100007FF], bit lane [17:0]
-- INST netcontrol_inst/instruction_ram LOC = RAMB16_X1Y4;
	constant netcontrol_inst_instruction_ram_INIT_00  : bit_vector(0 to 255) := x"1305844530051B5584253FF51005841533151315840530051B25888530051AA5";
	constant netcontrol_inst_instruction_ram_INIT_01  : bit_vector(0 to 255) := x"101585951015855510158515101584D510158495101584653FF5100584553305";
	constant netcontrol_inst_instruction_ram_INIT_02  : bit_vector(0 to 255) := x"101587951015875510158715101586D5101586951015865510158615101585D5";
	constant netcontrol_inst_instruction_ram_INIT_03  : bit_vector(0 to 255) := x"10154570A015100503B0880513058872882688350036004503308894101487D5";
	constant netcontrol_inst_instruction_ram_INIT_04  : bit_vector(0 to 255) := x"A015104549E0A01510754930A01510654770A015103546D0A015102545F0A015";
	constant netcontrol_inst_instruction_ram_INIT_05  : bit_vector(0 to 255) := x"000605E010118005804580358025801510054A80A0151FF548B0A015105547E0";
	constant netcontrol_inst_instruction_ram_INIT_06  : bit_vector(0 to 255) := x"80258015101506C0102106A0100146B0A06500363015123506304640A0651015";
	constant netcontrol_inst_instruction_ram_INIT_07  : bit_vector(0 to 255) := x"8015101507D0104107B047C0A065101500060760103180058045101580351005";
	constant netcontrol_inst_instruction_ram_INIT_08  : bit_vector(0 to 255) := x"4910A0351005A053101508A03F03100310518005804580353115140580251095";
	constant netcontrol_inst_instruction_ram_INIT_09  : bit_vector(0 to 255) := x"1015000609D01071800580451205803510058025108580151015092010610900";
	constant netcontrol_inst_instruction_ram_INIT_0A  : bit_vector(0 to 255) := x"A0541014000543C0A00410140A9010000A701FF18805887510750A204A30A065";
	constant netcontrol_inst_instruction_ram_INIT_0B  : bit_vector(0 to 255) := x"0BF08004091280440D5480340C4480240B3480140A240B40100110100B104340";
	constant netcontrol_inst_instruction_ram_INIT_0C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_0D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_0E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_0F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_10  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_11  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_12  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_13  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_14  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_15  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_16  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_17  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_18  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_19  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_1F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_20  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_21  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_22  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_23  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_24  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_25  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_26  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_27  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_28  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_29  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_2F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_30  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_31  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_32  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_33  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_34  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_35  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_36  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_37  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_38  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_39  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3A  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3B  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3C  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3D  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3E  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INIT_3F  : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_00 : bit_vector(0 to 255) := x"674ADB779F995C4ADBFF49922449922449DEFFDEDDDDDDDDDDDDDD755DD7755D";
	constant netcontrol_inst_instruction_ram_INITP_01 : bit_vector(0 to 255) := x"00000000000000000000000000000000CECC8CA5B464F6296DDFDD991259FD75";
	constant netcontrol_inst_instruction_ram_INITP_02 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_03 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_04 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_05 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_06 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";
	constant netcontrol_inst_instruction_ram_INITP_07 : bit_vector(0 to 255) := x"0000000000000000000000000000000000000000000000000000000000000000";

end backplane_mem_pkg;
