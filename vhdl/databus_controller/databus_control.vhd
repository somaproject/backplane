library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity databus_control is
    Port ( CLK : in std_logic;
           SYSDATA : in std_logic_vector(15 downto 0);
           DACK : in std_logic;
           DEN : out std_logic_vector(15 downto 0);
           RESET : in std_logic;
		 WE : out std_logic;
		 ADDR : out std_logic_vector(19 downto 0);
		 DATA : inout std_logic_vector(15 downto 0); 
		 CLK2X : out std_logic;
		 RDATAR : out std_logic_vector(15 downto 0);
		 RADDRR : in std_logic_vector(19 downto 0) 
		 );
end databus_control;

architecture Behavioral of databus_control is
-- databus_controller.vhd : soma data bus controller
--
-- This module contains the logic and the FSMs to control the data
-- bus over which the bulk of soma data is transferred. It handles
-- activation of the individual cards, and reads the data off
-- the bus and into pipelined ZBT RAM. it also provides the interface
-- by witch the network layer can access stored packets. 

type buscases is (none, nextpkt, pktid_l, pktid_h, chan_1, chan_1s,
			   chan_1w, chan_1d, chan_2, chan_2w, chan_2d,
			   chan_3, chan_3w, chan_3d, chan_4, chan_4w, 
			   chan_4d); 
signal bcs, bns : buscases := none; 


signal datal : std_logic_vector(15 downto 0) := (others => '0');
signal dackl : std_logic;
signal dataencnt : integer range 0 to 15; 
signal denable : std_logic; 
signal pktid : std_logic_vector(31 downto 0) := (others => '0'); 
signal pktidval : std_logic_vector(15 downto 0);
signal rdataw : std_logic_vector(15 downto 0);
signal raddrw : std_logic_vector(19 downto 0);
signal rwe : std_logic := '1'; 
signal pktcnten, pktcntsel : std_logic := '0'; 
signal nextchan, pktidlh : std_logic := '0'; 
signal fsmwe : std_logic := '1'; 
signal dackcnt : integer range 0 to 7 := 0;  
signal clk2x_locked: std_logic := '0';


component ramcontrol is
    Port ( CLK : in std_logic;
           CLK2X : out std_logic;
           RDATAR : out std_logic_vector(15 downto 0);
           RDATAW : in std_logic_vector(15 downto 0);
           RADDRR : in std_logic_vector(19 downto 0);
           RADDRW : in std_logic_vector(19 downto 0);
           RWE : in std_logic;
           WE : out std_logic;
		 RESET : in std_logic;
		 CLK2X_locked : out std_logic; 
		 DATA: inout std_logic_vector(15 downto 0);  
           ADDR : out std_logic_vector(19 downto 0));
end component;


begin

	RAMctl: ramcontrol port map (
		CLK => CLK,
		CLK2X => CLK2X,
		RDATAR => RDATAR,
		RDATAW => rdataw,
		RADDRR => RADDRR,
		RADDRW => raddrw,
		RWE => rwe,
		WE => WE,
		RESET => RESET,
		CLK2X_LOCKED => clk2x_locked, 
		DATA => DATA,
		ADDR => ADDR);

	clock: process(CLK, RESET, DACK, SYSDATA) is
	begin
		if RESET = '1' then
			bcs <= none; 
			pktid <= (others => '0'); 
		else
			if rising_edge(CLK) then
				bcs <= bns; 
				
				-- latch input data
				datal <= SYSDATA;
				dackl <= DACK;
				
				if nextchan = '1' then
					if dataencnt = 15 then
						dataencnt <= 0;
					else
						dataencnt <= dataencnt + 1;
					end if; 
				end if; 

				-- raddrw counter, for 10 lsbs
				if bcs = nextpkt then
					raddrw(9 downto 0) <= (others => '0');
				else
					if (pktcntsel = '1' and pktcnten = '1') or
						(pktcntsel = '0' and dackl = '0') then
						raddrw(9 downto 0) <= raddrw(9 downto 0) + 1;
					end if;
				end if; 
					
				-- DACKCNT counting
				if bcs = pktid_h or bcs = chan_1s or
				   bcs = chan_1d or bcs = chan_2d or
				   bcs = chan_3d or bcs = chan_4d then
				   dackcnt <= 0;
				else
					if dackcnt = 7 then
						dackcnt <= 0;
					else
						dackcnt <= dackcnt + 1;
					end if;
				end if; 	


				-- den decoding
				case dataencnt is 
					when 0 => DEN <= (0 => denable, others => '1');
					when 1 => DEN <= (1 => denable, others => '1');
					when 2 => DEN <= (2 => denable, others => '1');
					when 3 => DEN <= (3 => denable, others => '1');
					when 4 => DEN <= (4 => denable, others => '1');
					when 5 => DEN <= (5 => denable, others => '1');
					when 6 => DEN <= (6 => denable, others => '1');
					when 7 => DEN <= (7 => denable, others => '1');
					when 8 => DEN <= (8 => denable, others => '1');
					when 9 => DEN <= (9 => denable, others => '1');
					when 10=> DEN <= (10=> denable, others => '1');
					when 11=> DEN <= (11=> denable, others => '1');
					when 12=> DEN <= (12=> denable, others => '1');
					when 13=> DEN <= (13=> denable, others => '1');
					when 14=> DEN <= (14=> denable, others => '1');
					when 15=> DEN <= (15=> denable, others => '1');
					when others => DEN <= (others =>'1'); 
				end case; 

				-- pktid counter
				if bcs = nextpkt then
					pktid <= pktid + 1;
				end if; 


			end if; 
		end if; 


	end process clock; 

	-- combinational logic

	rdataw <= datal when denable = '0' else
			pktidval;
	pktidval <= pktid(15 downto 0) when pktidlh = '0' else
			pktid(31 downto 16); 
	raddrw(19 downto 10) <= pktid(9 downto 0); 

	rwe <= dackl when denable = '0' else
		   fsmwe;
	

	fsm: process(bcs, dackcnt, dackl, clk2x_locked) is
	begin
		case bcs is 
			when none => 
				denable <= '1'; 
				pktcntsel <= '1';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '0';
				nextchan <= '0';
				if clk2x_locked = '1' then
					bns <= nextpkt;
				else
					bns <= none;
				end if; 
			when nextpkt => 
				denable <= '1'; 
				pktcntsel <= '1';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '0';
				nextchan <= '0';
				bns <= pktid_l;
			when pktid_l => 
				denable <= '1'; 
				pktcntsel <= '1';
				pktcnten <= '1';
				fsmwe <= '0';
				pktidlh <= '0';
				nextchan <= '0';
				bns <= pktid_h;
			when pktid_h => 
				denable <= '1'; 
				pktcntsel <= '1';
				pktcnten <= '1';
				fsmwe <= '0';
				pktidlh <= '1';
				nextchan <= '0';
				bns <= chan_1;
			when chan_1 => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackcnt = 6 then
					bns <= chan_1s;
				else
					if dackl = '0' then
						bns <= chan_1w;
					else
						bns <= chan_1;
					end if;
				end if; 
			when chan_1s => 
				denable <= '1'; 
				pktcntsel <= '1';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '1';
				bns <= chan_1;
			when chan_1w => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackl = '0' then
					bns <= chan_1w;
				else
					bns <= chan_1d;
				end if; 
			when chan_1d => 
				denable <= '1'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '1';
				bns <= chan_2; 
			when chan_2 => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackcnt = 6 then
					bns <= chan_2d;
				else
					if dackl = '0' then
						bns <= chan_2w;
					else
						bns <= chan_2;
					end if;
				end if; 
			when chan_2w => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackl = '0' then
					bns <= chan_2w;
				else
					bns <= chan_2d;
				end if; 
			when chan_2d => 
				denable <= '1'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '1';
				bns <= chan_3; 
			when chan_3 => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackcnt = 6 then
					bns <= chan_3d;
				else
					if dackl = '0' then
						bns <= chan_3w;
					else
						bns <= chan_3;
					end if;
				end if; 
			when chan_3w => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackl = '0' then
					bns <= chan_3w;
				else
					bns <= chan_3d;
				end if; 
			when chan_3d => 
				denable <= '1'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '1';
				bns <= chan_4;
			when chan_4 => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackcnt = 6 then
					bns <= chan_4d;
				else
					if dackl = '0' then
						bns <= chan_4w;
					else
						bns <= chan_4;
					end if;
				end if; 
			when chan_4w => 
				denable <= '0'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				if dackl = '0' then
					bns <= chan_4w;
				else
					bns <= chan_4d;
				end if; 
			when chan_4d => 
				denable <= '1'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '1';
				bns <= nextpkt;
			when others =>
				denable <= '1'; 
				pktcntsel <= '0';
				pktcnten <= '0';
				fsmwe <= '1';
				pktidlh <= '1';
				nextchan <= '0';
				bns <= none;
		 end case;
				 


	end process fsm; 


end Behavioral;
