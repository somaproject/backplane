library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LUTreserialize is
    Generic (IPN : in integer := 4); 
    Port ( CLK : in std_logic;
           START : in std_logic;
           DONE : out std_logic;
           SOUT : out std_logic_vector(IPN-1 downto 0);
           IPIN : in std_logic_vector(4*IPN-1 downto 0);
           WE : out std_logic);
end LUTreserialize;

architecture Behavioral of LUTreserialize is
-- LUTRESERIALIZE.VHD - Complex module that turns an input 
-- IP (IPIN) into a series of serial outs to program the LUTs
-- in IPmatch. 

   signal cnt : std_logic_vector(3 downto 0) := (others => '0'); 
   
   type states is (none, pending, wdone); 
   signal cs, ns : states := none; 


begin
   comp: for i in 0 to IPN-1 generate
	   	SOUT(i) <= '1' when cnt = IPIN(4*i+3 downto 4*i) else '0';
   end generate; 

   WE <= '1' when cs = pending else '0'; 
   
   main: process(CLK) is
   begin
   	if rising_edge(CLK) then
		cs <= ns;
		if cs = pending then
			if cnt = "1111" then
				cnt <= (others => '0');
			else 
				cnt <= cnt + 1;
			end if;  
		end if; 
	end if; 
   end process main; 


   fsm : process(cs, START, cnt) is
   begin
   	case cs is 
		when none => 
			if START = '1' then
				ns <= pending;
			else
				ns <= none; 
			end if; 
			WE <= '0';
			DONE <= '0';
		when pending=>
			if cnt = "1111" then
				ns <= wdone;
			else 
				ns <= pending;
			end if; 
			WE <= '1';
			DONE <= '0';
		when wdone => 
			ns <= none; 
			WE <= '0';
			DONE <= '1';
		when others => 
			ns <= none;
			WE <= '0';
			DONE <= '0';
	end case;
  end process fsm; 
				
				
end Behavioral;
