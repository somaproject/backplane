
-- VHDL Test Bench Created from source file ipsum.vhd -- 15:30:41 12/16/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ipsumtest IS
END ipsumtest;

ARCHITECTURE behavior OF ipsumtest IS 

	COMPONENT ipsum
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		DIN : IN std_logic_vector(15 downto 0);
		EN : IN std_logic;          
		SUMOUT : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL RESET :  std_logic := '0';
	SIGNAL DIN :  std_logic_vector(15 downto 0);
	SIGNAL EN :  std_logic;
	SIGNAL SUMOUT :  std_logic_vector(15 downto 0);

BEGIN

	uut: ipsum PORT MAP(
		CLK => CLK,
		RESET => RESET,
		DIN => DIN,
		EN => EN,
		SUMOUT => SUMOUT
	);

	clk <= not clk after 10 ns; 

	test: process is
	begin
		wait until rising_edge(CLK); 
		wait until rising_edge(CLK); 
		wait until rising_edge(CLK); 
		RESET <= '1';
		wait until rising_edge(CLK); 
		RESET <= '0';
		DIN <= X"0001";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"f203";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"f4f5";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"f6f7";
		EN <= '1';
		wait until rising_edge(CLK); 
		EN <= '0'; 
		wait until rising_edge(CLK);
		wait until rising_edge(CLK);
		assert SUMOUT = X"ddf2" report
			"Checksum test 1 failed"
			severity error; 


		wait until rising_edge(CLK); 
		RESET <= '1';
		wait until rising_edge(CLK); 
		RESET <= '0';
		DIN <= X"0100";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"03f2";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"f5f4";
		EN <= '1';
		wait until rising_edge(CLK); 

		DIN <= X"f7f6";
		EN <= '1';
		wait until rising_edge(CLK); 
		EN <= '0'; 
		wait until rising_edge(CLK);
		wait until rising_edge(CLK);
		assert SUMOUT = X"f2dd" report
			"Checksum test 1 failed"
			severity error; 

		assert false
			report "End of simulation"
			severity failure; 

	end process; 


END;
