library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity event_transmit is
    Port ( CLK : in std_logic;
           EVENTIN : in std_logic_vector(79 downto 0);
			  RESET: in std_logic; 
           ADDRIN : in std_logic_vector(39 downto 0);
           NEWEVENT : in std_logic;
           PENDING : out std_logic;
           DATA : out std_logic_vector(15 downto 0);
           ADDR : out std_logic_vector(7 downto 0);

           CE : in std_logic);
end event_transmit;

architecture Behavioral of event_transmit is
-- EVENT_TRANSMIT.VHD -- reference design for event transmission
--     This uses the external 20 MHz clock to place the event on the
--     event bus

	type states is (none, eventlatch, xmit_pend, out1, out2, out3, out4, out5);
	signal cs, ns : states := none;
	
	signal levent: std_logic;
	signal oe, eventce : std_logic;
	signal addrout: std_logic_vector(7 downto 0);
	signal dataout: std_logic_vector(15 downto 0);
	signal eventl : std_logic_vector(79 downto 0);
	signal addrl : std_logic_vector(39 downto 0);


begin
   --outnumout <= outnum;
	-- tristate of outpus
	ADDR <= addrout when oe='1' else (others => 'Z');
	DATA <= dataout when oe='1' else (others => 'Z');


	clock: process(CLK, eventce, EVENTIN, ADDRIN, cs, ns) is
	begin
		if RESET = '1' then 
			cs <= none;
		else
			if rising_edge(CLK) then


				cs <= ns; 


			 	if eventce = '1' then
					eventl <= EVENTIN;
					addrl <= ADDRIN; 
				end if; 
			end if; 
		end if;
	end process clock;


	fsm: process(cs, newevent, ce, eventl, addrl) is 
	begin
		case cs is
			when none =>
				oe <= '0';
				pending <= '0';
				eventce <= '0';				
				dataout <= eventl(15 downto 0);		
				addrout <= addrl(7 downto 0);
				if NEWEVENT = '1' then
					ns <= eventlatch;
				else
					ns <= none;
				end if; 
			when eventlatch =>
				oe <= '0';
				pending <= '0';
				eventce <= '1';
				dataout <= eventl(15 downto 0);		
				addrout <= addrl(7 downto 0);
				ns <= xmit_pend; 
			when xmit_pend =>
				oe <= '0';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(15 downto 0);		
				addrout <= addrl(7 downto 0);
				if CE = '0' then
					ns <= out1;
				else
					ns <= xmit_pend;
				end if; 
			when out1 =>
				oe <= '1';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(15 downto 0);		
				addrout <= addrl(7 downto 0);
				ns <= out2; 
			when out2 =>
				oe <= '1';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(31 downto 16);		
				addrout <= addrl(15 downto 8);
				ns <= out3; 
			when out3 =>
				oe <= '1';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(47 downto 32);		
				addrout <= addrl(23 downto 16);
				ns <= out4; 
			when out4 =>
				oe <= '1';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(63 downto 48);		
				addrout <= addrl(31 downto 24);
				ns <= out5; 
			when out5 =>
				oe <= '1';
				pending <= '1';
				eventce <= '0';
				dataout <= eventl(79 downto 64);		
				addrout <= addrl(39 downto 32);
				ns <= none;
			when others =>
				oe <= '0';
				pending <= '0';
				eventce <= '0';
				dataout <= (others => '0');
				addrout <= (others => '0');
				ns <= none;
		end case; 

	end process fsm; 
		

end Behavioral;
