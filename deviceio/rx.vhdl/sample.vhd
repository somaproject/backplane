library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity sample is
  port ( CLK   : in  std_logic;
         CLK90 : in  std_logic;
         DIN   : in  std_logic;
         DOUT  : out std_logic_vector(3 downto 0)
         );

end sample;

architecture Behavioral of sample is

  signal notclk, notclk90 : std_logic                    := '0';
  signal dinl, dinll      : std_logic_vector(3 downto 0) := (others => '0');

begin

  notclk   <= not CLK;
  notclk90 <= not CLK90;

  main1 : process (CLK)
  begin
    if rising_edge(CLK) then
      dinl(0)  <= DIN;
      dinll(0) <= dinl(0);
      dinll(1) <= dinl(1);

      DOUT <= dinll;

    end if;
  end process main1;

  main2 : process (CLK90)
  begin
    if rising_edge(CLK90) then
      dinl(1)  <= DIN;
      dinll(2) <= dinl(2);
    end if;
  end process main2;

  main3 : process (notclk)
  begin
    if rising_edge(notclk) then
      dinl(2)  <= DIN;
      dinll(3) <= dinl(3);
    end if;
  end process main3;

  main4 : process (notclk90)
  begin
    if rising_edge(notclk90) then
      dinl(3) <= DIN; 
    end if;
  end process main4;


end Behavioral;

