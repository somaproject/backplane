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
			  RESET : in std_logic; 
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

	type states is (none, evt1, evt2, evt3, evt4, evt5);
	signal cs, ns : states := none; 
	signal myevent, addrce, addrl : std_logic; 
	signal datal : std_logic_vector(79 downto 0);
	

begin
		
	clock: process(CLK, RESET, cs, ns, addrce, myevent) is
	begin
		if RESET = '1' then
			cs <= none; 
		else
			if rising_edge(CLK) then

	   		 cs <= ns; 
				if addrce = '1' then
					addrl <= ADDR(conv_integer(eventid(2 downto 0))); 
				end if; 
	 			-- latch in!
				if cs = evt1 then
					datal(79 downto 64) <= data;
				end if; 
				if cs = evt2 then
					datal(63 downto 48) <= data;
				end if; 
				if cs = evt3 then
					datal(47 downto 32) <= data;
				end if; 
				if cs = evt4 then
					datal(31 downto 16) <= data;
				end if; 
				if cs = evt5 then
					datal(15 downto 0) <= data;
				end if; 

				if myevent = '1' then
					cmd <= datal(79 downto 64);
					D0 <= datal(63 downto 32);
					D1 <= datal(31 downto 0);
				end if; 

				newevent <= myevent; 

			end if;
		end if; 

	end process clock; 

   fsm: process(CS, EVENT,  addrl) is
	begin
		case CS is 
			when none => 
			   addrce <= '0';
				myevent <= '0';
				if EVENT = '0' then
					ns <= evt1;
				else
					ns <= none;
				end if;
			when evt1 =>
				if eventid(5 downto 3) = "000" then
					ADDRCE <= '1';
				else
					ADDRCE <= '0';
				end if;

				if addrl = '1' then
					myevent <= '1';
				else
					myevent <= '0';
				end if; 

				ns <= evt2;
			when evt2 =>
				if  eventid(5 downto 3)  = "001" then
					ADDRCE <= '1';
				else
					ADDRCE <= '0';
				end if;

				myevent <= '0';
				ns <= evt3;
			when evt3 =>
				if  eventid(5 downto 3)  = "010" then
					ADDRCE <= '1';
				else
					ADDRCE <= '0';
				end if;

				myevent <= '0';
				ns <= evt4;			
			when evt4 =>
				if  eventid(5 downto 3)  = "011" then
					ADDRCE <= '1';
				else
					ADDRCE <= '0';
				end if;

				myevent <= '0';
				ns <= evt5;
			when evt5 =>
				if  eventid(5 downto 3)  = "100" then
					ADDRCE <= '1';
				else
					ADDRCE <= '0';
				end if;

				myevent <= '0';
				
				if EVENT = '0' then
					ns <= evt1;
				else
					ns <= none;
				end if; 
			when others =>
				ADDRCE <= '0';
				myevent <= '0';
				ns <= none;
		end case; 
	end process fsm; 
end Behavioral;
