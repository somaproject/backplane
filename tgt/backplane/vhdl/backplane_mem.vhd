library ieee;
use ieee.std_logic_1164;
package backplane_mem_pkg is
		constant syscontrol_inst_instruction_ram_INIT_00 : bit_vector(0 to 255) := X"1929844930091B69842930291029841939091909840930091B39888930091A09";
		constant syscontrol_inst_instruction_ram_INIT_01 : bit_vector(0 to 255) := X"84D9101984A930291029849939491949848930091BA984693029102984593929";
		constant syscontrol_inst_instruction_ram_INIT_02 : bit_vector(0 to 255) := X"86D9101986991019865910198619101985D91019859910198559101985191019";
		constant syscontrol_inst_instruction_ram_INIT_03 : bit_vector(0 to 255) := X"191B809910098089101903A08899101987D91019879910198759101987191019";
		constant syscontrol_inst_instruction_ram_INIT_04 : bit_vector(0 to 255) := X"20AA300A101A885A36BA12EA884A36FA172A883A374A177A882A36EA165A102C";
		constant syscontrol_inst_instruction_ram_INIT_05 : bit_vector(0 to 255) := X"20AA308A101A885A100A884A100A883A374A100A882A362A169A880B881A887C";
		constant syscontrol_inst_instruction_ram_INIT_06 : bit_vector(0 to 255) := X"887910291005100406B01FF788091909887910290650103780B0880B881A887C";
		constant syscontrol_inst_instruction_ram_INIT_07 : bit_vector(0 to 255) := X"80941089C8D0B05BA04C102C103B88348825100A07501FF78809192920991019";
		constant syscontrol_inst_instruction_ram_INIT_08 : bit_vector(0 to 255) := X"100908E0106708C01FF7880919398859108988491009209910198879102990A5";
		constant syscontrol_inst_instruction_ram_INIT_09 : bit_vector(0 to 255) := X"09F010778809194920991019887910290970104709501057A09810194960A089";
		constant syscontrol_inst_instruction_ram_INIT_0A : bit_vector(0 to 255) := X"106948F0A07910594760A079104946C0A079103943B0A07910194660A0791009";
		constant syscontrol_inst_instruction_ram_INIT_0B : bit_vector(0 to 255) := X"80A90D5980A90C4980A90B390B9010470C420B330B5010170B310B204980A079";
		constant syscontrol_inst_instruction_ram_INIT_0C : bit_vector(0 to 255) := X"00000000000000000000000000000000000000000C501057106880C080A90E69";
		constant syscontrol_inst_instruction_ram_INIT_0D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_0E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_0F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_10 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_11 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_12 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_13 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_14 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_15 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_16 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_17 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_18 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_19 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_1F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_20 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_21 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_22 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_23 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_24 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_25 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_26 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_27 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_28 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_29 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_2F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_30 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_31 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_32 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_33 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_34 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_35 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_36 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_37 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_38 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_39 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INIT_3F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_00 : bit_vector(0 to 255) := X"2403E6E0EA6EE6FF23BBAEBF23AEBAEABB9EEEEEEEEEEEEEEEBAEBAEBAEBAEBA";
		constant syscontrol_inst_instruction_ram_INITP_01 : bit_vector(0 to 255) := X"000000000000000000000000000006BCCCC60614924924926E0E662499BBB838";
		constant syscontrol_inst_instruction_ram_INITP_02 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_03 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant syscontrol_inst_instruction_ram_INITP_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_00 : bit_vector(0 to 255) := X"849210128452101284223FF210028412330213028402300213A2888230021352";
		constant netcontrol_inst_instruction_ram_INIT_01 : bit_vector(0 to 255) := X"86921012865210128612101285D2101285921012855210128512101284D21012";
		constant netcontrol_inst_instruction_ram_INIT_02 : bit_vector(0 to 255) := X"88220033004202C08891101187D2101287921012875210128712101286D21012";
		constant netcontrol_inst_instruction_ram_INIT_03 : bit_vector(0 to 255) := X"80310C4180210B3180110A21039042D0A0211011000203408802130288708833";
		constant netcontrol_inst_instruction_ram_INIT_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000004408001091080410D51";
		constant netcontrol_inst_instruction_ram_INIT_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_08 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_09 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_0F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_10 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_11 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_12 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_13 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_14 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_15 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_16 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_17 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_18 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_19 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_1F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_20 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_21 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_22 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_23 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_24 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_25 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_26 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_27 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_28 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_29 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_2F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_30 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_31 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_32 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_33 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_34 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_35 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_36 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_37 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_38 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_39 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INIT_3F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_00 : bit_vector(0 to 255) := X"000000000000000000000000000001CCCCC52DEFFDEEEEEEEEEEEEEEEEEBAEBA";
		constant netcontrol_inst_instruction_ram_INITP_01 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_02 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_03 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_instruction_ram_INITP_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
end backplane_mem_pkg;
