
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity blink is

  port (
    CLKIN    : in  std_logic;
    LEDPOWER : out std_logic;
    LEDVALID : out std_logic
    );

end blink;

architecture Behavioral of blink is

  signal cnt : std_logic_vector(23 downto 0) := (others => '0');


  begin

    process(clkin)
      begin
        if rising_edge(CLKIN) then
          cnt <= cnt + 1;

          LEDPOWER <= cnt(23);
          LEDVALID <= cnt(22); 
          
        end if;

      end process; 


  end Behavioral;
  
