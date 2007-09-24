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

entity backplane is
  port (
    CLKIN         : in    std_logic;
    SERIALBOOT    : out   std_logic_vector(19 downto 0);
    SDOUT         : out   std_logic;
    SDIN          : in    std_logic;
    SCLK          : out   std_logic;
    SCS           : out   std_logic;
    LEDPOWER      : out   std_logic;
    LEDEVENT      : out   std_logic;
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

    -- DeviceLink Interfaces
    TXIO_P     : out std_logic_vector(18 downto 0);
    TXIO_N     : out std_logic_vector(18 downto 0);
    RXIO_P     : in  std_logic_vector(18 downto 0);
    RXIO_N     : in  std_logic_vector(18 downto 0);
    -- debugging
    
    FIBERDEBUGOUT : out   std_logic;
    FIBERDEBUGIN  : in    std_logic


    );
end backplane;


architecture Behavioral of backplane is

  component eventrouter
    port (
      CLK     : in  std_logic;
      ECYCLE  : in  std_logic;
      EARX    : in  somabackplane.addrarray;
      EDRX    : in  somabackplane.dataarray;
      EDSELRX : out std_logic_vector(3 downto 0);
      EATX    : out somabackplane.addrarray;
      EDTX    : out std_logic_vector(7 downto 0)
      );
  end component;

  component timer
    port (
      CLK     : in  std_logic;
      ECYCLE  : out std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0)
      );
  end component;

  component syscontrol
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0)
      );
  end component;

  component boot
    generic (
      M       :     integer                      := 20;
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SDOUT   : out std_logic;
      SDIN    : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic;
      SEROUT  : out std_logic_vector(M-1 downto 0);
      DEBUG   : out std_logic_vector(1 downto 0));
  end component;


  component bootdeserialize
    port (
      CLK   : in  std_logic;
      SERIN : in  std_logic;
      FPROG : out std_logic;
      FCLK  : out std_logic;
      FDIN  : out std_logic);
  end component;


  component jtagesend
    generic (
      JTAG_CHAIN :     integer := 1);
    port (
      CLK        : in  std_logic;
      ECYCLE     : in  std_logic;
      EARX       : out std_logic_vector(somabackplane.N - 1 downto 0)
                               := (others => '0');
      EDRX       : out std_logic_vector(7 downto 0);
      EDSELRX    : in  std_logic_vector(3 downto 0)
      );
  end component;

  component jtagereceive
    generic (
      JTAG_CHAIN_MASK :     integer := 1;
      JTAG_CHAIN_OUT  :     integer := 1
      );
    port (
      CLK             : in  std_logic;
      ECYCLE          : in  std_logic;
      EDTX            : in  std_logic_vector(7 downto 0);
      EATX            : in  std_logic_vector(somabackplane.N - 1 downto 0);
      DEBUG           : out std_logic_vector(3 downto 0)
      );
  end component;

  component ether
    generic (
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                 := (others => '0');
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SOUT    : out std_logic;
      SIN     : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic);
  end component;

  component udpburst
    port (
      CLK      : in  std_logic;
      NEWFRAME : out std_logic;
      DOUT     : out std_logic_vector(15 downto 0));
  end component;

  component network
    port (
      CLK       : in std_logic;
      MEMCLK    : in std_logic;
      MEMCLK90  : in std_logic;
      MEMCLK180 : in std_logic;
      MEMCLK270 : in std_logic;

      RESET        : in    std_logic;
      -- config
      MYIP         : in    std_logic_vector(31 downto 0);
      MYMAC        : in    std_logic_vector(47 downto 0);
      MYBCAST      : in    std_logic_vector(31 downto 0);
      -- input
      NICNEXTFRAME : out   std_logic;
      NICDINEN     : in    std_logic;
      NICDIN       : in    std_logic_vector(15 downto 0);
      -- output
      NICDOUT      : out   std_logic_vector(15 downto 0);
      NICNEWFRAME  : out   std_logic;
      NICIOCLK     : out   std_logic;
      -- event bus
      ECYCLE       : in    std_logic;
      EARX         : out   std_logic_vector(somabackplane.N -1 downto 0);
      EDRX         : out   std_logic_vector(7 downto 0);
      EDSELRX      : in    std_logic_vector(3 downto 0);
      EATX         : in    std_logic_vector(somabackplane.N -1 downto 0);
      EDTX         : in    std_logic_vector(7 downto 0);
      -- data bus
      DIENA        : in    std_logic;
      DINA         : in    std_logic_vector(7 downto 0);
      DIENB        : in    std_logic;
      DINB         : in    std_logic_vector(7 downto 0);
      -- memory interface
      RAMCKE       : out   std_logic := '0';
      RAMCAS       : out   std_logic;
      RAMRAS       : out   std_logic;
      RAMCS        : out   std_logic;
      RAMWE        : out   std_logic;
      RAMADDR      : out   std_logic_vector(12 downto 0);
      RAMBA        : out   std_logic_vector(1 downto 0);
      RAMDQSH      : inout std_logic;
      RAMDQSL      : inout std_logic;
      RAMDQ        : inout std_logic_vector(15 downto 0);
      -- error signals and counters
      RXIOCRCERR   : out   std_logic;
      UNKNOWNETHER : out   std_logic;
      UNKNOWNIP    : out   std_logic;
      UNKNOWNUDP   : out   std_logic;
      UNKNOWNARP   : out   std_logic;
      TXPKTLENEN   : out   std_logic;
      TXPKTLEN     : out   std_logic_vector(15 downto 0);
      TXCHAN       : out   std_logic_vector(2 downto 0);
      EVTRXSUC     : out   std_logic;
      EVTFIFOFULL  : out   std_logic



      );
  end component;


  component netcontrol
    generic (
      DEVICE       :     std_logic_vector(7 downto 0) := X"01";
      CMDCNTQUERY  :     std_logic_vector(7 downto 0) := X"40";
      CMDCNTRST    :     std_logic_vector(7 downto 0) := X"41";
      CMDNETWRITE  :     std_logic_vector(7 downto 0) := X"42";
      CMDNETQUERY  :     std_logic_vector(7 downto 0) := X"43";
      CMDNETRESP   :     std_logic_vector(7 downto 0) := X"50";
      CMDCNTRESP   :     std_logic_vector(7 downto 0) := X"51"
      );
    port (
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      -- standard event-bus interface
      ECYCLE       : in  std_logic;
      EDTX         : in  std_logic_vector(7 downto 0);
      EATX         : in  std_logic_vector(somabackplane.N - 1 downto 0);
      EARX         : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX         : out std_logic_vector(7 downto 0);
      EDSELRX      : in  std_logic_vector(3 downto 0);
      -- tx counter input
      TXPKTLENEN   : in  std_logic;
      TXPKTLEN     : in  std_logic_vector(15 downto 0);
      TXCHAN       : in  std_logic_vector(2 downto 0);
      -- other counters
      RXIOCRCERR   : in  std_logic;
      UNKNOWNETHER : in  std_logic;
      UNKNOWNIP    : in  std_logic;
      UNKNOWNARP   : in  std_logic;
      UNKNOWNUDP   : in  std_logic;
      EVTRXSUC     : in  std_logic;
      EVTFIFOFULL  : in  std_logic;


      -- output network control settings
      MYMAC   : out std_logic_vector(47 downto 0);
      MYBCAST : out std_logic_vector(31 downto 0);
      MYIP    : out std_logic_vector(31 downto 0)

      );

  end component;

  component pingdump
    port (
      CLK      : in  std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic);        -- (others => '0')
  end component;

  component dincapture
    port (
      CLK   : in std_logic;
      DINEN : in std_logic;
      DIN   : in std_logic_vector(15 downto 0)
      );
  end component;

  component fakedata
    port (
      CLK    : in  std_logic;
      DOUT   : out std_logic_vector(7 downto 0);
      DOUTEN : out std_logic;
      ECYCLE : in  std_logic
      );
  end component;

  component fiberdebug
    generic (
      DEVICE    :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK       : in  std_logic;
      TXCLK     : in  std_logic;
      RESET     : in  std_logic;
      -- Event bus interface
      ECYCLE    : in  std_logic;
      EARXA     : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                   := (others => '0');
      EDRXA     : out std_logic_vector(7 downto 0);
      EARXB     : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                   := (others => '0');
      EDRXB     : out std_logic_vector(7 downto 0);
      EDSELRXA  : in  std_logic_vector(3 downto 0);
      EDSELRXB  : in  std_logic_vector(3 downto 0);
      EATX      : in  std_logic_vector(somabackplane.N - 1 downto 0);
      EDTX      : in  std_logic_vector(7 downto 0);
      EADDRDEST :     std_logic_vector(somabackplane.N -1 downto 0);

      -- Fiber interfaces
      FIBERIN  : in  std_logic;
      FIBEROUT : out std_logic;
      DEBUG : out std_Logic_vector(15 downto 0)
      );

  end component;

  component devicelinkclk 
  port (
    CLKIN       : in  std_logic;
    CLKBITTX    : out std_logic;
    CLKBITTX180 : out std_logic;
    CLKBITRX    : out std_logic;
    CLKRX       : out std_logic;
    STARTUPDONE : out std_logic);
  end component;


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

  signal bittxclk : std_logic := '0';
  signal bittxclk180 : std_logic := '0';
  signal bitrxclk : std_logic := '0';
  signal rxclk : std_logic := '0';
  

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

  constant DEVICELINKN : integer := 2;
  --constant DEVICELINKN : integer := 16+3;  DEBUGGING
  signal validint  : std_logic_vector(DEVICELINKN-1 downto 0)
                                                   := (others => '0');
  
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

  eventrouter_inst : eventrouter
    port map (
      CLK     => clk,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EATX    => EATX,
      EDTX    => EDTX);

  timer_inst : timer
    port map (
      CLK     => clk,
      ECYCLe  => ECYCLE,
      EARX    => EARX(0),
      EDRX    => EDRX(0),
      EDSELRX => EDSELRX,
      EATX    => EATX(0),
      EDTX    => EDTX);

  syscontrol_inst : syscontrol
    port map (
      CLK     => clk,
      RESET   => RESET,
      ECYCLe  => ECYCLE,
      EARX    => EARX(1),
      EDRX    => EDRX(1),
      EDSELRX => EDSELRX,
      EATX    => EATX(1),
      EDTX    => EDTX);

  boot_inst : boot
    generic map (
      M      => 20,
      DEVICE => X"02")

    port map (
      CLk     => clk,
      RESET   => RESET,
      ECYCLE  => ECYCLE,
      EARX    => EARX(2),
      EDRX    => EDRX(2),
      EDSELRX => EDSELRX,
      EATX    => EATX(2),
      EDTX    => EDTX,
      SDOUT   => SDOUT,
      SDIN    => SDIN,
      SCLK    => SCLK,
      SCS     => SCS,
      SEROUT  => lserialboot,
      DEBUG   => open);

  bootdeserialize_inst : bootdeserialize
    port map (
      CLK   => clk,
      SERIN => lserialboot(0),
      FPROG => NICFPROG,
      FCLK  => NICFCLK,
      FDIN  => NICFDIN);

  SERIALBOOT <= lserialboot;

  LEDEVENT <= fiberdebugdebug(0);
  LEDPOWER <= locked2;

  jtagsend_inst : jtagesend
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CLK        => clk,
      ECYCLE     => ecycle,
      EARX       => earx(7),
      EDRX       => edrx(7),
      EDSELRX    => edselrx);

  jtagreceive_inst : jtagereceive
    generic map (
      JTAG_CHAIN_MASK => 2,
      JTAG_CHAIN_OUT  => 3 )
    port map (
      CLK             => clk,
      ECYCLE          => ecycle,
      EDTX            => edtx,
      EATX            => eatx(7),
      DEBUG           => open);

  ether_inst : ether
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

  fiberdebug_inst : fiberdebug
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
      DEBUG => fiberdebugdebug);


  devicelinkclk_inst: devicelinkclk
    port map (
      CLKIN       => clk,
      CLKBITTX    => bittxclk,
      CLKBITTX180 => bittxclk180,
      CLKBITRX    => bitrxclk,
      CLKRX       => rxclk,
      STARTUPDONE => open);
  
    
  fakedata1 : fakedata
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



  myip    <= X"0A000002";               -- 10.0.0.2
  mybcast <= X"FFFFFFFF";               -- 10.255.255.255

  mymac <= X"00ADBEEF1234";

  fiberdebugdest(3) <= '1';
  network_inst : network
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

  netcontrol_inst : netcontrol
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
      EVTFIFOFULL  => evtfifofull
-- MYMAC => mymac,
-- MYBCAST => mybcast,
-- MYIP => myip

      );


  NICIOCLK <= clk;

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clk,
      RST    => reset
      );

-- dincapture_inst : dincapture
-- port map (
-- CLK => clk,
-- DIN => lnicdout,
-- DINEN => lnicnewframe);

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


 ------------------------------------------------------------------------------
 -- at the moment, a devicelink test, from manydevicelinktes 
 ------------------------------------------------------------------------------


    devicelinks : for i in 0 to DEVICELINKN-1 generate
    dl        : linktester
      port map (
        CLK       => rxclk,
        RXBITCLK  => bitrxclk,
        TXHBITCLK => bittxclk,
        TXWORDCLK => clk,
        RESET     => RESET,
        TXIO_P    => TXIO_P(i),
        TXIO_N    => TXIO_N(i),
        RXIO_P    => RXIO_P(i),
        RXIO_N    => RXIO_N(i),
        VALID     => validint(i));

  end generate devicelinks;

    
end Behavioral;
