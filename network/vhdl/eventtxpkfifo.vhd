library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity eventtxpktfifo is
  port (
    CLK      : in  std_logic;
    DIN      : in  std_logic_vector(15 downto 0);
    ADDRIN   : in  std_logic_vector(8 downto 0);
    WE       : in  std_logic;
    DONE     : in  std_logic;
    DOUT     : out std_logic_vector(15 downto 0);
    ADDROUT  : in  std_logic_vector(8 downto 0);
    VALID    : out std_logic;
    FIFONEXT : in  std_logic);
end eventtxpktfifo;

architecture Behavioral of eventtxpktfifo is
  signal addra : std_logic_vector(10 downto 0) := (others => '0');

  signal bpin, bpinl, bpout : std_logic_vector(1 downto 0) := (others => '0');

  signal addrb : std_logic_vector(10 downto 0) := (others => '0');



begin  -- Behavioral

  VALID <= '1' when bpinl /= bpout else '0';
  addra <= bpin & ADDRIN;
  addrb <= bpout & ADDROUT;


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if DONE = '1' then
        bpin <= bpin + 1;
      end if;

      if FIFONEXT = '1' then
        bpout <= bpout + 1;
      end if;

      bpinl <= bpin;

    end if;
  end process main;


  buffer_high : RAMB16_S9_S9
    generic map (
      SIM_COLLISION_CHECK => "NONE",
      -- Address 0 to 511
      INIT_00             => X"000000000000000000000000009c0000000000400000004508000000FFFFFF00",
      -- Address 512 to 1023
      INIT_10             => X"000000000000000000000000009c0000000000400000004508000000FFFFFF00",
      -- Address 1024 to 1535
      INIT_20             => X"000000000000000000000000009c0000000000400000004508000000FFFFFF00",
      -- Address 1536 to 2047
      INIT_30             => X"000000000000000000000000009c0000000000400000004508000000FFFFFF00")
    port map (
      DOA                 => open,
      DOB                 => DOUT(15 downto 8),  -- Port B 8-bit Data Output
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => DIN(15 downto 8),   -- Port A 8-bit Data Input
      DIB                 => X"00",
      DIPA                => "0",
      DIPB                => "0",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => WE,
      WEB                 => '0'
      );

  buffer_low : RAMB16_S9_S9
    generic map (
      SIM_COLLISION_CHECK => "NONE",
      -- Address 0 to 511
      INIT_00             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      -- Address 512 to 1023
      INIT_10             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      -- Address 1024 to 1535
      INIT_20             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      -- Address 1536 to 2047
      INIT_30             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00")
    port map (
      DOA                 => open,
      DOB                 => DOUT(7 downto 0),  -- Port B 8-bit Data Output
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => DIN(7 downto 0),   -- Port A 8-bit Data Input
      DIB                 => X"00",
      DIPA                => "0",
      DIPB                => "0",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => WE,
      WEB                 => '0'
      );

end Behavioral;
