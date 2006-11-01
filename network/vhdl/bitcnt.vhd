library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity bitcnt is
  port (
    CLK : in std_logic;
    DIN : in std_logic_vector(95 downto 0);
    DOUT : out std_logic_vector(6 downto 0);
    START : in std_logic;
    DONE : out std_logic
    ); 
end bitcnt;

architecture Behavioral of bitcnt is
  signal do : std_logic_vector(31 downto 0) := (others => '0');
  signal s1 : std_logic_vector(19 downto 0) := (others => '0');
  
  
begin  -- Behavioral

  array: for i in 0 to 7 generate
      mem: RAMB16_S4_S4
        generic map (
          SIM_COLLISION_CHECK => "NONE")
        port map (
          WEA   => '0',
          ENA   => '1',
          SSRA  => '0',
          CLKA  => CLK,
          ADDRA => DIN(24*i+11 downto 24*i)
          ADDRB => DIN(24*i+23 downto 24*i + 12)
          DIA   => "0000",
          DOPA  => open,
          DOA   => do(8*i+3 downto 8*i),
          WEB   => '0',
          ENB   => '1',
          SSRB  => '0',
          CLKB  => CLK,
          DIB   => X"0000",
          DIPB  => "00",
          DOPB  => open,
          DOB   => do(8*i+7 downto 8*i+4));
  end generate array;

  

end Behavioral;
