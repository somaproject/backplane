
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
		tclrtest: out std_logic; 
		tclr : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL reset :  std_logic := '1';
	SIGNAL tincext :  std_logic;
	SIGNAL tclrext :  std_logic;
	SIGNAL tsel :  std_logic := '0';
	SIGNAL tinc :  std_logic;
	SIGNAL tclr, tclrtest :  std_logic := '0';
	SIGNAL data :  std_logic_vector(15 downto 0) := (others => 'Z');
	SIGNAL addr :  std_logic_vector(7 downto 0) := (others => 'Z');
	SIGNAL event :  std_logic := '1';
	SIGNAL ce :  std_logic := '1';


	signal longcount : integer := 0; 
BEGIN


	reset <= '0' after 100 ns; 

	clk <= not clk after 25 ns; 



	
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
		tclrtest => tclrtest,
		data => data,
		addr => addr,
		event => event,
		ce => ce
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS(CLK, longcount)
  	variable count : integer := 0; 
   BEGIN
		if rising_edge(CLK) then
			if count = 1999 then
				count := 0;
			else
				count := count + 1;
			end if; 				
			longcount <= longcount + 1; 

		end if; 
		
		if (count mod 250) = 0 then
			ce <= '0' after 10 ns;
		else
			ce <= '1' after 10 ns;
		end if; 

		if longcount mod 5 = 0 then
			event <= '0' after 10 ns;
		else
			event <= '1' after 10 ns;
		end if; 
		case longcount is
			when 6101 =>
				addr <= "11111111" after 10 ns;
				data <= "1000000000000000" after 10 ns;
			when 10102 =>
				addr <= "11111111" after 10 ns;
				data <= "0000000000000000" after 10 ns;
			when 6103 =>
				event <= '1' after 10 ns;
				addr <= "11111111" after 10 ns;
				data <= "0000000000000000" after 10 ns;
			when 6104 =>
				addr <= "11111111" after 10 ns;
				data <= "0000000000000000" after 10 ns;
			when 6105 =>
				addr <= "11111111" after 10 ns;
				data <= "0000000000000000" after 10 ns;
			when others =>
				addr <= "ZZZZZZZZ" after 10 ns;
				data <= "ZZZZZZZZZZZZZZZZ" after 10 ns;
		end case; 


		
			
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
