library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARP is
    Generic (IPN : in integer := 4; 
    		   ARPSIZE : in integer := 5); 
    Port ( CLK : in std_logic;
           MACOUTADDR : in std_logic_vector(1 downto 0);
           MACOUT : out std_logic_vector(15 downto 0);
           HIT : out std_logic;
           VERIFYDONE : out std_logic;
           IPOUT : in std_logic_vector(4 downto 0);
           VERIFY : in std_logic;
           MACIN : in std_logic_vector(15 downto 0);
           IPIN : in std_logic_vector(4 downto 0);
           IPINWE : in std_logic;
           MACINADDR : in std_logic_vector(1 downto 0);
           MACINWE : in std_logic);
end ARP;

architecture Behavioral of ARP is
-- ARP.VHD -- Our system's arp cache; there is a generic which specifies
-- both the size of the cache and the number of bits to detect in the
-- IP addresses. 

	-- input side:
	signal ipa : std_logic_vector(IPN-1 downto 0) := (others => '0'); 
	signal ipqa : std_logic := '0';
	signal matchout, outhit : std_logic := '0';
	signal macaddrout : std_logic_vector(ARPSIZE-1 downto 0) 
		:= (others => '0');
     signal addra : std_logic_vector(ARPSIZE+1 downto 0) := (others => '0');

	-- rx side:
	signal macl, macm, mach, di : std_logic_vector(15 downto 0)
		:= (others => '0');
	signal addrb : std_logic_vector(ARPSIZE+1 downto 0) := (others => '0');
	signal ipinl : std_logic_vector(4*IPN -1 downto 0)
		:= (others => '0');
	signal ipinwel : std_logic := '0';
	signal donein, ipcamdone, ipcamwe : std_logic := '0';
	signal ruweb, lruen, ramwe :std_logic := '0';


	-- fsm
	type states is none, lookup, lruchk, maclw, macmw, machw);
	signal cs, ns : states := none; 


	component ipcam is
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
	end component;

	component dpblockram is 
	 Generic (ADDRSIZE : in integer := 5); 
	 port (clk  : in std_logic; 
	 	we   : in std_logic; 
	 	a    : in std_logic_vector(ADDRSIZE-1 downto 0); 
	 	dpra : in std_logic_vector(ADDRSIZE-1 downto 0); 
	 	di   : in std_logic_vector(15 downto 0); 
	 	spo  : out std_logic_vector(15 downto 0); 
	 	dpo  : out std_logic_vector(15 downto 0)); 
	 end component; 

begin



	-- instantiate ram
	ram: dpblockram generic map (
		ADDRSIZE => ARPSIZE+3)
		port map (
		clk => CLK,
		we => ramwe,
		a => addra,
		dpra => addrb,
		di => di,
		spo => MACOUT,
		dpo => open); 


	-- instantiate cam
	ipcam_inst: ipcam generic map (
		IPN => IPN,
		ARPSIZE => ARPSIZE)
		port map (
		CLK => CLK,
		RESET => RESET,
		IPA => ipa, 
		IPQA => ipqa, 
		IPB => ipinl, 
		IPQB => ipinwel,
		IPWR => ipinl,
		WE => ipcamwe,
		MADDRWR => addrb(ARPSIZE+1 downto 2),
		MATCHOUT => matchout,
		MADDROUT => maddrout);
		
		 	 
    outhit <= matchout and donea; 
    di <= macl when addrb(1 downto 0) = "00" else
		macm when addrb(1 downto 0) = "01" else
		mach; 

    clock: process (CLK, RESET) is
    begin
    	  if RESET = '1' then
		cs <= none; 
	  else
	  	if rising_edge(CLK) then
			
			cs <= ns;
			
			if outhit = '1' then
				addra(ARPSIZE-1 downto 2) <= maddrout; 
			end if; 
			
			if VERIFY = '1' then
				ipa <= IPOUT;
			end if;
			
			ipqa <= VERIFY; 
			
			if ipinwe = '1' then
				ipinl <= IPIN;
			end if; 
			ipinwel <= IPINWE; 
			
			if lruen = '1' then
				adrb(ARPSIZE-1 downto 2) <= lru;
			end if; 
			
			if MACINWE = '1' and MACINADDR = "00" then
				macl <= MACIN;
			end if; 
			if MACINWE = '1' and MACINADDR = "01" then
				macm <= MACIN;
			end if; 
			if MACINWE = '1' and MACINADDR = "10" then
				mach <= MACIN;
			end if; 


		end if; 
	  end if; 


    end process clock; 


    fsm: process(cs, ipinwel, donein, matchout) is
    begin
    	  case cs is
	  	when none => 
			addrb(1 downto 0) <= "00";
			ramwe <= '0'; 
			lruen <= '0';
			if ipwenl = '1' then
				ns <= lookup;
			else
				ns <= none;
			end if; 

	  	when lookup => 
			addrb(1 downto 0) <= "00";
			ramwe <= '0'; 
			lruen <= '0';
			if donein= '1'  then
				if matchout = '1' then
					ns <= none; 
				else
					ns <= lruchk;
				end if; 
			else
				ns <= lookup; 
			end if; 
	  	when lruchk => 
			addrb(1 downto 0) <= "00";
			ramwe <= '0'; 
			lruen <= '1';
			ns <= maclw;
	  	when maclw => 
			addrb(1 downto 0) <= "00";
			ramwe <= '1'; 
			lruen <= '0';
			ns <= macmw;
	  	when macmw => 
			addrb(1 downto 0) <= "01";
			ramwe <= '1'; 
			lruen <= '0';
			ns <= machw;
	  	when machw => 
			addrb(1 downto 0) <= "10";
			ramwe <= '1'; 
			lruen <= '0';
			ns <= none;
	  	when others => 
			addrb(1 downto 0) <= "00";
			ramwe <= '0'; 
			lruen <= '0';
			ns <= none;
	  end case;
    end process fsm; 

end Behavioral;
