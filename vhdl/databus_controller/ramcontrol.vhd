library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity ramcontrol is
    Port ( CLK : in std_logic;
           CLK2X : out std_logic;
           RDATAR : out std_logic_vector(15 downto 0);
           RDATAW : in std_logic_vector(15 downto 0);
           RADDRR : in std_logic_vector(19 downto 0);
           RADDRW : in std_logic_vector(19 downto 0);
           RWE : in std_logic;
           WE : out std_logic;
		 RESET : in std_logic;
		 CLK2X_locked: out std_logic; 
		 DATA: inout std_logic_vector(15 downto 0);  
           ADDR : out std_logic_vector(19 downto 0));
end ramcontrol;

architecture Behavioral of ramcontrol is
-- ramcontrol.vhd -- ZBT/NoBL pipelined ram controller. Basically multiplexe
-- the reading and writin of the ram, using a double-clocked CLK2X
-- Uses a two-state FSM with two states, R and W

type states is (R, W);
signal cs, ns : states := R;

signal addrsel, wen, oe : std_logic := '0';
signal raddrrl, raddrwl : std_logic_vector(19 downto 0);
signal rdatawl, rdatawll: std_logic_vector(15 downto 0); 
signal rwel : std_logic;
signal clk2x_dll, locked2x, clk2x_g: std_logic; 

begin

  dll2x  : CLKDLL port map (CLKIN=>clk,   CLKFB=>CLK2X_g, RST=>reset,
                  CLK0=>open,   CLK90=>open, CLK180=>open, CLK270=>open,
                  CLK2X=>CLK2X_dll, CLKDV=>open, LOCKED=>LOCKED2X);

	clk2xg : BUFG   port map (I=>CLK2X_dll,   O=>CLK2X_g);

   clk2x <= clk2x_dll;
   CLK2X_LOCKED <= LOCKED2X; 
   fastclock: process(clk2x_dll, RESET, locked2X) is
   begin
   	if RESET = '1' or locked2x = '0' then
		cs <= R;
	else
		if rising_edge(clk2x_dll) then
			cs <= ns; 


		end if;
	end if;
    end process fastclock;

    clock: process(CLK, raddrr, raddrw, rdatawl, rwe) is
    begin
	if rising_edge(CLK) then
		raddrrl <= raddrr;
		raddrwl <= raddrw;
		rdatawll <= rdatawl;
		rwel <= rwe; 		
		rdatar <= data; 
	 	rdatawl <= rdataw; 
	end if;     	
   end process clock; 

	fsm: process(CLK, cs) is
	begin
		case cs is
			when R => 
				wen <= '1';
				oe <= '0';
				addrsel <= '0';
				ns <= W;
			when W =>
				wen <= '0';
				oe <= '1';
				addrsel <= '1';
				ns <= R;
			when others =>
				wen <= '0';
				oe <= '1';
				addrsel <= '1';
				ns <= R;
		end case;				   
	end process fsm;    	


-- general combinational logic:
	ADDR <= raddrrl when addrsel = '0' else
		raddrwl;
	WE <= rwel or wen; 
	DATA <= rdatawll when oe = '1'
	 		else (others => 'Z');


end Behavioral;
