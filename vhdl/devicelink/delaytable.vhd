library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity delaytable is
  port (
    CLK : in std_logic;
    RESET : in std_logic; 
    WE : in std_logic;
    DIN : in std_logic;
    ADDRIN : in std_logic_vector(4 downto 0);
    DOUTA : out std_logic;
    ADDROUTA : in std_logic_vector(4 downto 0);
    DOUTB : out std_logic;
    ADDROUTB : in std_logic_vector(4 downto 0)
    );

end delaytable;

architecture Behavioral of delaytable is
  signal values : std_logic_vector(31 downto 0) := (others => '0');

begin  -- Behavioral

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          values <= (others => '0'); 
        else
          if WE = '1' then
            values(to_integer(UNSIGNED(ADDRIN))) <= DIN; 
          end if;
        end if;

        DOUTA <= values(to_integer(UNSIGNED(ADDROUTA))) ;
        DOUTB <= values(to_integer(UNSIGNED(ADDROUTB)));
      end if;
    end process; 

end Behavioral;
  
    
