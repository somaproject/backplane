library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DSPboardsim is
    Port ( CLK : in std_logic;
           SYSDATA : out std_logic_vector(15 downto 0);
           DACK : out std_logic;
           DEN : in std_logic);
end DSPboardsim;

architecture Behavioral of DSPboardsim is

begin


end Behavioral;
