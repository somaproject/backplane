
-- VHDL Test Bench Created from source file iptx.vhd -- 22:03:15 12/14/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY iptxtest IS
END iptxtest;

ARCHITECTURE behavior OF iptxtest IS 

	COMPONENT iptx
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		LEN : IN std_logic_vector(15 downto 0);
		SRCMAC : IN std_logic_vector(47 downto 0);
		PROTO : IN std_logic_vector(7 downto 0);
		SUBNET : IN std_logic_vector(15 downto 0);
		SRCIP : IN std_logic_vector(15 downto 0);
		DESTIP : IN std_logic_vector(15 downto 0);
		DATA : IN std_logic_vector(15 downto 0);
		LATENCY : IN std_logic_vector(3 downto 0);
		PKTPENDING : IN std_logic;
		ARPPENDING : IN std_logic;
		ARPHIT : IN std_logic;
		ARPDONE : IN std_logic;
		ARPMAC : IN std_logic_vector(15 downto 0);          
		DEN : OUT std_logic;
		DOUT : OUT std_logic_vector(15 downto 0);
		DOUTEN : OUT std_logic;
		SETARPPENDING : OUT std_logic;
		PKTDONE : OUT std_logic;
		NEXTAPP : OUT std_logic;
		ARPVERIFY : OUT std_logic;
		ARPIP : OUT std_logic_vector(31 downto 0);
		ARPADDR : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL RESET :  std_logic := '1';
	SIGNAL LEN :  std_logic_vector(15 downto 0);
	SIGNAL SRCMAC :  std_logic_vector(47 downto 0);
	SIGNAL PROTO :  std_logic_vector(7 downto 0);
	SIGNAL SUBNET :  std_logic_vector(15 downto 0);
	SIGNAL SRCIP :  std_logic_vector(15 downto 0);
	SIGNAL DESTIP :  std_logic_vector(15 downto 0);
	SIGNAL DATA :  std_logic_vector(15 downto 0);
	SIGNAL DEN :  std_logic;
	SIGNAL LATENCY :  std_logic_vector(3 downto 0);
	SIGNAL DOUT :  std_logic_vector(15 downto 0);
	SIGNAL DOUTEN :  std_logic;
	SIGNAL PKTPENDING :  std_logic;
	SIGNAL ARPPENDING :  std_logic;
	SIGNAL SETARPPENDING :  std_logic;
	SIGNAL PKTDONE :  std_logic;
	SIGNAL NEXTAPP :  std_logic;
	SIGNAL ARPHIT :  std_logic;
	SIGNAL ARPDONE :  std_logic;
	SIGNAL ARPVERIFY :  std_logic;
	SIGNAL ARPIP :  std_logic_vector(31 downto 0);
	SIGNAL ARPMAC :  std_logic_vector(15 downto 0);
	SIGNAL ARPADDR :  std_logic_vector(1 downto 0);

BEGIN

	uut: iptx PORT MAP(
		CLK => CLK,
		RESET => RESET,
		LEN => LEN,
		SRCMAC => SRCMAC,
		PROTO => PROTO,
		SUBNET => SUBNET,
		SRCIP => SRCIP,
		DESTIP => DESTIP,
		DATA => DATA,
		DEN => DEN,
		LATENCY => LATENCY,
		DOUT => DOUT,
		DOUTEN => DOUTEN,
		PKTPENDING => PKTPENDING,
		ARPPENDING => ARPPENDING,
		SETARPPENDING => SETARPPENDING,
		PKTDONE => PKTDONE,
		NEXTAPP => NEXTAPP,
		ARPHIT => ARPHIT,
		ARPDONE => ARPDONE,
		ARPVERIFY => ARPVERIFY,
		ARPIP => ARPIP,
		ARPMAC => ARPMAC,
		ARPADDR => ARPADDR
	);

   CLK <= not CLK after 8 ns; 
   RESET <= '0' after 15 ns; 

-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
