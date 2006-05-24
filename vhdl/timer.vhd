library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity timer is
    port (
      CLK     : in  std_logic;
      ECYCLE  : out std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX :  out std_logic_vector(7 downto 0);  
      EDSELRX : in std_logic_vector(3 downto 0);
      EATX    : in std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in std_logic_vector(7 downto 0)
      );
end timer;


architecture Behavioral of timer is

  signal ecnt : integer range 0 to 999 := 0;

  signal tcnt : std_logic_vector(47 downto 0) := (others => '0');
  signal tcntl : std_logic_vector(47 downto 0) := (others => '0');

  signal lecycle : std_logic := '0';
  
begin  -- Behavioral

  lecycle <= '1' when ecnt =999 else '0';

  EDRX <= X"00" when EDSELRX = X"0" else
          X"10" when EDSELRX = X"1" else
          tcntl(47 downto 40) when EDSELRX = X"2" else
          tcntl(39 downto 32) when EDSELRX = X"3" else
          tcntl(31 downto 24) when EDSELRX = X"4" else
          tcntl(23 downto 16) when EDSELRX = X"5" else
          tcntl(15 downto 8) when EDSELRX = X"6" else
          tcntl(7 downto 0) when EDSELRX = X"7" else
          X"00"; 


  EARX <= (others => '1'); 
    
  
  main: process (CLK)
    begin
      if rising_edge(CLK) then

        -- ecycle counter
        if ecnt = 999 then
          ecnt <= 0;
        else
          ecnt <= ecnt + 1; 
        end if;

        if lecycle = '1' then
          tcnt <= tcnt + 1;
          tcntl <= tcnt; 
        end if;

        ECYCLE <= lecycle; 
      end if;

    end process main;
                        

end Behavioral;
