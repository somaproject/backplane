
-- VHDL Test Bench Created from source file timer.vhd -- 00:58:43 04/21/2003
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT timer
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		tincext : IN std_logic;
		tclrext : IN std_logic;
		tsel : IN std_logic;
		event : IN std_logic;
		ce : IN std_logic;    
		data : INOUT std_logic_vector(15 downto 0);
		addr : INOUT std_logic_vector(7 downto 0);      
		tinc : OUT std_logic;
		tclr : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL reset :  std_logic := '1';
	SIGNAL tincext :  std_logic;
	SIGNAL tclrext :  std_logic;
	SIGNAL tsel :  std_logic := '0';
	SIGNAL tinc :  std_logic;
	SIGNAL tclr :  std_logic;
	SIGNAL data :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL addr :  std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL event :  std_logic;
	SIGNAL ce :  std_logic := '1';

BEGIN


	reset <= '0' after 100 ns; 

	clk <= not clk after 25 ns; 


   -- CE faking it
	CE <= '0' after 110000 ns, '1' after 110050 ns,
			'0' after 210000 ns, '1' after 210050 ns,
			'0' after 310000 ns, '1' after 310050 ns,
			'0' after 410000 ns, '1' after 410050 ns,
			'0' after 510000 ns, '1' after 510050 ns,
			'0' after 610000 ns, '1' after 610050 ns,
			'0' after 710000 ns, '1' after 710050 ns,
			'0' after 810000 ns, '1' after 810050 ns,
			'0' after 910000 ns, '1' after 910050 ns;

	
	--CE <= '1' after 110050 ns; 
	--CE <= '0' after 210000 ns;
	--CE <= '1' after 210050 ns; 

	uut: timer PORT MAP(
		clk => clk,
		reset => reset,
		tincext => tincext,
		tclrext => tclrext,
		tsel => tsel,
		tinc => tinc,
		tclr => tclr,
		data => data,
		addr => addr,
		event => event,
		ce => ce
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
