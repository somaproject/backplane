library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity iphdrchk is
    Port ( CLK : in std_logic;
           DATA : in std_logic_vector(15 downto 0);
           CHECKSUM : out std_logic_vector(15 downto 0);
           RESET : in std_logic;
		 FRESET : in std_logic; 
           START : in std_logic);
end iphdrchk;

architecture Behavioral of iphdrchk is
-- IPHDRCHK : IP Header Checksum Calculator
-- 
-- following the assertion of start, the system keeps a running
-- checksum of the next 10 words that come in. 

	type states is (none, check, done);
	signal cs, ns : states := none; 
	signal len: std_logic_vector(4 downto 0) := "00000";
	signal sum: std_logic_vector(15 downto 0) := "0000000000000000";





begin

	checksum <= sum; 
	clock: process(CLK, ns, cs, len, sum, reset, start) is
	begin
		if RESET = '1' then
			cs <= none; 
		else
			if rising_edge(CLK) then
				cs <= ns; 

				if cs = none then 	
					len <= "00000";
					sum <= (others => '0');
				elsif cs = check then
					len <= len + 1; 
					if not (len = "00011") then
						sum <= DATA + sum;
					end if; 
				end if; 
			end if;	   
		end if; 		   
	end process clock; 

	fsm: process(CLK, CS, freset, start, len) is
	begin
		case CS is
			when none => 
				if start = '1' then
					ns <= check;
				else
					ns <= none;
				end if;
			when check =>
				if len = "01001" then
					ns <= done;
				else
					ns <= check;
				end if;
			when done =>
				if freset = '1' then
					ns <= none;
				else
					ns <= done;
				end if;

			when others => 
				ns <= none;
		end case; 
	end process fsm; 



end Behavioral;
