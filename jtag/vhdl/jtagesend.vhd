library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;

entity jtagesend is

  generic (
    JTAG_CHAIN : integer := 1);

  port (
    CLK     : in  std_logic;
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0)
    );

end jtagesend;

architecture Behavioral of jtagesend is

  signal capture  : std_logic := '0';
  signal drck     : std_logic := '0';
  signal reset    : std_logic := '0';
  signal sel      : std_logic := '0';
  signal shift    : std_logic := '0';
  signal tdi, tdo : std_logic := '0';
  signal update   : std_logic := '0';

  signal sreg : std_logic_vector(175 downto 0) := (others => '0');

  signal ubit, ubitl       : std_logic := '0';
  signal newdata, newdatal : std_logic := '0';

  signal data    : std_logic_vector(175 downto 0)    := (others => '0');
  signal edrxall : std_logic_vector(6*16-1 downto 0) := (others => '0');



begin  -- Behavioral

  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => JTAG_CHAIN)
    port map (
      CAPTURE    => capture,
      DRCK       => drck,
      reset      => reset,
      SEL        => sel,
      SHIFT      => shift,
      TDI        => tdi,
      UPDATE     => update,
      TDO        => tdo);


  process(DRCK)
  begin
    if rising_edge(DRCK) then
      if SEL = '1' then
        sreg <= TDI & sreg(175 downto 1);
      end if;
    end if;
  end process;


  process (UPDATE)
  begin
    if rising_edge(UPDATE) then
      if SEL = '1' then
        ubit <= not ubit;
      end if;
    end if;
  end process;

  newdata <= ubit xor ubitl;

  EDRX <= edrxall(7 downto 0)   when EDSELRX = X"0" else
          edrxall(15 downto 8)  when EDSELRX = X"1" else
          edrxall(23 downto 16) when EDSELRX = X"2" else
          edrxall(31 downto 24) when EDSELRX = X"3" else
          edrxall(39 downto 32) when EDSELRX = X"4" else
          edrxall(47 downto 40) when EDSELRX = X"5" else
          edrxall(55 downto 48) when EDSELRX = X"6" else
          edrxall(63 downto 56) when EDSELRX = X"7" else
          edrxall(71 downto 64) when EDSELRX = X"8" else
          edrxall(79 downto 72) when EDSELRX = X"9" else
          edrxall(87 downto 80) when EDSELRX = X"A" else
          edrxall(95 downto 88);


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      newdatal <= newdata;
      ubitl    <= ubit;

      if newdatal = '1' then
        data   <= sreg;
      else
        if ECYCLE = '1' then
          data <= (others => '0');
        end if;
      end if;

      if ECYCLE = '1' then
        EARX    <= data(somabackplane.N -1 downto 0);
        edrxall <= data(175 downto 80);
      end if;

    end if;
  end process;
end Behavioral;

