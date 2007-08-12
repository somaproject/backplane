library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity fakedata is
    port (
    CLK    : in std_logic;
    DOUT   : out   std_logic_vector(7 downto 0);
    DOUTEN : out   std_logic;
    ECYCLE : in std_logic
    ); 
end fakedata;

architecture Behavioral of fakedata is
  signal ecyclecnt : std_logic_vector(7 downto 0) := (others => '0');

  signal epos : integer range 0 to 2047 := 0;
  
    
begin  -- Behavioral

  DOUT <= (others => '0'); 
          
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        if ECYCLE = '1' then
          ecyclecnt <= ecyclecnt + 1; 
        end if;

        if ECYCLE = '1'  then
          epos <= 0;
        else
          epos <= epos + 1; 
        end if;

        if ecyclecnt = X"00" then
          if epos > 50 and epos < 150 then
            DOUTEN <= '1';
          else
            DOUTEN <= '0'; 
          end if;
        else
            DOUTEN <= '0'; 
        end if;

      end if;
    end process; 
  

end Behavioral;
