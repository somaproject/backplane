library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity eventbodywriter is
  port (
    CLK    : in  std_logic;
    ECYCLE : in  std_logic;
    EDTX   : in  std_logic_vector(7 downto 0);
    EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
    DOUT   : out std_logic_vector(15 downto 0);
    WEOUT  : out std_logic;
    ADDR   : out std_logic_vector(8 downto 0);
    DONE : out std_logic);
end eventbodywriter;


architecture Behavioral of eventbodywriter is

  -- counters
  signal ewcnt : std_logic_vector(7 downto 0) := (others => '0');
  signal epos : integer range 0 to somabackplane.N-1 := 0;
  signal bcnt : integer range 0 to 11 := 0;

  signal eincnt : std_logic_vector(8 downto 0) := (others => '0');

  signal elb : std_logic := '0';

  signal etxbit : std_logic := '0';
  
  signal wrlen : std_logic := '0';

  
begin  -- Behavioral

  DOUT <= ldout when wrlen = '0' else ewcnt;
  ADDR <= eincnt when wrlen = '0' else X"00";
    
  elb <= '1' when bcnt = 11 else '0';

  etxbit <= eatx(epos);

  main: process(CLK)
    begin
      if rising_edge(CLK) then
        
        
      end if;
    end process main; 
         

end Behavioral;
