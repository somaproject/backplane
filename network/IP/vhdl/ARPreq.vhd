library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARPreq is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           DOUTEN : out std_logic;
           SRCMAC : in std_logic_vector(47 downto 0);
           SRCIP : in std_logic_vector(31 downto 0);
           DESTIP : in std_logic_vector(31 downto 0);
           DONE : out std_logic;
           START : in std_logic);
end ARPreq;

architecture Behavioral of ARPreq is
-- ARPREQ.VHD -- ARP request generator. 
	signal sm : std_logic_vector(47 downto 0) := (others => '0');
	signal sip, dip : std_logic_vector(31 downto 0) := (others =>'0'); 

	signal muxcnt : std_logic_vector(5 downto 0) := (others => '0'); 
	signal dmux : std_logic_vector(15 downto 0) := (others => '0');

	type states is (none, output, endarp);
	signal cs, ns : states := none; 

begin
	
	dmux <= X"0020" when muxcnt = "000000" else
		   X"FFFF" when muxcnt = "000001" else
		   X"FFFF" when muxcnt = "000010" else
		   X"FFFF" when muxcnt = "000011" else
		   sm(15 downto 0) when muxcnt = "000100" else
		   sm(31 downto 16) when muxcnt = "000101" else
		   sm(47 downto 32) when muxcnt = "000110" else
		   X"0608" when muxcnt = "000111" else
		   X"0100" when muxcnt = "001000" else
		   X"0008" when muxcnt = "001001" else
		   X"0406" when muxcnt = "001010" else
		   X"0100" when muxcnt = "001011" else
		   sm(15 downto 0) when muxcnt = "001100" else
		   sm(31 downto 16) when muxcnt = "001101" else
		   sm(47 downto 32) when muxcnt = "001110" else
		   sip(31 downto 16) when muxcnt = "001111" else
		   sip(15 downto 0) when muxcnt = "010000" else
		   X"0000" when muxcnt = "010001" else
		   X"0000" when muxcnt = "010010" else
		   X"0000" when muxcnt = "010011" else
		   dip(31 downto 16) when muxcnt = "010100" else
		   dip(15 downto 0) when muxcnt = "010101" else
		   X"0000" ;	

	clock : process(CLK, RESET) is
	begin
		if RESET = '1' then
			cs <= none; 
		else
			if rising_edge(CLK) then
				cs <= ns; 
				if cs = none then	
					muxcnt <= (others => '0');
				else
					if cs = output then 
						muxcnt <= muxcnt + 1; 
					end if; 
				end if; 

				if cs = output then 
					DOUTEN <= '1';
				else
					DOUTEN <= '0';
				end if; 

				DOUT <= dmux; 

				if cs = endarp then
					DONE <= '1';
				else
					DONE <= '0';
				end if; 

				-- input latching
				sm <= SRCMAC;
				sip <= SRCIP; 
				dip <= DESTIP; 



			end if; 
		end if; 

	end process clock;
	
	fsm : process(cs, START, muxcnt) is
	begin
		case cs is 
			when none =>
				if START = '1' then
					ns <= output;
				else
					ns <= none;
				end if; 
			when output => 
				if muxcnt = "100010" then
					ns <= endarp;
				else
					ns <= output; 
				end if; 
			when endarp =>
				ns <= none;
			when others =>
				ns <= none; 
		end case; 
	end process;  
	

end Behavioral;
