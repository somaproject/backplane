
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity manydevicelink is

  port (
    CLKIN      : in  std_logic;
    RESET      : in  std_logic;
    TXIO_P     : out std_logic_vector(18 downto 0);
    TXIO_N     : out std_logic_vector(18 downto 0);
    RXIO_P     : in  std_logic_vector(18 downto 0);
    RXIO_N     : in  std_logic_vector(18 downto 0);
    LEDPOWER   : out std_logic;
    LEDVALID   : out std_logic;
    WORDCLKOUT : out std_logic;
    TXCLKOUT   : out std_logic
    );

end manydevicelink;

architecture Behavioral of manydevicelink is

  constant DEVICELINKN : integer := 16+3;

  component linktester

    port (
      CLK       : in  std_logic;
      RXBITCLK  : in  std_logic;
      TXHBITCLK : in  std_logic;
      TXWORDCLK : in  std_logic;
      RESET     : in  std_logic;
      TXIO_P    : out std_logic;
      TXIO_N    : out std_logic;
      RXIO_P    : in  std_logic;
      RXIO_N    : in  std_logic;
      VALID     : out std_logic
      );

  end component;

  signal clk, clkint : std_logic := '0';

  signal clksrc, clksrcint   : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';

  signal clkbittxint, clkbittx       : std_logic := '0';
  signal clkbittx180int, clkbittx180 : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkrxint, clkrx       : std_logic := '0';


  signal dc, dcint : std_logic                     := '0';
  signal ledtick   : std_logic_vector(23 downto 0) := (others => '0');
  signal validint  : std_logic_vector(DEVICELINKN-1 downto 0)
                                                   := (others => '0');

  signal base_lock      : std_logic                    := '0';
  signal base_rst       : std_logic                    := '0';
  signal base_rst_delay : std_logic_vector(9 downto 0) := (others => '1');

  signal maindcmlocked : std_logic := '0';
  signal dcmreset      : std_logic := '1';


  type uptimearray_t is array (0 to DEVICELINKN-1) of std_logic_vector(7 downto 0);
  signal   uptimearray : uptimearray_t := (others => (others => '0'));
  constant UPTIMETICKN : integer       := 50000000;

  signal uptimetickcnt : integer range 0 to UPTIMETICKN - 1 := 0;
  signal uptimetick    : std_logic                          := '0';

  signal uptimesreg : std_logic_vector(DEVICELINKN*8-1 downto 0) := (others => '0');

  signal jtagcapture, jtagdrck, jtagreset, jtagsel,
    jtagshift, jtagtdi, jtagupdate, jtagtdo : std_logic := '0';


begin  -- Behavioral

  txsrc : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 2,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 5,       -- Can be any integer from 2 to 32
      CLKIN_PERIOD          => 15.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      FACTORY_JF            => X"F0F0",
      PHASE_SHIFT           => 0,
      STARTUP_WAIT          => false)
    port map(
      CLKIN                 => CLKIN,
      CLK0                  => clkint,
      CLKFB                 => clk,
      CLKFX                 => clksrcint,
      RST                   => RESET,
      LOCKED                => base_lock
      );

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clksrc_bufg : BUFG
    port map (
      O => clksrc,
      I => clksrcint);


  clkbittx_bufg : BUFG
    port map (
      O => clkbittx,
      I => clkbittxint);

  clkbittx180_bufg : BUFG
    port map (
      O => clkbittx180,
      I => clkbittx180int);


  process(clk)
  begin
    if rising_edge(clk) then
      base_rst_delay <= base_rst_delay(8 downto 0) & (not base_lock);
    end if;
  end process;

  maindcm : DCM_BASE
    generic map (
      CLKDV_DIVIDE          => 3.0,
      CLKFX_MULTIPLY        => 5,
      CLKFX_DIVIDE          => 3,
      CLKIN_PERIOD          => 2.5,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      FACTORY_JF            => X"F0F0",
      PHASE_SHIFT           => 0,
      STARTUP_WAIT          => false)
    port map(
      CLKIN                 => clksrc,
      clk0                  => clknoneint,
      CLKFB                 => clknone,

      CLK2X    => clkbittxint,
      CLK2X180 => clkbittx180int,
      CLKFX    => clkbitrxint,
      CLKDV    => clkrxint,
      RST      => base_rst_delay(7),
      LOCKED   => maindcmlocked
      );

  dcmreset <= not maindcmlocked;

  clknonebufg : BUFG
    port map (
      O => clknone,
      I => clknoneint);


  clkbitrxbufg : BUFG
    port map (
      O => clkbitrx,
      I => clkbitrxint);

  clkrxbuft : BUFG
    port map (
      O => clkrx,
      I => clkrxint);


  -- instantiate devices

  devicelinks : for i in 0 to DEVICELINKN-1 generate
    dl        : linktester
      port map (
        CLK       => clkrx,
        RXBITCLK  => clkbitrx,
        TXHBITCLK => clkbittx,
        TXWORDCLK => clk,
        RESET     => RESET,
        TXIO_P    => TXIO_P(i),
        TXIO_N    => TXIO_N(i),
        RXIO_P    => RXIO_P(i),
        RXIO_N    => RXIO_N(i),
        VALID     => validint(i));

  end generate devicelinks;


  uptimechecks : for i in 0 to DEVICELINKN - 1 generate
    process(CLK, jtagupdate)
    begin
      if rising_edge(CLK) then
        if validint(i) = '1' then
          if uptimetick = '1' then
            uptimearray(i) <= uptimearray(i) + 1;
          end if;
        else
          uptimearray(i)   <= (others => '0');
        end if;

      end if;

      if rising_edge(jtagupdate) then
        uptimesreg(i*8+7 downto i*8) <= uptimearray(i);
      end if;
    end process;
  end generate uptimechecks;

  uptimetickproc : process(CLK)
  begin
    if rising_edge(CLK) then
      if uptimetickcnt = UPTIMETICKN -1 then
        uptimetickcnt <= 0;
        uptimetick    <= '1';
      else
        uptimetickcnt <= uptimetickcnt + 1;
        uptimetick    <= '0';
      end if;

    end if;
  end process uptimetickproc;


  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clkrx,
      RST    => dcmreset
      );

  ledblink : process(clkrx)
  begin
    if rising_edge(clkrx) then
      ledtick  <= ledtick + 1;
      LEDPOWER <= ledtick(22);

    end if;
  end process ledblink;

  LEDVALID <= validint(0);

  WORDCLKOUT <= clkrx;
  TXCLKOUT   <= clkbittx;


  ----------------------------------------------------------------------------
  -- JTAG OUTPUT
  ---------------------------------------------------------------------------

  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE    => jtagcapture,
      DRCK       => jtagdrck,
      reset      => jtagreset,
      SEL        => jtagsel,
      SHIFT      => jtagshift,
      TDI        => jtagtdi,
      UPDATE     => jtagupdate,
      TDO        => jtagtdo);

  -- output read
  process(jtagupdate, jtagsel, jtagdrck, jtagshift)
    variable tdopos : integer range 0 to (DEVICELINKN*8 -1) := 0;
  begin

    if jtagupdate = '1' then
      tdopos     := DEVICELINKN*8 -1;
    elsif falling_edge(jtagdrck) then
      if jtagsel = '1' then
        if tdopos = DEVICELINKN*8 - 1 then
          tdopos := 0;
        else
          tdopos := tdopos + 1;
        end if;

      end if;
    end if;
    jtagtdo <= uptimesreg(tdopos);
  end process;

end Behavioral;
