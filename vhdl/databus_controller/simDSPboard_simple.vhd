library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simDSPboard_simple is
    Port ( CLK : in std_logic;
           SYSDATA : out std_logic_vector(15 downto 0);
           DEN : in std_logic;
           DACK : out std_logic);
end simDSPboard_simple;

architecture Behavioral of simDSPboard_simple is
-- simDSPboard_simple.vhdl
--  Really simple simulation of the DSPboard


 	constant Tout : time := 10 ns; 

begin

	process is
	begin
		while (1 = 1) loop
			DACK <= 'Z' after Tout;
			SYSDATA <=  (others => 'Z') after Tout; 
			wait until rising_edge(CLK) and DEN = '0';
			wait until rising_edge(CLK) and DEN = '0';
			wait until rising_edge(CLK) and DEN = '0';
			for i in 0 to 15 loop
			  DACK <= '0' after Tout; 
			  SYSDATA <= conv_std_logic_vector(i, 16) after Tout; 
			  wait until rising_edge(CLK); 			
			end loop; 
			DACK <= '1' after Tout; 
			wait until rising_edge(CLK) and DEN = '1'; 
		end loop;


	end process; 


end Behavioral;
