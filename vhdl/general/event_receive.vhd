library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity event_receive is
	 Generic (eventid :std_logic_vector(5 downto 0) := "001000");
    Port ( CLK : in std_logic;
           EVENT : in std_logic;
           CE : in std_logic;
           DATA : in std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(7 downto 0);
			  CMD : out std_logic_vector(15 downto 0);
			  NEWEVENT : out std_logic;
			  D0 : out std_logic_vector(31 downto 0);
			  D1 : out std_logic_vector(31 downto 0));
end event_receive;

architecture Behavioral of event_receive is
-- event_receive.vhd : reference implementation of event receiver


	signal cnt: std_logic_vector(2 downto 0); 
	signal myevent, eventl,  byteeq, addrbit, addrbitl : std_logic; 
	signal datal : std_logic_vector(79 downto 0);

begin
	byteeq <= '1' when cnt = eventid(5 downto 3) else '0';
	addrbit <= byteeq and addr(conv_integer(eventid(2 downto 0))); 
	myevent <= addrbitl and (not eventl); 
		

	
	main: process(CLK, cnt, byteeq, myevent) is
	begin
		if rising_edge(CLK) then
			eventl <= event; 
			if EVENT = '0' then
				cnt <= "000";
			else
				cnt <= cnt + 1;
			end if; 
			if byteeq = '1' then 
				addrbitl <= addrbit;
			end if; 
	   
 			-- latch in!
			if cnt = "000" then
				datal(15 downto 0) <= data;
			end if; 
			if cnt = "001" then
				datal(31 downto 16) <= data;
			end if; 
			if cnt = "010" then
				datal(47 downto 32) <= data;
			end if; 
			if cnt = "011" then
				datal(63 downto 48) <= data;
			end if; 
			if cnt = "100" then
				datal(79 downto 64) <= data;
			end if; 

			if myevent = '1' then
				cmd <= datal(15 downto 0);
				D0 <= datal(47 downto 16);
				D1 <= datal(79 downto 48);
			end if; 

			newevent <= myevent; 

		end if;


	end process main; 


end Behavioral;
