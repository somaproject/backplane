library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receive is
    Port ( CLK : in std_logic;
           DATA : in std_logic_vector(15 downto 0);
           RFRAME : in std_logic;
           RESET : in std_logic;
           PKTADDR : in std_logic_vector(9 downto 0);
           PKTDATA : out std_logic_vector(15 downto 0);
           PKTDONE : out std_logic;
           VALIDUDP : out std_logic;
           VALIDICMP : out std_logic;
           VALIDARP : out std_logic;
           IPADDR : in std_logic_vector(31 downto 0));
end receive;

architecture Behavioral of receive is
-- RECEIVE.VHD : Network Packet Detection Engine
-- 
-- Receive takes in a frame, and figures out if
--    1. if its for us
--    2. if the checksums are valid
--    3. for okay packets, tells whether they are ARP, UDP, or ICMP
-- and then allows the network engine to read the packets

  type states is (none, lfrmlen, word0, abortdone, abort,
  			   protochk, ipverchk, lippktlen, fragidchk, fragoff, lipproto, iphdrchk,
			   liplen, ipsrcipl, ipsrciph, ipdestipl, ipdestiph, 
			   icmptype, icmpchk, icmpmsg, icmpwait, icmpfrmw, icmpvfy, icmpdone, 
			   udpsport, udpdport, ludplen, udpchk, udpwait, udpfrmw, udpvfy, udpdone, 
			   arpdestw, arpdestipl, arpdestiph, arpset, arpwait, arpdone);
  signal rcs, rns : states := none; 

  signal frmlen, iplen, ipproto, udplen: 
  		std_logic_vector (15 downto 0) := (others => '0');
  signal frmcnt, ipcnt, udpcnt : std_logic_vector(9 downto 0) := (others => '0'); 
  signal pktreset : std_logic := '0';
  
  signal ipaddrl, ipaddrh : std_logic_vector(15 downto 0) := (others => '0'); 

  signal iphdrchksum, udpchksum, icmpchksum: std_logic_vector(15 downto 0);

  signal ipchken, icmpchken, udpchken : std_logic := '0';

  signal we, we00, we01, we10 : std_logic := '0';
  signal pd00, pd10, pd01: std_logic_vector(15 downto 0) := (others => '0');



  -- instantiate necessary components!
  component RAMB4_S16_S16
	  generic (
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000");

	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        RSTA   : in STD_logic;
	        RSTB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (7 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (7 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0)); 
	end component;

	component IPchecksum is
	    Port ( CLK : in std_logic;
	           DATA : in std_logic_vector(15 downto 0);
	           CHKEN : in std_logic;
	           RESET : in std_logic;
	           CHECKSUM : out std_logic_vector(15 downto 0));
	end component;	

begin

	ram_00 : RAMB4_S16_S16 port map (
		DIA => DATA,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => we00,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK,
		CLKB => CLK,
		ADDRA => frmcnt(7 downto 0),
		ADDRB => pktaddr(7 downto 0),
		DOA => open,
		DOB => pd00 ); 
	ram_01 : RAMB4_S16_S16 port map (
		DIA => DATA,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => we01,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK,
		CLKB => CLK,
		ADDRA => frmcnt(7 downto 0),
		ADDRB => pktaddr(7 downto 0),
		DOA => open,
		DOB => pd01 ); 
	ram_10 : RAMB4_S16_S16 port map (
		DIA => DATA,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => we10,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK,
		CLKB => CLK,
		ADDRA => frmcnt(7 downto 0),
		ADDRB => pktaddr(7 downto 0),
		DOA => open,
		DOB => pd10 ); 


	ip_header_checksum: ipchecksum port map (
		CLK => CLK,
		DATA => DATA,
		RESET => pktreset,
		CHKEN => ipchken,
		checksum => iphdrchksum);
	icmp_checksum: ipchecksum port map (
		CLK => CLK,
		DATA => DATA,
		RESET => pktreset,
		CHKEN => icmpchken,
		checksum => icmpchksum);
	udp_checksum: ipchecksum port map (
		CLK => CLK,
		DATA => DATA,
		RESET => pktreset,
		CHKEN => udpchken,
		checksum => udpchksum);


	-- ram data decoders
	we_decode: process(frmcnt, we) is
	begin
		case frmcnt(9 downto 8) is
			when "00" =>
			   we00 <= we;
			   we01 <= '0';
			   we10 <= '0';
			when "01" =>
			   we00 <= '0';
			   we01 <= we;
			   we10 <= '0';
			when "10" =>
			   we00 <= '0';
			   we01 <= '0';
			   we10 <= we;
			when "11" =>
			   we00 <= '0';
			   we01 <= '0';
			   we10 <= '0';
			when others =>
			   we00 <= '0';
			   we01 <= '0';
			   we10 <= '0';
		  end case;
	end process we_decode;	 	

	PKTDATA <= PD00 when PKTADDR(9 downto 8) = "00" else
			 PD01 when PKTADDR(9 downto 8) = "01" else	   
			 PD10 when PKTADDR(9 downto 8) = "10" else
			 PD00;


	clock: process (rcs, rns, rframe, reset) is
	begin
	  if reset = '1' then
	  	rcs <= none;
	  else
	  	if rising_edge(CLK) then
			rcs <= rns; 


			-- counters
			if rcs = lfrmlen then
				frmcnt <= (others => '0');
			else
				frmcnt <= frmcnt + 1;
			end if; 

			if rcs = protochk then
				ipcnt <= (others => '0');
			else
				ipcnt <= ipcnt + 1;
			end if; 

			if rcs = ipdestiph then
				ipcnt <= (others => '0');
			else
				ipcnt <= ipcnt + 1;
			end if; 


			-- latch all the registers
			if rcs = lfrmlen then
				frmlen <= data;
			end if; 

			if rcs = liplen then
				iplen <= data;
			end if;

			if rcs = lipproto then
				ipproto <= data;
			end if;

			if rcs = ludplen then
				udplen <= data;
			end if; 

		end if;
	  end if; 
	end process clock;


 	fsm: process(rcs, rns, RFRAME, frmcnt, data, ipaddrl, ipaddrh, ipproto, 
		frmcnt, frmlen, ipcnt, udpcnt, udplen, iphdrchksum,  icmpchksum,  udpchksum) is
	begin
		case rcs is
			when none => 
				we <= '0';
				validicmp <= '0';
				validudp <= '0';				
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';
				if RFRAME = '1' then
					rns <= lfrmlen;
				else
					rns <= none;
				end if; 
			when lfrmlen => 
				we <= '0';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';
				rns <= word0;
			when word0 => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '1';    
				if frmcnt = "0000000101" then
					rns <= protochk;
				else
					rns <= word0;
				end if; 
			when protochk => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data =  "0000100000000000" then --0x0800
					rns <= ipverchk;
				elsif data = "0000100000000110" then --0x0806
					rns <= arpdestw;
				else 
					rns <= abort; 
				end if; 
			when ipverchk => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = "0100010100000000" then  --0x4500
					rns <= liplen;
				else 
					rns <= abort; 
				end if; 
			when liplen => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = "0000000000000000" then -- 0x0000
					rns <= fragidchk;
				else 
					rns <= abort; 
				end if; 
			when fragidchk => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = "0000000000000000" then -- 0x0000
					rns <= fragoff;
				else 
					rns <= abort; 
				end if; 
			when fragoff => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= lipproto;
			when lipproto => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= iphdrchk;
			when iphdrchk => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= ipsrcipl;
			when ipsrcipl => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= ipsrciph;
			when ipsrciph => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= ipdestipl;
			when ipdestipl => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = ipaddrl then
					rns <= ipdestiph;
				else 
					rns <= abort; 
				end if;
			when ipdestiph => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '1';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = ipaddrh then
					if ipproto = "0000000000000001" then	-- 0x0001
						rns <= icmptype;
					elsif ipproto = "0000000000010111" then -- 0x0017
						rns <= udpsport;
					else 
						rns <= abort;
					end if;
				else 
					rns <= abort; 
				end if;
			when icmptype => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '1';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = "0000100000000000" then --0x0800
					rns <= icmpchk;
				else 
					rns <= abort; 
				end if;		
			when icmpchk => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '1';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= icmpmsg;
			when icmpmsg => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '1';
				udpchken <= '0'; 
				pktreset <= '0';     
				if data = "0000000000000001" then --0x0001
					rns <= icmpwait;
				else 
					rns <= abort; 
				end if;		
			when icmpwait => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '1';
				udpchken <= '0'; 
				pktreset <= '0';     
				if ipcnt >= iplen then
					rns <= icmpfrmw;
				else 
					rns <= icmpwait; 
				end if;	
			when icmpfrmw => 
				we <= '1';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if frmcnt >= frmlen then
					rns <= icmpvfy;
				else 
					rns <= icmpwait; 
				end if;	
			when icmpvfy => 
				we <= '0';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if iphdrchksum = "1111111111111111" and 
					icmpchksum = "1111111111111111"  then
					rns <= icmpdone;  
				else 
					rns <= abort; 
				end if;
			when icmpdone => 
				we <= '0';
				validicmp <= '1';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '1';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= none;
			when abort => 
				we <= '0';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				if frmcnt >= frmlen	then
					rns <= abortdone;  
				else 
					rns <= abort; 
				end if;			
			when abortdone => 
				we <= '0';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= none;
			when others =>
				we <= '0';
				validicmp <= '0';
				validudp <= '0';
				validarp <= '0';
				pktdone <= '0';
				ipchken <= '0';
				icmpchken <= '0';
				udpchken <= '0'; 
				pktreset <= '0';     
				rns <= none;

	    end case; 
	end process fsm; 

end Behavioral;
