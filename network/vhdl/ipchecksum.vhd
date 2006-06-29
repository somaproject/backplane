library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity ipchecksum is
  port (
    CLK    : in  std_logic;
    DIN    : in  std_logic_vector(15 downto 0);
    LD     : in  std_logic;
    EN     : in  std_logic;
    CHKOUT : out std_logic_vector(15 downto 0));
end ipchecksum;

architecture Behavioral of ipchecksum is
  signal sum, suml : std_logic_vector(15 downto 0) := (others => '0');

  signal a, b : std_logic_vector(16 downto 0) := (others => '0');


begin  -- Behavioral

  a <= ('0' & din(15 downto 0)) + ('0' & suml(15 downto 0));
  b <= a + (X"0000" & a(16) ) ;
  sum <= b(15 downto 0) ;
  
  CHKOUT <= not suml; 
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      if EN = '1' then
        if ld = '0' then
          suml <= sum;
        else
          suml <= DIN; 
        end if;
      end if;

    end if;
  end process main;


end Behavioral;
