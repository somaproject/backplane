library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity ipmatch is
    Generic (IPN : in integer := 4);
    Port ( CLK : in std_logic;
           IPIN : in std_logic_vector(4*IPN -1 downto 0);
           SIN : in std_logic_vector(IPN -1 downto 0);
           WE : in std_logic;
           EN : in std_logic;
           MATCH : out std_logic);
end ipmatch;

architecture Behavioral of ipmatch is
-- IPMATCH.VHD -- heavily generic use of LUTs as SRL16Es to perform
-- matching of individual IP addresses. 

	signal d : std_logic_vector(IPN-1 downto 0) := (others => '0'); 
	signal ween : std_logic := '0';
	signal ones : std_logic_vector(IPN-1 downto 0); 


	component SRL16E
	  generic (
	       INIT : bit_vector := X"0000");
	  port (D   : in STD_logic;
	        CE  : in STD_logic;
	        CLK : in STD_logic;
	        A0  : in STD_logic;
	        A1  : in STD_logic;
	        A2  : in STD_logic;
	        A3  : in STD_logic;
	        Q   : out STD_logic); 
	end component;	



begin
    ipmatch_inst: for i in 0 to IPN-1 generate
		SRL_inst0: SRL16E port map (
			D => SIN(i),
			CE => ween,
			CLK => clk,
			A0 => IPIN(i*IPN + 0),
			A1 => IPIN(i*IPN + 1),
			A2 => IPIN(i*IPN + 2),
			A3 => IPIN(i*IPN + 3),
			Q => d(i)); 
   end generate;
   ones <= (others => '1'); 
   ween <= WE and not EN; 

   output: process(CLK) is
   begin
   	if rising_edge(CLK) then
		if EN = '1' then
			if d = ones then
				MATCH <= '1';
			else
				MATCH <= '0';
			end if;
		else
			MATCH <= '0';
		end if; 
	end if;
   end process; 


end Behavioral;
