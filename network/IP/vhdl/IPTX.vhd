library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IPTX is
    Generic ( IPN : integer := 4;
    		    ARPSIZE: integer := 5); 
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           LEN : in std_logic_vector(15 downto 0);
           SRCMAC : in std_logic_vector(47 downto 0);
           PROTO : in std_logic_vector(7 downto 0);
           SUBNET : in std_logic_vector(31-(4*IPN) downto 0);
           SRCIP : in std_logic_vector((4*IPN -1) downto 0);
           DESTIP : in std_logic_vector((4*IPN -1) downto 0);
           DATA : in std_logic_vector(15 downto 0);
		 DEN : out std_logic; 
           LATENCY : in std_logic_vector(3 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           DOUTEN : out std_logic := '0';
           PKTPENDING : in std_logic;
           ARPPENDING : in std_logic;
           SETARPPENDING : out std_logic;
           PKTDONE : out std_logic;
           NEXTAPP : out std_logic;
		 ARPHIT : in std_logic;
		 ARPDONE : in std_logic;
		 ARPVERIFY : out std_logic;
		 ARPIP :  out std_logic_vector(31 downto 0);
           ARPMAC : in std_logic_vector(15 downto 0);
           ARPADDR : out std_logic_vector(1 downto 0));
end IPTX;

architecture Behavioral of IPTX is
-- IPTX.VHD  -- Our basic IP stack, which uses a giant mux to send
-- the packets over the standard network interface. 

	-- main registers
	signal flen : std_logic_vector(15 downto 0) := (others =>'0');
	signal  destmacl : std_logic_vector(47 downto 0) 
		:= (others => '0');
	signal destmac : std_logic_vector(15 downto 0) := (others => '0'); 
	signal srcmacl : std_logic_vector(47 downto 0) := (others => '0');
	signal plen : std_logic_vector(15 downto 0) := (others => '0');
	signal protol: std_logic_vector(7 downto 0) := (others => '0');
	signal hsum : std_logic_vector(15 downto 0) := (others => '0');
	signal srcipl : std_logic_vector(31 downto 0) := (others => '0');
	signal destipl : std_logic_vector(31 downto 0) := (others => '0');
	signal datal : std_logic_vector(15 downto 0 ) := (others => '0');

	signal lenl : std_logic_vector(15 downto 0) := (others => '0');

	signal mlen, mmen, mhen : std_logic := '0';
	signal bcast : std_logic := '0';

	-- counters
	signal framecnt : std_logic_vector(15 downto 0) := (others => '0');
	signal muxcnt, hdrcnt : std_logic_vector(4 downto 0) := (others => '0');

	-- mux-related:
	signal dmux, dmuxl : std_logic_vector(15 downto 0)	
		:= (others => '0');

	-- ip-checksum
	signal sum, suml : std_logic_vector (31 downto 0) 
		:= (others => '0');

	-- control signals
	signal cntsel, frameen, frameenl, frameenll, 
		hdren, hdrenl, hdrenll : std_logic := '0';


	-- arp interface
	signal arprdone, arprstart, arpen : std_logic := '0';
	signal arpdout : std_logic_vector(15 downto 0) := (others => '0');
		
	-- state machine
	type states is (napp, chkstate, newpkt, arpquery, arpwait, 
		arprbegin, arprwait, arprsetp, wmacl, wmacm, wmach, wbcast,
		calchdr, writepkt, setdone);
	signal cs, ns : states := napp; 

     signal muxaddr: std_logic_vector(4 downto 0) := (others => '0');


	component ARPreq is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           DOUT : out std_logic_vector(15 downto 0);
	           DOUTEN : out std_logic;
	           SRCMAC : in std_logic_vector(47 downto 0);
	           SRCIP : in std_logic_vector(31 downto 0);
	           DESTIP : in std_logic_vector(31 downto 0);
	           DONE : out std_logic;
	           START : in std_logic);
	end component;


begin
	
	ARPrequest: ARPreq port map (
		CLK => CLK,
		RESET => RESET, 
		DOUT => arpdout,
		DOUTEN => arpen,
		SRCMAC => srcmacl,
		SRCIP => srcipl,
		DESTIP => destipl,
		DONE => arprdone,
		START => arprstart); 

	-- mac combinational
	bcast <= '1' when destipl(4*IPN -1 downto 0) = X"FFFF" else '0';
									   
	destmac <= X"FFFF" when bcast = '1' else ARPMAC; 

	-- ip checksum
	sum <= (X"0000" & dmuxl) + suml; 

	dmux <= flen when muxaddr = "00000" else 
		   destmacl(15 downto 0) when muxaddr = "00001" else 
		   destmacl(31 downto 16) when muxaddr = "00010" else 
		   destmacl(47 downto 32) when muxaddr = "00011" else 
		   srcmacl(15 downto 0) when muxaddr = "00100" else 
		   srcmacl(31 downto 16) when muxaddr = "00101" else 
		   srcmacl(47 downto 32) when muxaddr = "00110" else 
		   X"0008" when muxaddr = "00111" else 
		   X"0045" when muxaddr = "01000" else 
		   (plen(7 downto 0) & plen(15 downto 8))  when muxaddr = "01001" else 
		   X"0000" when muxaddr = "01010" else 
		   X"0040" when muxaddr = "01011" else 
		   protol & X"40" when muxaddr = "01100" else 
		   hsum when muxaddr = "01101" else 
		   srcipl(23 downto 16) & srcipl(31 downto 24) when muxaddr = "01110" else 
		   srcipl(7 downto 0) & srcipl(15 downto 8) when muxaddr = "01111" else 
		   destipl(23 downto 16) & destipl(31 downto 24) when muxaddr = "10000" else 
		   destipl(7 downto 0) & destipl(15 downto 8) when muxaddr = "10001" else 
		   datal; 
			
	 

	clock: process(CLK, RESET) is
	begin
		if RESET = '1' then
			cs <= napp; 
		else
			if rising_edge(CLK) then
				cs <= ns; 

				-- basic input registers:
				if cs = newpkt then
					lenl <= LEN;
				end if; 
				
				flen <= lenl + 34;

				if mlen = '1' then 
					destmacl(15 downto 0) <= destmac;
				end if; 
				if mmen = '1' then
					destmacl(31 downto 16) <= destmac;
				end if;
				if mhen = '1' then
					destmacl(47 downto 32) <= destmac;
				end if; 

				srcmacl <= SRCMAC; 
				plen <= lenl + 20; 

				if cs = newpkt then
					protol <= PROTO;
				end if; 

				if cs = newpkt then	
					hsum <= (others => '0');
				else
					if muxcnt = "00101" then
						hsum <= sum(15 downto 0) + sum(31 downto 16);
					end if;
				end if; 

				srcipl <= SUBNET & SRCIP;
				if cs = newpkt then
					destipl <= SUBNET & DESTIP; 
				end if; 

				datal <= data;  
					 
				if muxcnt > ("10000" - ('0' & LATENCY)) then
					DEN<= '1';
				else
					DEN <= '0';
				end if; 
				
				hdrenl <= hdren; 
				hdrenll <= hdrenl;
				
				frameenl <= frameen;
				frameenll <= frameenl;

				if cntsel = '0' then
					muxaddr <= muxcnt;
					DOUTEN <= frameenll; 
					DOUT <= dmuxl;
				else	
					muxaddr <= hdrcnt;
					DOUTEN <= arpen; 
					DOUT <= arpdout; 
				end if; 

				dmuxl <= DMUX; 

				if cs = newpkt then 
					suml <= (others => '0');
				else
					if hdrenll = '1' then
						suml <= sum + suml;
					end if; 
				end if; 

				-- counters
				if cs = arpquery then
					framecnt <= flen; 
				else
					if frameen = '1' then 
						framecnt <= framecnt - 1; 
					end if; 
				end if; 

 				if cs = newpkt then 
					muxcnt <= (others => '0');
				else
					if frameen = '1' then
						if muxcnt /= "10010" then
							muxcnt <= muxcnt + 1;
						end if; 
					end if;
				end if; 

 				if cs = newpkt then 
					hdrcnt <= "01000";
				else
					if hdren = '1' then
						hdrcnt <= hdrcnt + 1;
					end if;
				end if; 

				ARPIP <= destipl;  

			end if;
		end if; 
	end process clock;
	
	
	fsm : process(cs, pktpending, arppending, bcast, ARPDONE, ARPHIT,
				 hdrcnt, arprdone) is
		begin
			case cs is 
				when napp => 
					NEXTAPP <= '1';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= chkstate; 

				when chkstate => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					if PKTPENDING = '1' or ARPPENDING = '1' then
						ns <= newpkt;
					else
						ns <= napp;
					end if; 
				
				when newpkt => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= arpquery; 
				 
				when arpquery => 
					NEXTAPP <= '0';
					ARPVERIFY <= '1';
					hdren <= '1';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					if bcast = '1' then
						ns <= wbcast; 
					else
						ns <= arpwait; 
					end if; 
				 
				
				when wbcast => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '1';
					mmen <= '1';
					mhen <= '1';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= calchdr; 

				when arpwait => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					if ARPDONE = '1' then
						if ARPHIT = '1' then
							ns <= wmacl;
						else
							ns <= arprbegin;
						end if; 
					else
						ns <= arpwait; 
					end if;
					 
				when arprbegin => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '1';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '1';
					setarppending <= '0';
					arprstart <= '1';
					ns <= arprwait; 

				when arprwait => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '1';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '1';
					setarppending <= '0';
					arprstart <= '0';
					if arprdone = '1' then
						ns <= arprsetp;
					else
						ns <= arprwait; 
					end if; 

				when arprsetp => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '1';
					setarppending <= '1'; 
					arprstart <= '0';
					ns <= napp; 

				when wmacl => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '1';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "01";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= wmacm; 

				when wmacm => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '0';
					mmen <= '1';
					mhen <= '0';
					ARPADDR <= "10";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= wmach; 

				when wmach => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '0';
					mmen <= '0';
					mhen <= '1';
					ARPADDR <= "01";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= calchdr; 

				when calchdr => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '1';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					if hdrcnt = "10001" then
						ns <= writepkt;
					else
						ns <= calchdr; 
					end if; 

				when writepkt => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '1';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					if framecnt = X"0000" then
						ns <= setdone;
					else
						ns <= writepkt; 
					end if; 

				when setdone => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '1';
					cntsel <= '0';
					setarppending <= '0'; 
					arprstart <= '0';
					ns <= napp; 
				 
				when others => 
					NEXTAPP <= '0';
					ARPVERIFY <= '0';
					hdren <= '0';
					mlen <= '0';
					mmen <= '0';
					mhen <= '0';
					ARPADDR <= "00";
					cntsel <= '0';
					frameen <= '0';
					PKTDONE <= '0';
					cntsel <= '0';
					setarppending <= '0';
					arprstart <= '0';
					ns <= napp; 
			end case; 
		end process fsm;  

end Behavioral;
