library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sequencer is
    Port ( CLK : in std_logic;
           EVENT : out std_logic; 
           CE : out std_logic_vector(15 downto 0) := "1111111111111111");
end sequencer;

architecture Behavioral of sequencer is
   signal cyclecnt: std_logic_vector(5 downto 0):= "111111";
	signal eventcnt: std_logic_vector(2 downto 0):= "000"; 
	signal romdata, cemux: std_logic_vector(15 downto 0); 
	signal eventen : std_logic := '1'; 



begin
	cemux <= romdata when eventen = '0' else
		 		(others => '1');
	
	process (CLK, romdata, cyclecnt, eventcnt, eventen, cemux) is
	begin
		if rising_edge(CLK) then
			if eventen = '0' then 
				if cyclecnt = "110001" then
					cyclecnt <= "000000";
				else
					cyclecnt <= cyclecnt + 1;
				end if; 
			end if; 

			if eventcnt = "100" then
				eventcnt <= "000";
			else
				eventcnt <= eventcnt + 1;
			end if; 

			EVENT <= eventen;
			CE <= cemux; 


		end if;

		if eventcnt = "100" then
			eventen <= '0';
		else
			eventen <= '1';
		end if; 

	end process;



	-- our lookup rom to control the CEs

	-- now, the lines are as follows:
	-- 
	--  3:0 : inputs to the 3:8 decoders
	--  6:4 : addr for the decoders
	--  7: NEP
	--  8: USB
	--  9: ether
	--  10: DIO
	--  11: AO
	--  12: LCD/UI
	--  13: TIMER
	--  14: Network
	rom: process(cyclecnt) is 
	begin
	  case cyclecnt is 
	  	-- first 8 DSPs
 	  		when "000000" => romdata <= "1111111110001110";
 	  		when "000001" => romdata <= "1111111110011110";
 	  		when "000010" => romdata <= "1111111110101110";		  
 	  		when "000011" => romdata <= "1111111110111110";
 	  		when "000100" => romdata <= "1111111111001110";
 	  		when "000101" => romdata <= "1111111111011110";
 	  		when "000110" => romdata <= "1111111111101110";
 	  		when "000111" => romdata <= "1111111111111110";
		-- NEP 
 	  		when "001000" => romdata <= "1111111101111111";
		-- next 8 DSPs
 	  		when "001001" => romdata <= "1111111110001101";
 	  		when "001010" => romdata <= "1111111110011101";
 	  		when "001011" => romdata <= "1111111110101101";
 	  		when "001100" => romdata <= "1111111110111101";
 	  		when "001101" => romdata <= "1111111111001101";
 	  		when "001110" => romdata <= "1111111111011101";
 	  		when "001111" => romdata <= "1111111111101101";
 	  		when "010000" => romdata <= "1111111111111101";
		-- NEP + ether
 	  		when "010001" => romdata <= "1111111101111111";
 	  		when "010010" => romdata <= "1111110111111111";
 		-- next 8 DSPs, wow this is boring
 	  		when "010011" => romdata <= "1111111110001011";
 	  		when "010100" => romdata <= "1111111110011011";
 	  		when "010101" => romdata <= "1111111110101011";
 	  		when "010110" => romdata <= "1111111110111011";
 	  		when "010111" => romdata <= "1111111111001011";
 	  		when "011000" => romdata <= "1111111111011011";
 	  		when "011001" => romdata <= "1111111111101011";
 	  		when "011010" => romdata <= "1111111111111011";
		-- NEP 
 	  		when "011011" => romdata <= "1111111101111111";
		-- next four DSPs, the excitement continues
 	  		when "011100" => romdata <= "1111111110000111";
 	  		when "011101" => romdata <= "1111111110010111";
 	  		when "011110" => romdata <= "1111111110100111";
 	  		when "011111" => romdata <= "1111111110110111";
 	  		when "100000" => romdata <= "1111111111000111";
 	  		when "100001" => romdata <= "1111111111010111";
 	  		when "100010" => romdata <= "1111111111100111";
 	  		when "100011" => romdata <= "1111111111110111";
		-- let the fun begin! NEP, ETHER, USB
 	  		when "100100" => romdata <= "1111111101111111";
 	  		when "100101" => romdata <= "1111111011111111";
 	  		when "100110" => romdata <= "1111110111111111";
		-- DIO, AO, LCD/UI, TIMER, NET
 	  		when "100111" => romdata <= "1111101111111111";
 	  		when "101000" => romdata <= "1111011111111111";
 	  		when "101001" => romdata <= "1110111111111111";
 	  		when "101010" => romdata <= "1101111111111111";
 	  		when "101011" => romdata <= "1011111111111111";
 	  		when "101100" => romdata <= "1110111111111111";
		-- remaining NEPs
 	  		when "101101" => romdata <= "1111111101111111";
 	  		when "101110" => romdata <= "1111111101111111";
 	  		when "101111" => romdata <= "1111111101111111";
 	  		when "110000" => romdata <= "1111111101111111";
 	  		when "110001" => romdata <= "1111111101111111";
 	  		when "110010" => romdata <= "1111111101111111";
 	  		when "110011" => romdata <= "1111111111111111";
 	  		when "110100" => romdata <= "1111111111111111";
 	  		when "110101" => romdata <= "1111111111111111";
 	  		when "110110" => romdata <= "1111111111111111";
 	  		when "110111" => romdata <= "1111111111111111";
 	  		when "111000" => romdata <= "1111111111111111";
 	  		when "111001" => romdata <= "1111111111111111";
 	  		when "111010" => romdata <= "1111111111111111";
 	  		when "111011" => romdata <= "1111111111111111";
 	  		when "111100" => romdata <= "1111111111111111";
 	  		when "111101" => romdata <= "1111111111111111";
 	  		when "111110" => romdata <= "1111111111111111";
 	  		when "111111" => romdata <= "1111111111111111";
			when others => Null;
		end case; 

	end process rom; 

 

end Behavioral;
