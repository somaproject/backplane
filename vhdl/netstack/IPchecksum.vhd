library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IPchecksum is
    Port ( CLK : in std_logic;
           DATA : in std_logic_vector(15 downto 0);
           CHKEN : in std_logic;
           RESET : in std_logic;
           CHECKSUM : out std_logic_vector(15 downto 0));
end IPchecksum;

architecture Behavioral of IPchecksum is
-- IPchecksum.vhd -- checksum calculator for all classes of
-- protocols for IP. There's an RFC about this someplace...

signal bsum : std_logic_vector(31 downto 0) := (others => '0');
signal sum : std_logic_vector(15 downto 0) := "0000000000000000";

begin 
    main: process(CLK, DATA, CHKEN, RESET, sum) is
    begin
    	  if rising_edge(CLK) then
		if RESET = '1' then
			bsum <= (others => '0');
		else
			if CHKEN = '1' then
				bsum <= bsum + ("0000000000000000" & data);  
			end if;
		end if;
	  end if;
	end process main; 

	  	
	CHECKSUM <= bsum(15 downto 0) + bsum(31 downto 16);  

end Behavioral;
