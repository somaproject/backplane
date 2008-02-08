
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;


entity eproctest is
  port (
    CLKIN  : in std_logic;
    -- Event Interface, CLK rate
    ECYCLE : in std_logic;

    EDTX     : in  std_logic_vector(7 downto 0);
    EATXBYTE : in  std_logic_vector(7 downto 0);
    EATXADDR : in  std_logic_vector(3 downto 0);
    EATXWE   : in  std_logic;
    EARXBYTE : out std_logic_vector(7 downto 0);
    EARXADDR : in  std_logic_vector(3 downto 0);
    EDRX     : out std_logic_vector(7 downto 0);
    EDSELRX  : in  std_logic_vector(3 downto 0)
    );
end eproctest;

architecture Behavioral of eproctest is

  signal iaddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata : std_logic_vector(17 downto 0) := (others => '0');

  component eproc
    port (
      CLK         : in  std_logic;
      RESET       : in  std_logic;
      -- Event Interface, CLK rate
      EDTX        : in  std_logic_vector(7 downto 0);
      EATX        : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE      : in  std_logic;
      -- event output interface
      EAOUT       : out std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
      EDOUT       : out std_logic_vector(95 downto 0);
      ENEWOUT     : out std_logic;
      -- High-speed interface
      CLKHI       : in  std_logic;
      -- instruction interface
      IADDR       : out std_logic_vector(9 downto 0);
      IDATA       : in  std_logic_vector(17 downto 0);
      --outport signals
      OPORTADDR   : out std_logic_vector(7 downto 0);
      OPORTDATA   : out std_logic_vector(15 downto 0);
      OPORTSTROBE : out std_logic;
      --inport signals
      IPORTADDR   : out std_logic_vector(7 downto 0);
      IPORTDATA   : in  std_logic_vector(15 downto 0);
      IPORTSTROBE : out std_logic;

      DEVICE : in std_logic_vector(7 downto 0)
      );

  end component;

  signal clkhi, clk : std_logic := '0';

  signal clkint, clkhiint : std_logic := '0';
  signal locked           : std_logic := '0';
  signal reset            : std_logic := '1';

  signal eatx, earx : std_logic_vector(somabackplane.n - 1 downto 0) := (others => '0');

  signal oportaddr   : std_logic_vector(7 downto 0);
  signal oportdata   : std_logic_vector(15 downto 0);
  signal oportstrobe : std_logic;

  signal iportaddr   : std_logic_vector(7 downto 0);
  signal iportdata   : std_logic_vector(15 downto 0);
  signal iportstrobe : std_logic;

  signal eaout   : std_logic_vector(somabackplane.n - 1 downto 0)
                                                 := (others => '0');
  signal edout   : std_logic_vector(95 downto 0) := (others => '0');
  signal enewout : std_logic                     := '0';

  component txeventbuffer
    port (
      CLK      : in  std_logic;
      EVENTIN  : in  std_logic_vector(95 downto 0);
      EADDRIN  : in  std_logic_vector(somabackplane.N -1 downto 0);
      NEWEVENT : in  std_logic;
      ECYCLE   : in  std_logic;
      -- outputs
      EDRX     : out std_logic_vector(7 downto 0);
      EDRXSEL  : in  std_logic_vector(3 downto 0);
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
  end component;


begin  -- Behavioral

  CLKDLL_inst : CLKDLL
    port map (
      CLKIN  => CLKIN,
      CLKFB  => clk,
      RST    => '0',
      CLK0   => clkint,
      CLK2x  => clkhiint,
      LOCKED => locked);
  clk_bufg    : bufg
    port map (
      I      => clkint,
      O      => clk);

  clkhi_bufg : bufg
    port map (
      I => clkhiint,
      O => clkhi);

  RESET <= not locked;

  eproc_inst : eproc
    port map (
      CLK         => clk,
      RESET       => RESET,
      EDTX        => EDTX,
      EATX        => eatx,
      ECYCLE      => ECYCLE,
      EAOUT       => eaout,
      EDOUT       => edout,
      ENEWOUT     => enewout,
      CLKHI       => clkhi,
      IADDR       => iaddr,
      IDATA       => idata,
      OPORTADDR   => OPORTADDR,
      OPORTDATA   => OPORTDATA,
      OPORTSTROBE => OPORTSTROBE,
      IPORTADDR   => IPORTADDR,
      IPORTDATA   => IPORTDATA,
      IPORTSTROBE => IPORTSTROBE,
      DEVICE      => X"12");

  txbuffer : txeventbuffer
    port map (
      CLK      => clkhi,
      EVENTIN  => edout,
      EADDRIN  => eaout,
      NEWEVENT => enewout,
      ECYCLE   => ECYCLE,
      EDRX     => EDRX,
      EDRXSEL  => EDSELRX,
      EARX     => EARX);

  OPORTDATA <= OPORTADDR & OPORTADDR;
  instruction_ram : RAMB16_S18_S18
    port map (
      DOA   => idata(15 downto 0),
      DOPA  => idata(17 downto 16),
      ADDRA => iaddr,
      CLKA  => clkhi,
      DIA   => X"0000",
      DIPA  => "00",
      ENA   => '1',
      WEA   => '0',
      SSRA  => RESET,
      DOB   => open,
      DOPB  => open,
      ADDRB => "0000000000",
      CLKB  => clkhi,
      DIB   => X"0000",
      DIPB  => "00",
      ENB   => '0',
      WEB   => '0',
      SSRB  => RESET);

  process(CLK)
  begin
    if rising_edge(CLK) then
      if EATXWE = '1' then
        if EATXADDR = "0000" then
          eatx(7 downto 0)   <= EATXBYTE;
        end if;
        if EATXADDR = "0001" then
          eatx(15 downto 8)  <= EATXBYTE;
        end if;
        if EATXADDR = "0010" then
          eatx(23 downto 16) <= EATXBYTE;
        end if;
        if EATXADDR = "0011" then
          eatx(31 downto 24) <= EATXBYTE;
        end if;
        if EATXADDR = "0100" then
          eatx(39 downto 32) <= EATXBYTE;
        end if;
        if EATXADDR = "0101" then
          eatx(47 downto 40) <= EATXBYTE;
        end if;
        if EATXADDR = "0110" then
          eatx(55 downto 48) <= EATXBYTE;
        end if;
        if EATXADDR = "0111" then
          eatx(63 downto 56) <= EATXBYTE;
        end if;
        if EATXADDR = "1000" then
          eatx(71 downto 64) <= EATXBYTE;
        end if;
        if EATXADDR = "1001" then
          eatx(77 downto 72) <= EATXBYTE(5 downto 0);
        end if;
      end if;

      if EARXADDR = "0000" then
        EARXBYTE <= EARX(7 downto 0);
      end if;
    end if;

  end process;

end Behavioral;
