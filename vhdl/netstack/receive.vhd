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
  			   protochk, ipverchk, lippktlen, fragidchk, liproto, liphdrchk,
			   ipsrcipl, ipsrciph, ipdestipl, ipdestiph, 
			   icmptype, icmpchk, icmpmsg, icmp_wait, icmpvfy, icmpdone, 
			   udpsport, udpdport, udplen, udpchk, udpwait, udpvfy, udpdone, 
			   arpdestw, arpdestipl, arpdestiph, arpset, arpwait, arpdone);

  signal frmlen, ippktlen, ipproto, iphdrchk, udpchk, icmpchk : 
  		std_logic_vector (15 downto 0) := (others => '0');
  signal frmcnt : std_logic_vector(9 downto 0) := (others => '0'); 
  signal pktreset : std_logic := '0';
  
  signal iphdrchksum, udpchksum, icmpchksum: std_logic_vector(15 downto 0);

  signal iphdrstart, appchkstart : std_logic := '0';



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
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000")

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

begin

	ram_0 : RAMB4_S16_S16 port map (
		DIA => DATA,
		DIB => PKTDATA,
		ENA => '1',
		ENB => '1',
		WEA => we,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK,
		CLKB => CLK,
		ADDRA =>  	




end Behavioral;
