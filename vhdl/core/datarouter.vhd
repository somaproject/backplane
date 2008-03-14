library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity datarouter is
    port (
      CLK     : in  std_logic;
      ECYCLE  : in std_logic;
      DIN    : in  somabackplane.dataroutearray;
      DINEN : in std_logic_vector(7 downto 0);
      
      DOUT : out std_logic_vector(7 downto 0);
      DOEN : out std_logic; 
      DGRANT: out std_logic_vector(31 downto 0)
      );
end datarouter;

architecture Behavioral of datarouter is
  signal cnt : std_logic_vector(4 downto 0) := (others => '1');
  
begin  -- Behavioral

  process(CLK)
    begin
      if rising_edge(CLK) then
        if ECYCLE = '1' then
          cnt <= cnt + 1; 
        end if;
      end if;
    end process; 

    DOUT <= DIN(0) when cnt(4 downto 2) = "000" else
            DIN(1) when cnt(4 downto 2) = "001" else
            DIN(2) when cnt(4 downto 2) = "010" else
            DIN(3) when cnt(4 downto 2) = "011" else
            DIN(4) when cnt(4 downto 2) = "100" else
            DIN(5) when cnt(4 downto 2) = "101" else
            DIN(6) when cnt(4 downto 2) = "110" else
            DIN(7); 

    grantgen: for i in 0 to 31 generate
      DGRANT(i) <= '1' when cnt = conv_std_logic_vector(i, 5) else '0'; 
    end generate grantgen;
    
end Behavioral;
