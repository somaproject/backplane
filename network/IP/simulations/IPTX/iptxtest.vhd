
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all; 
use  ieee.numeric_std.all; 
use std.TextIO.ALL; 


ENTITY iptxtest IS
	generic ( IPN : integer := 4;
			ARPSIZE : integer := 5); 
END iptxtest;

ARCHITECTURE behavior OF iptxtest IS 
	

	COMPONENT iptx	    Generic ( IPN : integer := 4;
    		    ARPSIZE: integer := 5); 

	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		LEN : IN std_logic_vector(15 downto 0);
		SRCMAC : IN std_logic_vector(47 downto 0);
		PROTO : IN std_logic_vector(7 downto 0);
		SUBNET : in std_logic_vector(31-(4*IPN) downto 0);
          SRCIP : in std_logic_vector((4*IPN -1) downto 0);
          DESTIP : in std_logic_vector((4*IPN -1) downto 0);
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
	SIGNAL SUBNET :  std_logic_vector(31-(4*IPN) downto 0);
	SIGNAL SRCIP :  std_logic_vector((4*IPN -1) downto 0);
	SIGNAL DESTIP :  std_logic_vector((4*IPN -1) downto 0);
	SIGNAL DATA :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL DEN :  std_logic;
	SIGNAL LATENCY :  std_logic_vector(3 downto 0);
	SIGNAL DOUT :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL DOUTEN :  std_logic := '0';
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
	signal arpmacval : std_logic_vector(47 downto 0) := (others => '0');
	signal dout_expected : std_logic_vector(15 downto 0)
		:= (others => '0'); 


BEGIN

	uut: iptx GENERIC MAP (
		IPN => IPN,
		ARPSIZE => ARPSIZE)
		 PORT MAP(
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


   inputs: process is
	file cfile, dfile : text;
	variable cL: line;
	variable dL: line;  
	variable arppend, arphitmiss : integer := 0;
	variable plen, lat, protocol : integer := 0;
	variable amac, smac : std_logic_vector(47 downto 0) := (others => '0');
	variable snet, sip, dip : std_logic_vector(31 downto 0) 
		:= (others => '0'); 
	variable do : std_logic_vector(15 downto 0) := (others => '0'); 
	variable datacnt : integer := 0; 

   begin
   	wait until falling_edge(RESET); 
	file_open(cfile, "control.dat", read_mode); 

	wait until rising_edge(CLK); 
	while not endfile(cfile) loop
		wait until rising_edge(CLK) and NEXTAPP = '1'; 
		readline(cfile, cL);

 		-- arp pending 
		read(cL, arppend); 
		if arppend = 0 then 
			ARPPENDING <= '0';
			PKTPENDING <= '1'; 
		else 
			ARPPENDING <= '1';
			PKTPENDING <= '0'; 
		end if; 

 		-- packet length
		read(cL, plen); 
		LEN <=  std_logic_vector(to_unsigned(plen-20, 16)); 
		
		-- protocol
		read(cL, protocol);
		PROTO <= std_logic_vector(to_unsigned(protocol, 8)); 

 		-- latency
		read(cL,  lat); 
		lATENCY <=  std_logic_vector(to_unsigned(lat, 4)); 

		
 		-- arphit
		read(cL,  arphitmiss);
		if arphitmiss = 0 then
			ARPHIT <= '0';
		else
			ARPHIT <= '1';
		end if; 
		
		--  macresponse, which is set in another process
		hread(cL, amac);
		arpmacval <= amac;  

		--  source mac
		hread(cL, smac); 
		SRCMAC <= smac; 

		-- ips
		hread(cL, snet);
		hread(cL, sip); 
		hread(cL, dip); 

		SUBNET <= snet(31 downto (IPN*4)); 
		SRCIP <= sip(IPN*4 - 1 downto 0);
		DESTIP <= dip(IPN * 4 - 1 downto 0); 

		datacnt := 0 - lat; 
		wait until rising_edge(CLK); 
		
		ARPPENDING <= '0';
		PKTPENDING <= '0';

		if arphitmiss = 1 then 
			wait until DEN = '1'; 
			while DEN = '1' and PKTDONE = '0'  loop 
				wait until rising_edge(CLK); 
				datacnt := datacnt + 1;
				if datacnt > 0 then 
					DATA <= std_logic_vector(to_unsigned(datacnt, 16)) after 5 ns;
				end if; 
			end loop; 
		end if; 
		DATA <= X"0000"; 
				  

	end loop; 

	wait for 400 ns; 
	assert false 
		report "End of Simulation"
		severity failure; 
		wait; 
   end process; 


   --arp cache ghettoness

   -- data output reading
   process is
   	variable doutenl : std_logic := '0';
	file dfile : text;
	variable dL: line;  
	variable do : std_logic_vector(15 downto 0) := (others => '0');


   begin
   	wait until falling_edge(RESET);    
	file_open(dfile, "data.dat", read_mode); 
	while not endfile(dfile) loop
		wait until rising_edge(douten); 
		readline(dfile, dL); 
		hread(dL, do);	
		dout_expected <= do;  
		while DOUTEN = '1' loop 
			dout_expected <= do; 		
			wait until rising_edge(CLK);
			if douten = '1' then
				assert do = DOUT 
					report "invalid DOUT"
					severity error; 
				
				
			end if; 
 			hread(dL, do);
		end loop; 
     end loop; 

   end process; 

   process(CLK) is
   	variable av1, av2, av3, av4 : std_logic := '0';
   begin
   	if rising_edge(CLK) then
	
		ARPDONE <= av3;
		av3 := av2;   
		av2 := av1; 
		av1 := arpverify;
		if ARPADDR = "00" then
			ARPMAC <= arpmacval(15 downto 0);
		elsif ARPADDR = "01" then
			ARPMAC <= arpmacval(31 downto 16);
		elsif ARPADDR = "10" then
			ARPMAC <= arpmacval(47 downto 32);
		end if; 
	end if;
   end process; 

END;
