library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity memtest is
  port (
    CLK   : in    std_logic;
    RAMDQ : inout std_logic_vector(15 downto 0);
    RAMWE : out std_logic;
    RAMADDR : out std_logic_vector(16 downto 0)
    ); 
end memtest;

architecture Behavioral of memtest is

  signal dsel : std_logic := '0';

  signal lramwe : std_logic := '0';
  signal lramaddr : std_logic_vector(16 downto 0) := (others => '0');
  signal lts : std_logic := '0';

  signal ts : std_logic := '0';

  signal ramdin : std_Logic_vector(15 downto 0) := (others => '0');
  
  signal acnt : std_logic_vector(16 downto 0) := (others => '0');

  signal dcnt : std_logic_vector(15 downto 0) := (others => '0');

  type acnt_t is array (0 to 15) of std_logic_vector(16 downto 0);  
  signal acntreg : acnt_t := (others => (others => '0'));
  
  type dcnt_t is array (0 to 15) of std_logic_vector(15 downto 0);  
  signal dcntreg : acnt_t := (others => (others => '0'));
  
  
  
begin  -- Behavioral

  lramwe <= '0' when dsel = '0' else '1';
  lts <= '0' when dsel = '0' else '1';
  lramaddr <= acnt when dsel = '0' else acntreg(5);
  
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        dsel <= not dsel;

        -- registers
        RAMWE <= lramwe;
        RAMADDR <= lramaddr;
        if lts = '1' then
          RAMDQ <= (others => 'Z');
        else
          RAMDQ <= dcnt; 
        end if;

        ramdin <= RAMDQ; 

        -- counters
        if dsel = '1' then
          acnt <= acnt + 1;
          dcnt <= dcnt + 1; 
        end if;

        acntreg <= acntreg(14 downto 0) & acnt;
        dcntreg <= dcntreg(14 downto 0) & dcnt;
        
      end if;
    end process; 

end Behavioral;
