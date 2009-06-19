library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity simdelay is
  generic (
    BITSIZE : integer := 26);
  port (
    CLK     : in std_logic;
    SETMASK : in std_logic;
    MASKIN  : in std_logic_vector(BITSIZE-1 downto 0);

    DLYRST : in  std_logic;
    DLYINC : in  std_logic;
    DLYCE  : in  std_logic;
    DELAY : out integer; 
    DOUT   : out std_logic_vector(9 downto 0));

end simdelay;

architecture Behavioral of simdelay is

  
  signal delay_position : integer                       := 0;
  signal mask           : std_logic_vector(BITSIZE -1 downto 0) := (others => '0');
  
  signal bits : std_logic_vector(9 downto 0) := (others => '0');
  
begin  -- Behavioral

  process(CLK)
  begin
    if rising_edge(CLK) then
      if setmask = '1' then
        mask <= maskin;
      end if;

      if dlyrst = '1' then
        delay_position <= 0;
      else
        if dlyce = '1' then
          if dlyinc = '1' then
            if delay_position = BITSIZE -1 then
              delay_position <= 0;
            else
              delay_position <= delay_position + 1;
            end if;
          else
            if delay_position = 0 then
              delay_position <= BITSIZE -1;
            else
              delay_position <= delay_position -1;
            end if;
          end if;
        end if;
      end if;

      if mask(delay_position) = '0' then
        bits <= "0010011011"; 
      else
        bits <= not bits; 
      end if;

      DOUT <= bits;
      DELAY <= delay_position;
      
    end if;
  end process;


end Behavioral;
