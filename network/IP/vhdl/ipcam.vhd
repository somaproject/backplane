library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ipcam is
    Generic ( IPN : integer := 4;
    			ARPSIZE : integer :=5); 
    Port ( CLK : in std_logic;
     	 RESET : in std_logic; 
           IPA : in std_logic_vector(4*IPN-1 downto 0);
           IPQA : in std_logic;
           IPB : in std_logic_vector(4*IPN-1 downto 0);
           IPQB : in std_logic;
           IPWR : in std_logic_vector(4*IPN-1 downto 0);
           WE : in std_logic;
           MADDRWR : in std_logic_vector(ARPSIZE-1 downto 0);
           MATCHOUT : out std_logic;
           MADDROUT : out std_logic);
end ipcam;

architecture Behavioral of ipcam is
-- IPCAM.VHD : Content adresssible memory component of ARP cache
-- which keeps an IP-to-location-in-RAM mapping. There are 2**ARPSIZE
-- cache entries adn IP addresses are assuemd to be 4*IPN long. 

   -- query interfaces
   signal ipal, ipbl, ipwrl : std_logic_vector(4*IPN-1 downto 0)
   	:= (others => '0'); 

   signal ipqap, ipqbp, donea, doneb, wep, donewr : std_logic := '0';
   signal macaddrwrl : std_logic_vector(ARPSIZE-1 downto 0)
   	:= (others =>'0'); 


   -- ipmatch interfaces:
   signal ipin : std_logic_vector(4*IPN-1 downto 0); 
   signal ipmatchsin : std_logic_vector(IPN-1 downto 0); 
   signal ipmatchen, lipmatchen : std_logic_vector(2**ARPSIZE-1 downto 0)
   	:= (others => '0'); 
   signal ipmatchwe : std_logic := '0';
   signal match : std_logic_vector(2**ARPSIZE -1 downto 0)
   	:= (others => '0');

   signal ipsel : std_logic := '0';

   -- output from match:
   signal maddr: std_logic_vector(ARPSIZE -1 downto 0) 
   	:= (others => '0'); 


   -- LUT controls	
   signal ipdisen, ldisable, lstart, ldone: std_logic := '0';
   
   signal outen : std_logic := '0';

   -- FSMs:
   type writestates is (none, disable, wstart, wdone, wwait, wend);
   signal writecs, writens : writestates := none;

   type camstates is (prea, ipselaen, latcha, enda, 
   			endb, latchb, ipselben, preb);
   signal camcs, camns : camstates := prea;
   
   component ipmatch is
    Generic (IPN : in integer := 4);
    Port ( CLK : in std_logic;
           IPIN : in std_logic_vector(4*IPN -1 downto 0);
           SIN : in std_logic_vector(IPN -1 downto 0);
           WE : in std_logic;
           EN : in std_logic;
           MATCH : out std_logic);
	end component;  

	component LUTreserialize is
	    Generic (IPN : in integer := 4); 
	    Port ( CLK : in std_logic;
	           START : in std_logic;
	           DONE : out std_logic;
	           SOUT : out std_logic_vector(IPN-1 downto 0);
	           IPIN : in std_logic_vector(4*IPN-1 downto 0);
	           WE : out std_logic);
	end component;


begin

    -- generate IPMATCH array
    IPMATCHes: for i in 0 to (2**ARPSIZE-1) generate 
	   IPM : ipmatch generic map (
	   	IPN => IPN)
		port map (
		CLK => CLK,
		IPIN => ipin,
		SIN => ipmatchsin,
		WE => ipmatchwe,
		EN => ipmatchen(i),
		MATCH => match(i)); 
    end generate; 

    LUTreserial: LUTreserialize generic map (
    		IPN => IPN)
		port map (
		CLK => CLK,
		START => lstart,
		DONE => ldone,
		SOUT => ipmatchsin,
		IPIN => ipwrl,
		WE => ipmatchwe); 

    ipin <= ipal when ipsel = '0' else ipbl; 

    -- macaddr decoder:
    -- NEED TO MAKE GENERIC DEBUGGING!!!!
    lipmatchen(0) <= '0' when macaddrwl = "00000" and IPDISEN = '1' else '1';
    lipmatchen(1) <= '0' when macaddrwl = "00001" and IPDISEN = '1' else '1';
    lipmatchen(2) <= '0' when macaddrwl = "00010" and IPDISEN = '1' else '1';
    lipmatchen(3) <= '0' when macaddrwl = "00011" and IPDISEN = '1' else '1';
    lipmatchen(4) <= '0' when macaddrwl = "00100" and IPDISEN = '1' else '1';
    lipmatchen(5) <= '0' when macaddrwl = "00101" and IPDISEN = '1' else '1';
    lipmatchen(6) <= '0' when macaddrwl = "00110" and IPDISEN = '1' else '1';
    lipmatchen(7) <= '0' when macaddrwl = "00111" and IPDISEN = '1' else '1';
    lipmatchen(8) <= '0' when macaddrwl = "01000" and IPDISEN = '1' else '1';
    lipmatchen(9) <= '0' when macaddrwl = "01001" and IPDISEN = '1' else '1';
    lipmatchen(10) <= '0' when macaddrwl = "01010" and IPDISEN = '1' else '1';
    lipmatchen(11) <= '0' when macaddrwl = "01011" and IPDISEN = '1' else '1';
    lipmatchen(12) <= '0' when macaddrwl = "01100" and IPDISEN = '1' else '1';
    lipmatchen(13) <= '0' when macaddrwl = "01101" and IPDISEN = '1' else '1';
    lipmatchen(14) <= '0' when macaddrwl = "01110" and IPDISEN = '1' else '1';
    lipmatchen(15) <= '0' when macaddrwl = "01111" and IPDISEN = '1' else '1';
    lipmatchen(16) <= '0' when macaddrwl = "10000" and IPDISEN = '1' else '1';
    lipmatchen(17) <= '0' when macaddrwl = "10001" and IPDISEN = '1' else '1';
    lipmatchen(18) <= '0' when macaddrwl = "10010" and IPDISEN = '1' else '1';
    lipmatchen(19) <= '0' when macaddrwl = "10011" and IPDISEN = '1' else '1';
    lipmatchen(20) <= '0' when macaddrwl = "10100" and IPDISEN = '1' else '1';
    lipmatchen(21) <= '0' when macaddrwl = "10101" and IPDISEN = '1' else '1';
    lipmatchen(22) <= '0' when macaddrwl = "10110" and IPDISEN = '1' else '1';
    lipmatchen(23) <= '0' when macaddrwl = "10111" and IPDISEN = '1' else '1';
    lipmatchen(24) <= '0' when macaddrwl = "11000" and IPDISEN = '1' else '1';
    lipmatchen(25) <= '0' when macaddrwl = "11001" and IPDISEN = '1' else '1';
    lipmatchen(26) <= '0' when macaddrwl = "11010" and IPDISEN = '1' else '1';
    lipmatchen(27) <= '0' when macaddrwl = "11011" and IPDISEN = '1' else '1';
    lipmatchen(28) <= '0' when macaddrwl = "11100" and IPDISEN = '1' else '1';
    lipmatchen(29) <= '0' when macaddrwl = "11101" and IPDISEN = '1' else '1';
    lipmatchen(30) <= '0' when macaddrwl = "11110" and IPDISEN = '1' else '1';
    lipmatchen(31) <= '0' when macaddrwl = "11111" and IPDISEN = '1' else '1';


    -- match encoder
    -- NEED TO MAKE GENERIC
    MADDR <= "00000" when match = X"00000001" else
    		"00001" when match = X"00000002" else
    		"00010" when match = X"00000004" else
    		"00011" when match = X"00000008" else
    		"00100" when match = X"00000010" else
    		"00101" when match = X"00000020" else
    		"00110" when match = X"00000040" else
    		"00111" when match = X"00000080" else
    		"01000" when match = X"00000100" else
    		"01001" when match = X"00000200" else
    		"01010" when match = X"00000400" else
    		"01011" when match = X"00000800" else
    		"01100" when match = X"00001000" else
    		"01101" when match = X"00002000" else
    		"01110" when match = X"00004000" else
    		"01111" when match = X"00008000" else
		"10000" when match = X"00010000" else
    		"10001" when match = X"00020000" else
    		"10010" when match = X"00040000" else
    		"10011" when match = X"00080000" else
    		"10100" when match = X"00100000" else
    		"10101" when match = X"00200000" else
    		"10110" when match = X"00400000" else
    		"10111" when match = X"00800000" else
    		"11000" when match = X"01000000" else
    		"11001" when match = X"02000000" else
    		"11010" when match = X"04000000" else
    		"11011" when match = X"08000000" else
    		"11100" when match = X"10000000" else
    		"11101" when match = X"20000000" else
    		"11110" when match = X"40000000" else
    		"11111";


    	  

    clock: process(RESET, CLK) is
    begin
    		if RESET = '1' then
			camcs <= prea;
			writecs <= none;
		else
			if rising_edge(CLK) then
			   camcs <= camns;
			   writecs <= writens;

			   -- input latching
			   if IPQA = '1' then
			   	ipal <= IPA;
			   end if; 

			   if donea = '1' then 
			   	ipqap <= '0';
			   else 
			   	 if IPQA = '1' then
				 	ipqap <= '1';
				 end if; 
 			   end if; 

			   if IPQB = '1' then
			   	ipbl <= IPB;
			   end if; 

			   if doneb = '1' then 
			   	ipqbp <= '0';
			   else 
			   	 if IPQB = '1' then
				 	ipqbp <= '1';
				 end if; 
 			   end if; 

			   if WE = '1' then
			   	ipwrl <= IPWR;
			   end if; 

			   if donewr = '1' then 
			   	wep <= '0';
			   else 
			   	 if WE = '1' then
				 	wep <= '1';
				 end if; 
 			   end if; 



			   if ldisable = '1' then
			   	ipmatchen <= lipmatchen;
			   end if; 


		        if outen = '1' then
			   	MATCH <= lmatch;
				MADDROUT <= maddr;
			   end if; 

			end if; 
		end if; 
    end process clock; 


    camfsm: process(camcs, ipqa, ipqb) is
    begin
	  case camcs is
	  	when prea =>
			ipsel <= '0';
			outen <= '0';
			donea <= '0';
			doneb <= '0';
			if ipqa = '1' then
				camns <= ipselaen;
			else
				camns <= preb;
			end if; 
	  	when ipselaen =>
			ipsel <= '0';
			outen <= '0';
			donea <= '0';
			doneb <= '0';
			camns <= latcha;
	  	when latcha =>
			ipsel <= '0';
			outen <= '1';
			donea <= '0';
			doneb <= '0';
			camns <= enda;
	  	when enda =>
			ipsel <= '0';
			outen <= '0';
			donea <= '1';
			doneb <= '0';
			camns <= preb;
	  	when preb =>
			ipsel <= '0';
			outen <= '0';
			donea <= '0';
			doneb <= '0';
			if ipqb = '1' then
				camns <= ipselben;
			else
				camns <= prea;
			end if; 
	  	when ipselben =>
			ipsel <= '1';
			outen <= '0';
			donea <= '0';
			doneb <= '0';
			camns <= latchb;
	  	when latchb =>
			ipsel <= '0';
			outen <= '1';
			donea <= '0';
			doneb <= '0';
			camns <= endb;
	  	when endb =>
			ipsel <= '0';
			outen <= '0';
			donea <= '0';
			doneb <= '1';
			camns <= prea;
	  	when others =>
			ipsel <= '0';
			outen <= '0';
			donea <= '0';
			doneb <= '0';
			camns <= prea;
	end case;
  end process camfsm; 
  			
  writefsm : process (writecs, camcs, wep, ldone) is
  begin
  	case writecs is
		when none =>
			ipdisen <= '0';
			ldisable <= '0';
			lstart <= '0';
			if (camcs =  prea or camcs = preb) and wep = '1' then
				writens <= disable;
			else
				writens <= none;
			end if; 
		when disable =>
			ipdisen <= '1';
			ldisable <= '1';
			lstart <= '0';
			writens <= wstart;
		when wstart =>
			ipdisen <= '0';
			ldisable <= '0';
			lstart <= '1';
			writens <= wdone;
		when wdone =>
			ipdisen <= '0';
			ldisable <= '0';
			lstart <= '0';
			if ldone = '1' then
				writens <= wwait;
			else
				writens <= wdone;
			end if; 
		when wwait =>
			ipdisen <= '0';
			ldisable <= '0';
			lstart <= '0';
			if (camcs =  prea or camcs = preb) then
				writens <= wend;
			else
				writens <= wwait;
			end if; 
		when wend =>
			ipdisen <= '0';
			ldisable <= '1';
			lstart <= '0';
			writens <= none;
		when others =>
			ipdisen <= '0';
			ldisable <= '0';
			lstart <= '0';
			writens <= none;
	end case;  
  end process writefsm; 			 
			

end Behavioral;
