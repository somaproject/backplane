library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;


entity dpblockram is 
 Generic (ADDRSIZE : in integer := 5); 
 port (clk  : in std_logic; 
 	we   : in std_logic; 
 	a    : in std_logic_vector(ADDRSIZE-1 downto 0); 
 	dpra : in std_logic_vector(ADDRSIZE-1 downto 0); 
 	di   : in std_logic_vector(15 downto 0); 
 	spo  : out std_logic_vector(15 downto 0); 
 	dpo  : out std_logic_vector(15 downto 0)); 
 end dpblockram; 
 
 architecture syn of dpblockram is 
 
 type ram_type is array (2**ADDRSIZE-1 downto 0) of std_logic_vector (15 downto 0); 
 signal RAM : ram_type; 
 signal read_a : std_logic_vector(ADDRSIZE-1 downto 0); 
 signal read_dpra : std_logic_vector(ADDRSIZE-1 downto 0); 
 
 begin 
 process (clk) 
 begin 
 	if (clk'event and clk = '1') then  
 		if (we = '1') then 
 			RAM(conv_integer(a)) <= di; 
 		end if; 
 		read_a <= a; 
 		read_dpra <= dpra; 
 	end if; 
 end process; 
 
 spo <= RAM(conv_integer(read_a)); 
 dpo <= RAM(conv_integer(read_dpra)); 
 
 end syn;
