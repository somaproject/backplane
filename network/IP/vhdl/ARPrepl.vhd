library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARPrepl is
    Port ( CLK : in std_logic;
           RUINA : in std_logic_vector(3 downto 0);
           RUWEA : in std_logic;
           RUINB : in std_logic_vector(3 downto 0);
           RUWEB : in std_logic;
           LRU : out std_logic_vector(3 downto 0));
end ARPrepl;

architecture Behavioral of ARPrepl is
-- ARPrepl : dummy ARP replacement code. 

begin
	


end Behavioral;
