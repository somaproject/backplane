library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IPsum is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           DIN : in std_logic_vector(15 downto 0);
           EN : in std_logic;
           SUMOUT : out std_logic_vector(15 downto 0));
end IPsum;

architecture Behavioral of IPsum is
-- IPSUM.VHD -- pipelined implementation of the IP checksum
-- calculation, ala RFC 1071
	signal sum, suml : std_logic_vector(31 downto 0) := (others => '0');

begin
	
	sum <= suml + (X"0000" & din); 

	process(CLK) is
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				suml <= (others => '0');
			else
				if EN = '1' then
					suml <= sum;
				end if;
			end if;
			
			SUMOUT <= suml(15 downto 0) + suml(31 downto 16);  
		end if;  
	end process; 

end Behavioral;
