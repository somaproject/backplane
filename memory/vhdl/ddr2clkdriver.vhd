library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity ddr2clkdriver is
  port (
    CLKIN    : in  std_logic;
    RESET    : in  std_logic;
    CLKOUT_P : out std_logic;
    CLKOUT_N : out std_logic
    ); 
end ddr2clkdriver;

architecture Behavioral of ddr2clkdriver is

  signal clkout : std_logic := '0';
  
begin  -- Behavioral
  oddr_inst : ODDR
    generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",
      SRTYPE       => "SYNC")
    port map (
      D1 => '1',
      D2 => '0',
      CE => '1',
      Q => clkout, 
      C  => CLKIN,
      S  => '0',
      R  => '0');

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => CLKOUT_P,
      OB         => CLKOUT_N,
      I          => clkout
      );


end Behavioral;
