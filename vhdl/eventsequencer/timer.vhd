library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity timer is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           TINCEXT : in std_logic;
           TCLREXT : in std_logic;
           TSEL : in std_logic;
           TINC : out std_logic;
           TCLR : out std_logic;
			  TCLRTEST: out std_logic; 
           DATA : inout std_logic_vector(15 downto 0);
           ADDR : inout std_logic_vector(7 downto 0);
			  EVENT : in std_logic;
           CE : in std_logic);				  
end timer;

architecture Behavioral of timer is
-- TIMER.VHD -- system timer 
--   Here is where system timestamps are taken care of. 
--   We place an event on the event bus for each tick. 
	
	signal tincint, tclrint, treset, tincmux, tclrmux : std_logic := '0';
	signal newevent : std_logic := '0'; 
	signal cmd : std_logic_vector(15 downto 0) := "0000000000000000";
	signal timeval, timeval_l : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal send_evt, inc: std_logic := '0'; 
	signal eventin: std_logic_vector(79 downto 0) := (others => '0');
	type states is (none, inc_count, send_event, waiting);
	signal cs, ns : states := none;

	component time_generator is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           TINC : out std_logic;
	           TCLR : out std_logic);
	end component;

	component event_receive is
		 Generic (eventid :std_logic_vector(5 downto 0));
	    Port ( CLK : in std_logic;
	           EVENT : in std_logic;
	           CE : in std_logic;
				  RESET : in std_logic;
	           DATA : in std_logic_vector(15 downto 0);
	           ADDR : in std_logic_vector(7 downto 0);
				  CMD : out std_logic_vector(15 downto 0);
				  NEWEVENT : out std_logic;
				  D0 : out std_logic_vector(31 downto 0);
				  D1 : out std_logic_vector(31 downto 0));
	end component;

	component event_transmit is
	    Port ( CLK : in std_logic;
	           EVENTIN : in std_logic_vector(79 downto 0);
				  RESET: in std_logic; 
	           ADDRIN : in std_logic_vector(39 downto 0);
	           NEWEVENT : in std_logic;
	           PENDING : out std_logic;
	           DATA : out std_logic_vector(15 downto 0);
	           ADDR : out std_logic_vector(7 downto 0); 
	           CE : in std_logic);
	end component;

begin

	-- instantiate time generator
   time_gen: time_generator port map (
			CLK => CLK,
			RESET => treset,
			TINC => tincint,
			TCLR => tclrint
			);

	event_receiver: event_receive 
		generic map (
			eventid => "100100")
		port map (
			CLK => CLK,
			RESET => RESET,
			EVENT => EVENT,
			CE => CE,
			DATA => DATA,
			ADDR => ADDR,
			CMD =>  cmd,
			NEWEVENT => newevent) ; 
	
	event_transmitter: event_transmit port map (
			CLK => CLK,
			EVENTIN => eventin,
			RESET => RESET,
			ADDRIN => "1111111111111111111111111111111111111111",
			NEWEVENT => send_evt,
			pending => open,
			DATA => data,
			ADDR => addr,
			CE => ce);
				
   eventin(79 downto 64) <= "1000000000000001";
	eventin(63 downto 32) <= timeval;
	eventin(31 downto 0) <= (others => '0');
	 


	-- select from internal or external time generation
		tincmux <= tincint when tsel = '0' else
					  tincext when tsel = '1';
		TINC <= tincmux;
		tclrmux <= tclrint when tsel = '0' else
					  tclrext when tsel = '1';
		TCLR <= tclrmux;

	--	tclrtest <= newevent; 
	-- code for the event receiver to reset
	   treset <= '1' when (newevent = '1' and cmd = "1000000000000000") else
					 '0';
	

	-- main clocks
	clock: process(CLK, ns, inc, tclrmux) is
	begin
		if RESET = '1' then
			cs <= none;
			timeval <= (others => '0'); 
		else
			if rising_edge(CLK) then
				if inc = '1' then
					if tclrmux = '1' then
						timeval <= (others => '0');
					else
						timeval <= timeval + 1;
					end if; 
				end if; 



				cs <= ns; 
			end if; 
			
		end if;
	end process clock; 

	fsm: process(cs, tincmux) is
	begin
	   case cs is
			when none =>
				inc <= '0';
				send_evt <= '0';
				if tincmux = '1' then
					ns <= inc_count;
				else
					ns <= none;
				end if;
			when inc_count =>
				inc <= '1';
				send_evt <= '0';
				ns <= send_event;
			when send_event =>
				inc <= '0';
				send_evt <= '1';
				ns <= waiting;
			when waiting =>
				inc <= '0';
				send_evt <= '0';
				if tincmux = '0' then
					ns <= none;
				else
					ns <= waiting;
				end if;
			when others =>
				inc <= '0';
				send_evt <= '0';
				ns <= none; 
		end case;			
	end process fsm; 

end Behavioral;
