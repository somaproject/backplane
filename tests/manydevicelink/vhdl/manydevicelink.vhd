
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity manydevicelink is
  port (
    CLKIN      : in  std_logic;
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

  constant DEVICELINKN : integer := 8;

  component linktester
    port (
      CLK         : in  std_logic;
      RXBITCLK    : in  std_logic;
      RXWORDCLK   : in  std_logic;
      TXHBITCLK   : in  std_logic;
      TXWORDCLK   : in  std_logic;
      AUTOLINK    : in  std_logic;
      ATTEMPTLINK : in  std_logic;
      RESET       : in  std_logic;
      TXIO_P      : out std_logic;
      TXIO_N      : out std_logic;
      RXIO_P      : in  std_logic;
      RXIO_N      : in  std_logic;
      VALID       : out std_logic;
      LOCKED      : out std_logic;
      DEBUGSTATE  : out std_logic_vector(7 downto 0);
      DEBUGVALUE  : out std_logic_vector(15 downto 0)
      );
  end component;

  signal clk, clkint : std_logic := '0';

  signal clksrc, clksrcint   : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';

  signal clkbittxint, clkbittx       : std_logic := '0';
  signal clkbittx180int, clkbittx180 : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkwordtx             : std_logic := '0';

  signal clkwordrx : std_logic := '0';

  signal dc, dcint : std_logic                     := '0';
  signal ledtick   : std_logic_vector(23 downto 0) := (others => '0');
  signal validint  : std_logic_vector(DEVICELINKN-1 downto 0)
 := (others => '0');

  signal lockedint, lockedintl : std_logic_vector(DEVICELINKN-1 downto 0)
 := (others => '0');

  signal base_lock      : std_logic                    := '0';
  signal base_rst       : std_logic                    := '0';
  signal base_rst_delay : std_logic_vector(9 downto 0) := (others => '1');

  signal maindcmlocked : std_logic := '0';
  signal dcmreset      : std_logic := '1';


  type     uptimearray_t is array (0 to DEVICELINKN-1) of std_logic_vector(7 downto 0);
  signal   uptimearray : uptimearray_t := (others => (others => '0'));
  constant UPTIMETICKN : integer       := 50000000;

  signal uptimetickcnt : integer range 0 to UPTIMETICKN - 1 := 0;
  signal uptimetick    : std_logic                          := '0';

  signal uptimesreg : std_logic_vector(DEVICELINKN*8-1 downto 0) := (others => '0');

  signal jtagoutreg            : std_logic_vector(63 downto 0) := (others => '0');
  signal jtaginreg, jtaginregl : std_logic_vector(63 downto 0) := (others => '0');

  signal jtaginsig : std_logic := '0';

  signal lockedarray : uptimearray_t := (others => (others => '0'));

  signal jtagcapture, jtagdrck, jtagreset, jtagsel,
    jtagshift, jtagtdi, jtagupdate, jtagtdo : std_logic := '0';

  signal jtagupdatel, jtagupdatell : std_logic := '0';
  signal jtagsell, jtagselll       : std_logic := '0';

  signal jtagcount : std_logic_vector(15 downto 0) := (others => '0');

  signal locked, nlocked, resetint : std_logic := '0';
  signal reset                     : std_logic := '0';

  type   debugstate_t is array (0 to DEVICELINKN-1) of std_logic_vector(7 downto 0);
  signal debugstate : debugstate_t := (others => (others => '0'));

  type   debugvalue_t is array (0 to DEVICELINKN-1) of std_logic_vector(15 downto 0);
  signal debugvalue : debugvalue_t := (others => (others => '0'));

  signal debugbuffer_in   : std_logic_vector(31 downto 0) := (others => '0');
  signal debugbuffer_en   : std_logic                     := '0';
  signal debugbuffer_next : std_logic                     := '0';

  signal testcounter    : std_logic_vector(7 downto 0)  := (others => '0');
  signal linkupduration : std_logic_vector(15 downto 0) := (others => '0');

  signal attemptlink : std_logic_vector(DEVICELINKN-1 downto 0) := (others => '0');
  signal autolink    : std_logic_vector(DEVICELINKN-1 downto 0) := (others => '0');

  component devicelinkclk
    port (
      CLKIN       : in  std_logic;
      CLKBITTX    : out std_logic;
      RESET       : in  std_logic;
      CLKBITTX180 : out std_logic;
      CLKBITRX    : out std_logic;
      CLKWORDRX   : out std_logic;
      CLKWORDTX   : out std_logic;
      STARTUPDONE : out std_logic);
  end component;

  component dincapture
    generic (
      JTAG_CHAIN : integer := 4);
    port (
      CLK        : in std_logic;
      DINEN      : in std_logic;
      NEXTBUFFER : in std_logic := '0';
      DIN        : in std_logic_vector(15 downto 0)
      ); 
  end component;


begin  -- Behavioral

  nlocked <= not locked;
  DCM_BASE_inst : DCM_BASE
    generic map (
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => true)
    port map (
      CLK0   => clkint,
      CLKFB  => clk,
      CLKIN  => CLKIN,
      LOCKED => locked,
      RST    => '0'
      );

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  reset <= not maindcmlocked;

  devicelinkclk_inst : devicelinkclk
    port map (
      CLKIN       => CLKIN,
      RESET       => '0',
      CLKBITTX    => clkbittx,
      CLKBITTX180 => clkbittx180,
      CLKBITRX    => clkbitrx,
      CLKWORDRX   => clkwordrx,
      CLKWORDTX   => clkwordtx,
      STARTUPDONE => maindcmlocked);

  -- instantiate devices

  devicelinks : for i in 0 to DEVICELINKN-1 generate
    dl : linktester
      port map (
        CLK         => CLK,
        RXBITCLK    => clkbitrx,
        TXHBITCLK   => clkbittx,
        RXWORDCLK   => clkwordrx,
        TXWORDCLK   => clkwordtx,
        RESET       => reset,
        AUTOLINK    => autolink(i),
        ATTEMPTLINK => attemptlink(i),
        TXIO_P      => TXIO_P(i),
        TXIO_N      => TXIO_N(i),
        RXIO_P      => RXIO_P(i),
        RXIO_N      => RXIO_N(i),
        VALID       => validint(i),
        LOCKED      => lockedint(i),
        DEBUGSTATE  => debugstate(i),
        DEBUGVALUE  => debugvalue(i));

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
          uptimearray(i) <= (others => '0');
        end if;

        if lockedintl(i) = '0' and lockedint(i) = '1' then
          lockedarray(i) <= lockedarray(i) + 1;
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
      ledtick    <= ledtick + 1;
      lockedintl <= lockedint;
      if debugstate(0)(7 downto 0) = X"03" then
        LEDPOWER <= '1';
      else
        LEDPOWER <= '0';
      end if;

    end if;
  end process ledblink;



  LEDVALID <= validint(0);

  WORDCLKOUT <= clkwordtx;
  TXCLKOUT   <= clkbittx;
  --TXCLKOUT <= '0'; 

  ----------------------------------------------------------------------------
  -- JTAG OUTPUT
  ---------------------------------------------------------------------------

  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE => jtagcapture,
      DRCK    => jtagdrck,
      reset   => jtagreset,
      SEL     => jtagsel,
      SHIFT   => jtagshift,
      TDI     => jtagtdi,
      UPDATE  => jtagupdate,
      TDO     => jtagtdo);

  process(CLK)
  begin
    if rising_edge(CLK) then
      if testcounter < debugstate(0) then
        testcounter <= debugstate(0);
      end if;
      if debugstate(0) = X"00" then
        linkupduration <= (others => '0');
      else
        linkupduration <= linkupduration + 1;
        
      end if;

      if jtagupdate = '1' then
        jtagoutreg(15 downto 0)  <= jtaginregl(15 downto 0);
        jtagoutreg(31 downto 16) <= jtagcount;
        jtagoutreg(47 downto 32) <= uptimearray(0) & lockedarray(0);
        jtagoutreg(63 downto 56) <= debugstate(0)(7 downto 0);
        
      end if;

      jtagsell     <= jtagsel;
      jtagselll    <= jtagsell;
      jtagupdatel  <= jtagupdate;
      jtagupdatell <= jtagupdatel;

      if jtagupdatel = '0' and jtagupdatell = '1' and jtagsell = '1' then
        jtaginsig <= '1';
      else
        jtaginsig <= '0';
      end if;

      if attemptlink(0) = '1' then
        jtagcount <= jtagcount + 1;
      end if;

      if jtaginsig = '1' and jtaginregl(1) = '1' then
        autolink(0) <= jtaginregl(2);
      end if;
    end if;
  end process;

  attemptlink(0) <= '1' when jtaginsig = '1' and jtaginregl(0) = '1' else '0';
  --autolink(0) <= '1'; 

  -- output read
  process(jtagupdate, jtagsel, jtagdrck, jtagshift)
    variable tdopos : integer range 0 to 63 := 0;
  begin

    if jtagupdate = '1' then
      tdopos     := 63;
      jtaginregl <= jtaginreg;
    elsif falling_edge(jtagdrck) then
      if jtagsel = '1' then
        if tdopos = 63 then
          tdopos := 0;
        else
          tdopos := tdopos + 1;
        end if;
        jtaginreg <= jtagtdi & jtaginreg(63 downto 1);
      end if;
    end if;
    jtagtdo <= jtagoutreg(tdopos);
  end process;

  -- input


  debugbuffer_en             <= '1';  --  when debugstate(0) = X"0C" else '0';
  debugbuffer_in(7 downto 0) <= debugstate(0);
  debugbuffer_in(15)         <= '1';

  debugbuffer_in(31 downto 16) <= debugvalue(0);
  debugbuffer_next             <= '1' when debugstate(0) = X"08" else '0';
  dincapture_test : dincapture
    generic map (
      JTAG_CHAIN => 4)
    port map (
      CLK        => CLK,
      DINEN      => debugbuffer_en,
      NEXTBUFFER => debugbuffer_next,
      DIN        => debugbuffer_in(15 downto 0));

  dincapture_test2 : dincapture
    generic map (
      JTAG_CHAIN => 3)
    port map (
      CLK        => CLK,
      DINEN      => debugbuffer_en,
      NEXTBUFFER => debugbuffer_next,
      DIN        => debugbuffer_in(31 downto 16));

  
end Behavioral;
