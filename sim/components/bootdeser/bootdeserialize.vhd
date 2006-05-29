library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity bootdeserialize is
  
  port (
    CLK   : in  std_logic;
    DIN   : in  std_logic;
    FPROG : out std_logic;
    FDIN  : out std_logic;
    FCLK  : out std_logic);

end bootdeserialize;


architecture Behavioral of bootdeserialize is
  signal lfdin, lfclk : std_logic := '0';
  signal lfprog : std_logic := '1';
  signal poscnt : integer := 0;
  signal dinreg : std_logic_vector(19 downto 0);
  
  
begin  -- Behavioral
  FPROG <= lfprog;
  FCLK <= lfclk;
  FDIN <= lfdin;
  
  process
    begin
      while True loop
        wait until rising_edge(CLK) and DIN = '1';
        wait until rising_edge(CLK) and DIN = '1';
        wait until  rising_edge(CLK) and DIN = '0';
        for i in 0 to 19 loop
          wait until rising_edge(CLK);
          dinreg(i) <= DIN; 
        end loop;  -- i
        wait until rising_edge(CLK);
        lFPROG <= dinreg(7);
        lFCLK <= dinreg(7+5);
        lFDIN <= dinreg(7+10);
        
        
      end loop;
    end process; 

end Behavioral;
