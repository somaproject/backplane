
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

  constant DEVICELINKN : integer := 19;

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
  signal clkwordtx       : std_logic := '0';


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

  
  component devicelinkclk
    port (
      CLKIN       : in  std_logic;
      CLKBITTX    : out std_logic;
      CLKBITTX180 : out std_logic;
      CLKBITRX    : out std_logic;
      CLKWORDTX   : out std_logic;
      STARTUPDONE : out std_logic);
  end component;

begin  -- Behavioral

  clk <= CLKIN;
  
  devicelinkclk_inst : devicelinkclk
    port map (
      CLKIN       => CLK,
      CLKBITTX    => clkbittx,
      CLKBITTX180 => clkbittx180,
      CLKBITRX    => clkbitrx,
      CLKWORDTX   => clkwordtx,
      STARTUPDONE => maindcmlocked);
  
  -- instantiate devices

  devicelinks : for i in 0 to DEVICELINKN-1 generate
    dl        : linktester
      port map (
        CLK       => CLKIN,
        RXBITCLK  => clkbitrx,
        TXHBITCLK => clkbittx,
        TXWORDCLK => clkwordtx,
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

  ledblink : process(clk)
  begin
    if rising_edge(clk) then
      ledtick  <= ledtick + 1;

    end if;
  end process ledblink;
  LEDPOWER <= maindcmlocked; 

  LEDVALID <= validint(0);

  WORDCLKOUT <= clkwordtx;
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
