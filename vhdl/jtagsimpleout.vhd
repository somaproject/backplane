library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity jtagsimpleout is
  generic (
    JTAG_CHAIN : integer := 0;
    JTAGN : integer := 32);
  port (
    CLK : in std_logic;
    DIN : in std_logic_vector(JTAGN-1 downto 0));
end jtagsimpleout;

architecture Behavioral of jtagsimpleout is
  -- jtag signal test
  signal jtagcapture : std_logic := '0';
  signal jtagdrck    : std_logic := '0';
  signal jtagreset   : std_logic := '0';
  signal jtagsel     : std_logic := '0';
  signal jtagshift   : std_logic := '0';
  signal jtagtdi     : std_logic := '0';
  signal jtagupdate  : std_logic := '0';
  signal jtagtdo     : std_logic := '0';

  signal testout : std_logic_vector(JTAGN-1 downto 0) := (others => '0');

begin  -- Behavioral

  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => JTAG_CHAIN)
    port map (
      CAPTURE    => jtagcapture,
      DRCK       => jtagdrck,
      reset      => jtagreset,
      SEL        => jtagsel,
      SHIFT      => jtagshift,
      TDI        => jtagtdi,
      UPDATE     => jtagupdate,
      TDO        => jtagtdo);

  jtagtdo         <= testout(0);

  process(jtagsel, jtagdrck, jtagupdate)
  begin
    if jtagupdate = '1' then
      testout     <= DIN;
    else
      if rising_edge(jtagdrck) then
        if jtagsel = '1' and jtagshift = '1' then
          testout <= testout(0) & testout(JTAGN-1 downto 1);
        end if;
      end if;
    end if;
  end process;


  

end Behavioral;
