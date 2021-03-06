library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;
library jtag;
use jtag.all;


library network;
use network.all;
library syscon;
use syscon.all;


library UNISIM;
use UNISIM.VComponents.all;

entity nettest is
  port (
    CLKIN         : in    std_logic;
    SERIALBOOT    : out   std_logic_vector(19 downto 0);
    -- SPI interface
    SPIMOSI       : in    std_logic;
    SPIMISO       : out   std_logic;
    SPICS         : in    std_logic;
    SPICLK        : in    std_logic;
    -- LEDS
    LEDPOWER      : out   std_logic;
    LEDEVENT      : out   std_logic;
    -- NIC interface
    NICFCLK       : out   std_logic;
    NICFDIN       : out   std_logic;
    NICFPROG      : out   std_logic;
    NICSCLK       : out   std_logic;
    NICSIN        : in    std_logic;
    NICSOUT       : out   std_logic;
    NICSCS        : out   std_logic;
    NICDOUT       : out   std_logic_vector(15 downto 0);
    NICNEWFRAME   : out   std_logic;
    NICDIN        : in    std_logic_vector(15 downto 0);
    NICNEXTFRAME  : out   std_logic;
    NICDINEN      : in    std_logic;
    NICIOCLK      : out   std_logic;
    RAMCLKOUT_P   : out   std_logic;
    RAMCLKOUT_N   : out   std_logic;
    RAMCKE        : out   std_logic := '0';
    RAMCAS        : out   std_logic;
    RAMRAS        : out   std_logic;
    RAMCS         : out   std_logic;
    RAMWE         : out   std_logic;
    RAMADDR       : out   std_logic_vector(12 downto 0);
    RAMBA         : out   std_logic_vector(1 downto 0);
    RAMDQSH       : inout std_logic;
    RAMDQSL       : inout std_logic;
    RAMDQ         : inout std_logic_vector(15 downto 0);
    FIBERDEBUGOUT : out   std_logic;
    FIBERDEBUGIN  : in    std_logic
    );
end nettest;


architecture Behavioral of nettest is

  signal ECYCLE : std_logic := '0';

  signal EARX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDRX    : somabackplane.dataarray      := (others => (others => '0'));
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');
  signal RESET   : std_logic                    := '0';

  signal lserialboot : std_logic_vector(19 downto 0) := (others => '1');

  signal douta   : std_logic_vector(7 downto 0) := (others => '0');
  signal doutena : std_logic                    := '0';

  signal doutb   : std_logic_vector(7 downto 0) := (others => '0');
  signal doutenb : std_logic                    := '0';


  signal clk, clkint             : std_logic := '0';
  signal clk2x, clk2xint         : std_logic := '0';
  signal clk180, clk180int       : std_logic := '0';
  signal memclkb, memclkbint     : std_logic := '0';
  signal memclk, memclkint       : std_logic := '0';
  signal memclk90, memclk90int   : std_logic := '0';
  signal memclk180, memclk180int : std_logic := '0';
  signal memclk270, memclk270int : std_logic := '0';


  signal nicclkint : std_logic := '0';


-- nic config signals
  signal myip, mybcast : std_logic_vector(31 downto 0) := (others => '0');
  signal mymac         : std_logic_vector(47 downto 0) := (others => '0');

  -- error signals and counters
  signal rxiocrcerr   : std_logic                     := '0';
  signal UNKNOWNETHER : std_logic                     := '0';
  signal UNKNOWNIP    : std_logic                     := '0';
  signal UNKNOWNUDP   : std_logic                     := '0';
  signal UNKNOWNARP   : std_logic                     := '0';
  signal txpktlenen   : std_logic                     := '0';
  signal txpktlen     : std_logic_vector(15 downto 0) := (others => '0');
  signal txchan       : std_logic_vector(2 downto 0)  := (others => '0');
  signal evtrxsuc     : std_logic                     := '0';
  signal evtfifofull  : std_logic                     := '0';


  signal nicnextframeint : std_logic := '0';

  signal locked, locked2 : std_logic                    := '0';
  signal resetint        : std_logic_vector(7 downto 0) := (others => '1');

  signal niciointclk : std_logic                     := '0';
  signal nicdinl     : std_logic_vector(15 downto 0) := (others => '0');
  signal nicdinenl   : std_logic                     := '0';


  signal fiberdebugdest : std_logic_vector(somabackplane.N-1 downto 0) := (others => '0');

  signal fibertxclk, fibertxclkint           : std_logic := '0';
  signal fibertxclkdummy, fibertxclkintdummy : std_logic := '0';

  signal lnicdout     : std_logic_vector(15 downto 0) := (others => '0');
  signal lnicnewframe : std_logic                     := '0';

  signal fiberdebugdebug : std_logic_vector(15 downto 0) := (others => '0');

  signal jtagesenddebug : std_logic_vector(7 downto 0) := (others => '0');

begin  -- Behavioral


  ---------------------------------------------------------------------------
  -- CLOCKING
  ---------------------------------------------------------------------------

  DCM_BASE_inst : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKFX_DIVIDE          => 1,
      CLKFX_MULTIPLY        => 3,
      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 20.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => true)
    port map (
      CLK0                  => clkint,      -- 0 degree DCM CLK ouptput
      CLK2x                 => clk2xint,
      CLKFX                 => memclkbint,  -- DCM CLK synthesis out (M/D)
      CLKFB                 => clk,
      CLK180                => clk180int,
      CLK90                 => niciointclk,
      CLKIN                 => CLKIN,
      LOCKED                => locked,
      RST                   => '0'          -- DCM asynchronous reset input
      );

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clk180_bufg : BUFG
    port map (
      I => clk180int,
      O => clk180);

  clk2x_bufg : BUFG
    port map (
      I => clk2xint,
      O => clk2x);

  memclkb_bufg : BUFG
    port map (
      O => memclkb,
      I => memclkbint);

  process(CLK)
  begin
    if rising_edge(CLK) then
      resetint <= resetint(6 downto 0) & (not locked);
    end if;
  end process;


  DCM_BASE_inst2 : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 6.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => false)
    port map (
      CLK0                  => memclkint,
      CLK180                => memclk180int,
      CLK270                => memclk270int,
      CLK90                 => memclk90int,
      CLKFB                 => memclk,
      CLKIN                 => memclkb,
      LOCKED                => locked2,
      RST                   => resetint(7)

      );

  RESET <= not locked2;

  memclk_bufg : BUFG
    port map (
      O => memclk,
      I => memclkint);

  memclk90_bufg : BUFG
    port map (
      O => memclk90,
      I => memclk90int);

  memclk180_bufg : BUFG
    port map (
      O => memclk180,
      I => memclk180int);

  memclk270_bufg : BUFG
    port map (
      O => memclk270,
      I => memclk270int);

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => RAMCLKOUT_P,
      OB         => RAMCLKOUT_N,
      I          => memclk270
      );

  eventrouter_inst : entity soma.eventrouter
    port map (
      CLK     => clk,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EATX    => EATX,
      EDTX    => EDTX);

  timer_inst : entity soma.timer
    port map (
      CLK     => clk,
      ECYCLe  => ECYCLE,
      EARX    => EARX(0),
      EDRX    => EDRX(0),
      EDSELRX => EDSELRX,
      EATX    => EATX(0),
      EDTX    => EDTX);

  syscontrol_inst : entity syscon.syscontrol
    port map (
      CLK     => clk,
      CLK2X   => clk2x,
      RESET   => RESET,
      ECYCLe  => ECYCLE,
      EARX    => EARX(1),
      EDRX    => EDRX(1),
      EDSELRX => EDSELRX,
      EATX    => EATX(1),
      EDTX    => EDTX,
      SEROUT  => lserialboot);

  bootstore_inst : entity soma.bootstore
    generic map (
      DEVICE  => X"02")
    port map (
      CLK     => clk,
      CLKHI   => memclk,
      RESET   => RESET,
      ECYCLE  => ECYCLE,
      EARX    => EARX(2),
      EDRX    => EDRX(2),
      EDSELRX => EDSELRX,
      EATX    => EATX(2),
      EDTX    => EDTX,
      SPIMOSI => SPIMOSI,
      SPIMISO => SPIMISO,
      SPICS   => SPICS,
      SPICLK  => SPICLK);

  bootdeserialize_inst : entity soma.bootdeserialize
    port map (
      CLK   => clk2x,
      SERIN => lserialboot(0),
      FPROG => NICFPROG,
      FCLK  => NICFCLK,
      FDIN  => NICFDIN);

  SERIALBOOT <= lserialboot;


  LEDPOWER <= lserialboot(0); 
  LEDEVENT <= jtagesenddebug(1);

  jtagsend_inst : entity jtag.jtagesend
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CLK        => clk,
      ECYCLE     => ecycle,
      EARX       => earx(7),
      EDRX       => edrx(7),
      EDSELRX    => edselrx,
      DEBUG      => jtagesenddebug);

  jtagreceive_inst : entity jtag.jtagereceive
    generic map (
      JTAG_CHAIN_MASK => 2,
      JTAG_CHAIN_OUT  => 3 )
    port map (
      CLK             => clk,
      ECYCLE          => ecycle,
      EDTX            => edtx,
      EATX            => eatx(7),
      DEBUG           => open);

  ether_inst : entity soma.ether
    generic map (
      DEVICE  => X"05")
    port map (
      CLK     => clk,
      RESET   => reset,
      EDTX    => edtx,
      EATX    => eatx(5),
      ECYCLE  => ecycle,
      EARX    => earx(5),
      EDRX    => edrx(5),
      EDSELRX => edselrx,
      SOUT    => NICSOUT,
      SIN     => NICSIN,
      SCLK    => NICSCLK,
      SCS     => NICSCS);


  DCM_fibertx_inst : DCM_BASE
    generic map (
      CLKFX_DIVIDE   => 5,
      CLKFX_MULTIPLY => 8,
      STARTUP_WAIT   => true)
    port map (
      CLKFX          => fibertxclkint,
      CLKIN          => clk,
      CLK0           => fibertxclkintdummy,
      CLKFB          => fibertxclkdummy,
      LOCKED         => open,
      RST            => '0'             -- DCM asynchronous reset input
      );

  clk_fibertx_bufg : BUFG
    port map (
      O => fibertxclk,
      I => fibertxclkint);

  clk_fibertxdummy_bufg : BUFG
    port map (
      O => fibertxclkdummy,
      I => fibertxclkintdummy);

  fiberdebug_inst : entity soma.fiberdebug
    generic map (
      DEVICE    => X"4C")
    port map (
      CLK       => CLK,
      TXCLK     => fibertxclk,
      RESET     => reset,
      ECYCLE    => ecycle,
      EARXA     => earx(70),
      EDRXA     => edrx(70),
      EDSELRXA  => edselrx,
      EARXB     => earx(71),
      EDRXB     => edrx(71),
      EDSELRXB  => edselrx,
      EATX      => eatx(70),
      EDTX      => edtx,
      EADDRDEST => fiberdebugdest,
      FIBERIN   => FIBERDEBUGIN,
      FIBEROUT  => FIBERDEBUGOUT,
      DEBUG     => fiberdebugdebug);


  fakedata1 : entity fakedata
    port map (
      clk    => clk,
      DOUT   => douta,
      DOUTEN => doutena,
      ECYCLE => ecycle);

  -- dummy
  process(clk)
    variable blinkcnt : std_logic_vector(21 downto 0)
               := (others => '0');
  begin
    if rising_edge(clk) then
      blinkcnt := blinkcnt + 1;

    end if;
  end process;

-- NETCLK <= clk;



-- myip <= X"0A000002";                 -- 10.0.0.2
--   mybcast <= X"FFFFFFFF";            -- 10.255.255.255

-- mymac <= X"00ADBEEF1234";

  fiberdebugdest(3) <= '1';
  network_inst : entity network.network
    port map (
      CLK       => CLK,
      MEMCLK    => memclk,
      MEMCLK90  => memclk90,
      MEMCLK180 => memclk180,
      MEMCLK270 => memclk270,
      RESET     => RESET,
      -- config
      MYIP      => MYIP,
      MYMAC     => mymac,
      MYBCAST   => mybcast,

      -- input
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => nicdinenl,
      NICDIN       => nicdinl,
      -- output
      NICDOUT      => lNICDOUT,
      NICNEWFRAME  => lNICNEWFRAME,
      NICIOCLK     => open,             --NICIOCLK,
      -- event bus
      ECYCLE       => ecycle,
      EARX         => earx(3),
      EDRX         => edrx(3),
      EDSELRX      => edselrx,
      EATX         => eatx(3),
      EDTX         => edtx,

      -- data bus
      DIENA => doutena,
      DIENB => '0',
      DINA  => douta,
      DINB  => X"00",

      -- memory interface
      RAMCKE  => RAMCKE,
      RAMCAS  => RAMCAS,
      RAMRAS  => RAMRAS,
      RAMCS   => RAMCS,
      RAMWE   => RAMWE,
      RAMADDR => RAMADDR,
      RAMBA   => RAMBA,
      RAMDQSH => RAMDQSH,
      RAMDQSL => RAMDQSL,
      RAMDQ   => RAMDQ,

      -- counters
      RXIOCRCERR   => rxiocrcerr,
      UNKNOWNETHER => unknownether,
      UNKNOWNIP    => unknownip,
      UNKNOWNUDP   => unknownudp,
      UNKNOWNARP   => unknownarp,
      TXPKTLENEN   => txpktlenen,
      TXPKTLEN     => txpktlen,
      TXCHAN       => txchan,
      EVTRXSUC     => evtrxsuc,
      EVTFIFOFULL  => evtfifofull

      );

  netcontrol_inst : entity soma.netcontrol
    generic map (
      DEVICE       => X"04")
    port map (
      CLK          => CLK,
      RESET        => RESET,
      ECYCLE       => ECYCLE,
      EDTX         => EDTX,
      EATX         => EATX(4),
      EARX         => EARX(4),
      EDRX         => EDRX(4),
      EDSELRX      => EDSELRX,
      TXPKTLENEN   => txpktlenen,
      TXPKTLEN     => txpktlen,
      TXCHAN       => txchan,
      RXIOCRCERR   => rxiocrcerr,
      UNKNOWNETHER => unknownether,
      UNKNOWNIP    => unknownip,
      UNKNOWNARP   => unknownarp,
      UNKNOWNUDP   => unknownudp,
      EVTRXSUC     => evtrxsuc,
      EVTFIFOFULL  => evtfifofull,
      MYMAC        => mymac,
      MYBCAST      => mybcast,
      MYIP         => myip
      );


  NICIOCLK <= clk;

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clk,
      RST    => reset
      );

  process(niciointclk)
  begin

    if rising_edge(niciointclk) then
      nicdinenl <= NICDINEN;
      nicdinl   <= NICDIN;

    end if;

  end process;

  process(CLK)
  begin
    if rising_edge(CLK) then
      NICDOUT     <= lnicdout;
      NICNEWFRAME <= lnicnewframe;

    end if;
  end process;
end Behavioral;
