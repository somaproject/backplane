library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_generator is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           TINC : out std_logic;
           TCLR : out std_logic);
end time_generator;

architecture Behavioral of time_generator is
-- time_generator.vhd
--    This is the time generator. It's actually really simple, there's
--    just a 0-1999 counter (based on the supposition of a 20 MHz clk)
--    that samples on the right times and does things. 

signal counter: integer range 1999 downto 0 := 0  ; 
signal resetarm: std_logic := '0';


begin

	clock: process(CLK, counter, resetarm, RESET) is
	begin
		if rising_edge(CLK) then
			if counter = 1999 then 
				counter <= 0;
			else
				counter <= counter + 1;
			end if; 

			if counter = 1959 then
				TINC <= '1';
			elsif counter = 1979 then
				TINC <= '0';
			end if; 

			if RESET = '1' then 
				resetarm <= '1';
			end if; 

			if counter = 1939 then
				if resetarm = '1' then
					TCLR <= '1';
					resetarm <= '0';
				end if;
			elsif counter = 1999 then
				TCLR <= '0'; 
			end if; 
		end if; 
	end process clock; 


end Behavioral;
