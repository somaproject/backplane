library ieee;
use ieee.std_logic_1164;
package netcontrolmemdebugtest_mem_pkg is
		constant netcontrol_inst_ram_INIT_00 : bit_vector(0 to 255) := X"1306844630061D3684263FF61006841634161416840630061CF6888630061C76";
		constant netcontrol_inst_ram_INIT_01 : bit_vector(0 to 255) := X"30061EB684A63FF61006849634061406848630061DE684663FF6100684563306";
		constant netcontrol_inst_ram_INIT_02 : bit_vector(0 to 255) := X"85263FF61006851633161316850630061F3684E63FF6100684D63446144684C6";
		constant netcontrol_inst_ram_INIT_03 : bit_vector(0 to 255) := X"10168616101685D610168596101685663FF61006855634561456854630061F66";
		constant netcontrol_inst_ram_INIT_04 : bit_vector(0 to 255) := X"88951015140487D6101687961016875610168716101686D61016869610168656";
		constant netcontrol_inst_ram_INIT_05 : bit_vector(0 to 255) := X"102647C0A01610164740A0161006058088061306887288278836003700460500";
		constant netcontrol_inst_ram_INIT_06 : bit_vector(0 to 255) := X"A016105649B0A01610464BB0A01610764B00A01610664940A016103648A0A016";
		constant netcontrol_inst_ram_INIT_07 : bit_vector(0 to 255) := X"4810A0761016000707B010118006804680368026801610064C50A0161FF64A80";
		constant netcontrol_inst_ram_INIT_08 : bit_vector(0 to 255) := X"10168036100680268016101608901021087010014880A0760037301612360800";
		constant netcontrol_inst_ram_INIT_09 : bit_vector(0 to 255) := X"1406802610968016101609A0104109804990A076101600070930103180068046";
		constant netcontrol_inst_ram_INIT_0A : bit_vector(0 to 255) := X"0AF010610AD04AE0A0361006A06310160A703F03100310518006804680363116";
		constant netcontrol_inst_ram_INIT_0B : bit_vector(0 to 255) := X"0BF04C00A076101600070BA01071800680461206803610068026108680161016";
		constant netcontrol_inst_ram_INIT_0C : bit_vector(0 to 255) := X"0A260CE04510A065101500064590A00510150C6010000C401FF1880688761076";
		constant netcontrol_inst_ram_INIT_0D : bit_vector(0 to 255) := X"887709170DD08005091280450D5580350C4580250B3580150A250D20C0668206";
		constant netcontrol_inst_ram_INIT_0E : bit_vector(0 to 255) := X"C0760B3684070A2700000EA08804884A88398828406A40694068820688160A26";
		constant netcontrol_inst_ram_INIT_0F : bit_vector(0 to 255) := X"14588826881A887709174096000084090A2A0A290F50100110100F200000C076";
		constant netcontrol_inst_ram_INIT_10 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000010108808";
		constant netcontrol_inst_ram_INIT_11 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_12 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_13 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_14 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_15 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_16 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_17 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_18 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_19 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_1F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_20 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_21 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_22 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_23 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_24 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_25 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_26 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_27 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_28 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_29 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_2F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_30 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_31 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_32 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_33 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_34 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_35 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_36 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_37 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_38 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_39 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INIT_3F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INITP_00 : bit_vector(0 to 255) := X"4B6FFE49249249249249EFFDEBBBBBBBBBBBAEBAEBAEBAEBAEBAEBAEBAEBAEBA";
		constant netcontrol_inst_ram_INITP_01 : bit_vector(0 to 255) := X"BF320693C81FFFECC733331E14B499BE52DBEEEE65226AFEBB994B6FBBE664E9";
		constant netcontrol_inst_ram_INITP_02 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000007";
		constant netcontrol_inst_ram_INITP_03 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INITP_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INITP_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INITP_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant netcontrol_inst_ram_INITP_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
end netcontrolmemdebugtest_mem_pkg;