--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2005 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file decode8b10b.vhd when simulating
-- the core, decode8b10b. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synopsys translate_off
Library XilinxCoreLib;
-- synopsys translate_on
ENTITY decode8b10b IS
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(9 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	kout: OUT std_logic;
	ce: IN std_logic;
	code_err: OUT std_logic;
	disp_err: OUT std_logic);
END decode8b10b;

ARCHITECTURE decode8b10b_a OF decode8b10b IS
-- synopsys translate_off
component wrapped_decode8b10b
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(9 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	kout: OUT std_logic;
	ce: IN std_logic;
	code_err: OUT std_logic;
	disp_err: OUT std_logic);
end component;

-- Configuration specification 
	for all : wrapped_decode8b10b use entity XilinxCoreLib.decode_8b10b_v5_0(behavioral)
		generic map(
			c_has_nd_b => 0,
			c_has_code_err => 1,
			c_has_run_disp => 0,
			c_sinit_dout => "00000000",
			c_has_sym_disp_b => 0,
			c_sinit_kout => 0,
			c_has_sym_disp => 0,
			c_has_sinit_b => 0,
			c_decode_type => 0,
			c_sinit_run_disp_b => 1,
			c_has_nd => 0,
			c_enable_rlocs => 0,
			c_has_disp_err_b => 0,
			c_sinit_run_disp => 1,
			c_has_ce => 1,
			c_has_bports => 0,
			c_has_disp_err => 1,
			c_sinit_kout_b => 0,
			c_has_disp_in_b => 0,
			c_has_code_err_b => 0,
			c_sinit_dout_b => "00000000",
			c_has_sinit => 0,
			c_has_run_disp_b => 0,
			c_has_disp_in => 0,
			c_has_ce_b => 0);
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_decode8b10b
		port map (
			clk => clk,
			din => din,
			dout => dout,
			kout => kout,
			ce => ce,
			code_err => code_err,
			disp_err => disp_err);
-- synopsys translate_on

END decode8b10b_a;

