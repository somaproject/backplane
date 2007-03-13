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
  signal sum, suml : std_logic_vector(31 downto 0) := (others => '0');

  signal a, b, c : std_logic_vector(16 downto 0) := (others => '0');


begin  -- Behavioral

  sum <= (X"0000" & DIN) + suml;
  
  CHKOUT <= not (suml(15 downto 0) + suml(31 downto 16)); 
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      if EN = '1' then
        if ld = '0' then
          suml <= sum;
        else
          suml <= X"0000" & DIN; 
        end if;
      end if;

    end if;
  end process main;


end Behavioral;
