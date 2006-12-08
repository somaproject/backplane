library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity bigmem is
  port (
    CLK     : in  std_logic;
    DIN     : in  std_logic_vector(15 downto 0);
    WEIN    : in  std_logic;
    ADDRIN  : in  std_logic_vector(13 downto 0);
    DOUT    : out std_logic_vector(15 downto 0);
    ADDROUT : in  std_logic_vector(13 downto 0)
    );
end bigmem;

architecture Behavioral of bigmem is

  signal weset : std_logic_vector(15 downto 0) := (others => '0');

  type douts_t is array (0 to 15) of
    std_logic_vector(15 downto 0);

  signal douts : douts_t := (others => (others => '0'));


begin  -- Behavioral
  memsets : for i in 0 to 15 generate
    weset(i) <= '1' when WEIN = '1' and
                addrin(13 downto 10) = std_logic_vector(TO_UNSIGNED(i, 4))
                else '0';
    rami :
      RAMB16_S18_S18
        generic map (
          SIM_COLLISION_CHECK => "NONE")

        port map (
          WEA   => weset(i),
          ENA   => '1',
          SSRA  => '0',
          CLKA  => CLK,
          ADDRA => ADDRIN(9 downto 0),
          ADDRB => ADDROUT(9 downto 0),
          DIA   => DIN,
          DIPA  => "00",
          DOPA  => open,
          DOA   => open,
          WEB   => '0',
          ENB   => '1',
          SSRB  => '0',
          CLKB  => CLK,
          DIB   => X"0000",
          DIPB  => "00",
          DOPB  => open,
          DOB   => douts(i));

  end generate memsets;

  -- output mux

  DOUT <= douts(TO_INTEGER(unsigned(ADDROUT(13 downto 10))));


end Behavioral;
