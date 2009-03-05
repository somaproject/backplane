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
library memory;
use memory.all;
library syscon;
use syscon.all;

library UNISIM;
use UNISIM.VComponents.all;

-- for instruction ram for syscontrol

--
entity backplane is
  port (
    CLKIN         : in    std_logic;
    DSPCFG        : out   std_logic_vector(15 downto 0);
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
    FIBERDEBUGIN  : in    std_logic;

    -- DeviceLink Serial interfaces
    -- DSP Boards
    DSPTXIO_P  : out std_logic_vector(15 downto 0);
    DSPTXIO_N  : out std_logic_vector(15 downto 0);
    DSPRXIO_P  : in  std_logic_vector(15 downto 0);
    DSPRXIO_N  : in  std_logic_vector(15 downto 0);
    -- ADIO
    ADIOTXIO_P : out std_logic;
    ADIOTXIO_N : out std_logic;
    ADIORXIO_P : in  std_logic;
    ADIORXIO_N : in  std_logic;
    ADIOCFG    : out std_logic;
    -- SYS / DISPLAY
    SYSTXIO_P  : out std_logic;
    SYSTXIO_N  : out std_logic;
    SYSRXIO_P  : in  std_logic;
    SYSRXIO_N  : in  std_logic;
    SYSCFG     : out std_logic;
    -- NEP
    NEPTXIO_P  : out std_logic;
    NEPTXIO_N  : out std_logic;
    NEPRXIO_P  : in  std_logic;
    NEPRXIO_N  : in  std_logic;
    NEPCFG     : out std_logic
    );
end backplane;


architecture Behavioral of backplane is

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

  signal dgrant : std_logic_vector(63 downto 0) := (others => '0');

  type   datadout_t is array (0 to 15) of std_logic_vector(7 downto 0);
  signal datadout : somabackplane.dataroutearray  := (others => (others => '0'));
  signal datadoen : std_logic_vector(15 downto 0) := (others => '0');

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

  signal ramdqalignh, ramdqalignl : std_logic_vector(7 downto 0) := (others => '0');

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

  -- devicelink clocks
  signal clkbittxint, clkbittx       : std_logic := '0';
  signal clkbittx180int, clkbittx180 : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkwordtx             : std_logic := '0';

  signal validint : std_logic_vector(18 downto 0) := (others => '0');

  signal maindcmlocked : std_logic := '0';

  constant DMOFFSET : integer := 8;

  signal txdinadio, rxdoutadio : std_logic_vector(7 downto 0) := (others => '0');
  signal txkinadio, rxkoutadio : std_logic                    := '0';
  signal dllockedadio          : std_logic                    := '0';

  signal txdinsys, rxdoutsys : std_logic_vector(7 downto 0) := (others => '0');
  signal txkinsys, rxkoutsys : std_logic                    := '0';
  signal dllockedsys         : std_logic                    := '0';

  signal dlinkup : std_logic_vector(31 downto 0) := (others => '0');

  signal jtagdebug       : std_logic_vector(31 downto 0) := (others => '0');
  signal netdebug        : std_logic_vector(31 downto 0) := (others => '0');
  signal dincapture_data : std_logic_vector(15 downto 0) := (others => '0');
  signal jtagjtagrxdebug : std_logic_vector(15 downto 0) := (others => '0');


  -- memory debug
  signal MEMDEBUGRDADDR : std_logic_vector(3 downto 0)  := (others => '0');
  signal MEMDEBUGWRADDR : std_logic_vector(3 downto 0)  := (others => '0');
  signal MEMDEBUGWE     : std_logic                     := '0';
  signal MEMDEBUGRD     : std_logic                     := '0';
  signal MEMDEBUGDIN    : std_logic_vector(15 downto 0) := (others => '0');
  signal MEMDEBUGDOUT   : std_logic_vector(15 downto 0) := (others => '0');

  signal mainclkrst : std_logic := '1';

  signal dcm2reset : std_logic := '1';
  
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
      CLK0   => clkint,                 -- 0 degree DCM CLK ouptput
      CLK2x  => clk2xint,
      CLKFX  => memclkbint,             -- DCM CLK synthesis out (M/D)
      CLKFB  => clk,
      CLK180 => clk180int,
      CLK270 => niciointclk,
      CLKIN  => CLKIN,
      LOCKED => locked,
      RST    => '0'                     -- DCM asynchronous reset input
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
      CLKOUT_PHASE_SHIFT    => "FIXED",
      PHASE_SHIFT           => 0,
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => false)
    port map (
      CLK0   => memclkint,
      CLK180 => memclk180int,
      CLK270 => memclk270int,
      CLK90  => memclk90int,
      CLKFB  => memclk,
      CLKIN  => memclkb,
      LOCKED => locked2,
      RST    => resetint(7)

      );

  dcm2reset <= not locked2;

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

  memclk_driver : entity memory.ddr2clkdriver
    port map (
      CLKOUT_P => RAMCLKOUT_P,
      CLKOUT_N => RAMCLKOUT_N,
      CLKIN    => memclk270,
      RESET    => reset
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

  datarbouter_a : entity soma.datarouter
    port map (
      CLK    => clk,
      ECYCLE => ecycle,
      DIN    => datadout,
      DINEN  => datadoen(7 downto 0),
      DOUT   => douta,
      DOEN   => doutena,
      DGRANT => dgrant(31 downto 0));

  timer_inst : entity soma.timer
    port map (
      CLK     => clk,
      ECYCLe  => ECYCLE,
      EARX    => EARX(0),
      EDRX    => EDRX(0),
      EDSELRX => EDSELRX,
      EATX    => EATX(0),
      EDTX    => EDTX);
  -- init syscontrol with the ram values so that we can properly sim
  syscontrol_inst : entity syscon.syscontrol
    generic map (
      RAM_INIT_00 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_00,
      RAM_INIT_01 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_01,
      RAM_INIT_02 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_02,
      RAM_INIT_03 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_03,
      RAM_INIT_04 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_04,
      RAM_INIT_05 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_05,
      RAM_INIT_06 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_06,
      RAM_INIT_07 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_07,
      RAM_INIT_08 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_08,
      RAM_INIT_09 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_09,
      RAM_INIT_0A => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0A,
      RAM_INIT_0B => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0B,
      RAM_INIT_0C => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0C,
      RAM_INIT_0D => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0D,
      RAM_INIT_0E => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0E,
      RAM_INIT_0F => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_0F,

      RAM_INIT_10 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_10,
      RAM_INIT_11 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_11,
      RAM_INIT_12 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_12,
      RAM_INIT_13 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_13,
      RAM_INIT_14 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_14,
      RAM_INIT_15 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_15,
      RAM_INIT_16 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_16,
      RAM_INIT_17 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_17,
      RAM_INIT_18 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_18,
      RAM_INIT_19 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_19,
      RAM_INIT_1A => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1A,
      RAM_INIT_1B => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1B,
      RAM_INIT_1C => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1C,
      RAM_INIT_1D => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1D,
      RAM_INIT_1E => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1E,
      RAM_INIT_1F => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_1F,

      RAM_INIT_20 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_20,
      RAM_INIT_21 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_21,
      RAM_INIT_22 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_22,
      RAM_INIT_23 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_23,
      RAM_INIT_24 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_24,
      RAM_INIT_25 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_25,
      RAM_INIT_26 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_26,
      RAM_INIT_27 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_27,
      RAM_INIT_28 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_28,
      RAM_INIT_29 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_29,
      RAM_INIT_2A => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2A,
      RAM_INIT_2B => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2B,
      RAM_INIT_2C => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2C,
      RAM_INIT_2D => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2D,
      RAM_INIT_2E => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2E,
      RAM_INIT_2F => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_2F,

      RAM_INIT_30 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_30,
      RAM_INIT_31 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_31,
      RAM_INIT_32 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_32,
      RAM_INIT_33 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_33,
      RAM_INIT_34 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_34,
      RAM_INIT_35 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_35,
      RAM_INIT_36 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_36,
      RAM_INIT_37 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_37,
      RAM_INIT_38 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_38,
      RAM_INIT_39 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_39,
      RAM_INIT_3A => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3A,
      RAM_INIT_3B => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3B,
      RAM_INIT_3C => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3C,
      RAM_INIT_3D => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3D,
      RAM_INIT_3E => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3E,
      RAM_INIT_3F => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INIT_3F,

      RAM_INITP_00 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_00,
      RAM_INITP_01 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_01,
      RAM_INITP_02 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_02,
      RAM_INITP_03 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_03,
      RAM_INITP_04 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_04,
      RAM_INITP_05 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_05,
      RAM_INITP_06 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_06,
      RAM_INITP_07 => work.backplane_mem_pkg.syscontrol_inst_instruction_ram_INITP_07)
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
      SEROUT  => lserialboot,
      DLINKUP => dlinkup);

  bootstore_inst : entity soma.bootstore
    generic map (
      DEVICE => X"02")
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
      CLK   => clk,
      SERIN => lserialboot(0),
      FPROG => NICFPROG,
      FCLK  => NICFCLK,
      FDIN  => NICFDIN);

  DSPCFG  <= lserialboot(19 downto 4);
  ADIOCFG <= lserialboot(3);
  SYSCFG  <= lserialboot(2);
  NEPCFG  <= lserialboot(1);

  LEDPOWER <= lserialboot(0);
  LEDEVENT <= jtagesenddebug(1);

  jtagsend_inst : entity jtag.jtagesend
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CLK     => clk,
      ECYCLE  => ecycle,
      EARX    => earx(7),
      EDRX    => edrx(7),
      EDSELRX => edselrx,
      DEBUG   => jtagesenddebug);

  jtagreceive_inst : entity jtag.jtagereceive
    generic map (
      JTAG_CHAIN_MASK => 2,
      JTAG_CHAIN_OUT  => 3)
    port map (
      CLK    => clk,
      ECYCLE => ecycle,
      EDTX   => edtx,
      EATX   => eatx(7),
      DEBUG  => jtagjtagrxdebug);

  DCM_fibertx_inst : DCM_BASE
    generic map (
      CLKFX_DIVIDE   => 5,
      CLKFX_MULTIPLY => 8,
      STARTUP_WAIT   => true)
    port map (
      CLKFX  => fibertxclkint,
      CLKIN  => clk,
      CLK0   => fibertxclkintdummy,
      CLKFB  => fibertxclkdummy,
      LOCKED => open,
      RST    => '0'                     -- DCM asynchronous reset input
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
      DEVICE => X"4C")
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


--  jtagdebugout: entity jtagsimpleout
--    generic map (
--      JTAG_CHAIN => 4,
--      JTAGN      => 32)
--    port map (
--      CLK => clk,
--      DIN => jtagdebug);

  --jtagdebug <= jtagnetdebug & jtagjtagrxdebug; 


-- dummy
  process(clk)
    variable blinkcnt : std_logic_vector(21 downto 0)
 := (others => '0');
  begin
    if rising_edge(clk) then
      blinkcnt := blinkcnt + 1;

    end if;
  end process;


  myip    <= X"0A000002";               -- 10.0.0.2
  mybcast <= X"FFFFFFFF";               -- 10.255.255.255

  mymac <= X"00ADBEEF1234";

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
      DIENB => doutenb,
      DINA  => douta,
      DINB  => doutb,

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
      RXIOCRCERR     => rxiocrcerr,
      UNKNOWNETHER   => unknownether,
      UNKNOWNIP      => unknownip,
      UNKNOWNUDP     => unknownudp,
      UNKNOWNARP     => unknownarp,
      TXPKTLENEN     => txpktlenen,
      TXPKTLEN       => txpktlen,
      TXCHAN         => txchan,
      EVTRXSUC       => evtrxsuc,
      EVTFIFOFULL    => evtfifofull,
      -- debug control for memory
      RAMDQALIGNH    => ramdqalignh,
      RAMDQALIGNL    => ramdqalignl,
      -- memory debug interface,
      MEMDEBUGCLK    => clk2x,
      MEMDEBUGRDADDR => memdebugrdaddr,
      MEMDEBUGWRADDR => memdebugwraddr,
      MEMDEBUGWE     => memdebugwe,
      MEMDEBUGRD     => memdebugrd,
      MEMDEBUGDOUT   => memdebugdin,
      MEMDEBUGDIN    => memdebugdout,

      DEBUG => netdebug

      );

  netcontrol_inst : entity soma.netcontrol
    generic map (
      DEVICE => X"04"
-- RAM_INIT_00 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_00,
-- RAM_INIT_01 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_01,
-- RAM_INIT_02 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_02,
-- RAM_INIT_03 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_03,
-- RAM_INIT_04 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_04,
-- RAM_INIT_05 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_05,
-- RAM_INIT_06 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_06,
-- RAM_INIT_07 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_07,
-- RAM_INIT_08 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_08,
-- RAM_INIT_09 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_09,
-- RAM_INIT_0A => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0A,
-- RAM_INIT_0B => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0B,
-- RAM_INIT_0C => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0C,
-- RAM_INIT_0D => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0D,
-- RAM_INIT_0E => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0E,
-- RAM_INIT_0F => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_0F,

-- RAM_INIT_10 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_10,
-- RAM_INIT_11 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_11,
-- RAM_INIT_12 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_12,
-- RAM_INIT_13 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_13,
-- RAM_INIT_14 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_14,
-- RAM_INIT_15 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_15,
-- RAM_INIT_16 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_16,
-- RAM_INIT_17 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_17,
-- RAM_INIT_18 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_18,
-- RAM_INIT_19 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_19,
-- RAM_INIT_1A => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1A,
-- RAM_INIT_1B => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1B,
-- RAM_INIT_1C => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1C,
-- RAM_INIT_1D => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1D,
-- RAM_INIT_1E => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1E,
-- RAM_INIT_1F => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_1F,

-- RAM_INIT_20 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_20,
-- RAM_INIT_21 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_21,
-- RAM_INIT_22 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_22,
-- RAM_INIT_23 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_23,
-- RAM_INIT_24 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_24,
-- RAM_INIT_25 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_25,
-- RAM_INIT_26 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_26,
-- RAM_INIT_27 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_27,
-- RAM_INIT_28 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_28,
-- RAM_INIT_29 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_29,
-- RAM_INIT_2A => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2A,
-- RAM_INIT_2B => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2B,
-- RAM_INIT_2C => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2C,
-- RAM_INIT_2D => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2D,
-- RAM_INIT_2E => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2E,
-- RAM_INIT_2F => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_2F,

-- RAM_INIT_30 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_30,
-- RAM_INIT_31 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_31,
-- RAM_INIT_32 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_32,
-- RAM_INIT_33 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_33,
-- RAM_INIT_34 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_34,
-- RAM_INIT_35 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_35,
-- RAM_INIT_36 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_36,
-- RAM_INIT_37 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_37,
-- RAM_INIT_38 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_38,
-- RAM_INIT_39 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_39,
-- RAM_INIT_3A => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3A,
-- RAM_INIT_3B => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3B,
-- RAM_INIT_3C => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3C,
-- RAM_INIT_3D => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3D,
-- RAM_INIT_3E => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3E,
-- RAM_INIT_3F => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INIT_3F,

-- RAM_INITP_00 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_00,
-- RAM_INITP_01 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_01,
-- RAM_INITP_02 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_02,
-- RAM_INITP_03 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_03,
-- RAM_INITP_04 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_04,
-- RAM_INITP_05 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_05,
-- RAM_INITP_06 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_06,
-- RAM_INITP_07 => work.backplane_mem_pkg.netcontrol_inst_instruction_ram_INITP_07)
      )
    port map (
      CLK            => CLK,
      CLK2X          => CLK2X,
      RESET          => RESET,
      -- standard event-bus interface
      ECYCLE         => ECYCLE,
      EDTX           => EDTX,
      EATX           => EATX(4),
      EARX           => EARX(4),
      EDRX           => EDRX(4),
      EDSELRX        => EDSELRX,
      -- tx counter input
      TXPKTLENEN     => txpktlenen,
      TXPKTLEN       => txpktlen,
      TXCHAN         => txchan,
      -- other counters
      RXIOCRCERR     => rxiocrcerr,
      UNKNOWNETHER   => unknownether,
      UNKNOWNIP      => unknownip,
      UNKNOWNARP     => unknownarp,
      UNKNOWNUDP     => unknownudp,
      EVTRXSUC       => evtrxsuc,
      EVTFIFOFULL    => evtfifofull,
      -- debug for memory
      MEMDEBUGRDADDR => memdebugrdaddr,
      MEMDEBUGWRADDR => memdebugwraddr,
      MEMDEBUGWE     => memdebugwe,
      MEMDEBUGRD     => memdebugrd,
      MEMDEBUGDIN    => memdebugdin,
      MEMDEBUGDOUT   => memdebugdout,

      RAMDQALIGNH => ramdqalignh,
      RAMDQALIGNL => ramdqalignl,
      -- output network control settings
      --MYMAC        => mymac,
      --MYBCAST      => mybcast,
      --MYIP         => myip,
      -- NIC interface
      NICSOUT     => NICSOUT,
      NICSIN      => NICSIN,
      NICSCLK     => NICSCLK,
      NICSCS      => NICSCS
      );


  ODDR_INST : oddr
    port map (
      Q  => NICIOCLK,
      C  => clk,
      CE => '1',
      D1 => '0',
      D2 => '1',
      R  => '0',
      S  => '0'); 

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

  RESET <= not maindcmlocked;
  
  devicelinkclk_inst : entity work.devicelinkclk
    port map (
      CLKIN       => clk,
      RESET =>  dcm2reset, 
      CLKBITTX    => clkbittx,
      CLKBITTX180 => clkbittx180,
      CLKBITRX    => clkbitrx,
      CLKWORDTX   => clkwordtx,
      STARTUPDONE => maindcmlocked);

  ----------------------------------------------------------------------------
  -- DSP DeviceLinks
  ----------------------------------------------------------------------------

  devicelinks_and_mux : for i in 0 to 7 generate
    signal txdin, rxdout : std_logic_vector(7 downto 0) := (others => '0');
    signal txkin, rxkout : std_logic                    := '0';
    signal dllocked      : std_logic                    := '0';

  begin
    dl : entity work.coredevicelink
      generic map (
        N => 4)
      port map (
        CLK       => clk,
        RXBITCLK  => clkbitrx,
        TXHBITCLK => clkbittx,
        TXWORDCLK => clkwordtx,
        RESET     => RESET,
        TXDIN     => txdin,
        TXKIN     => txkin,
        RXDOUT    => rxdout,
        RXKOUT    => rxkout,
        TXIO_P    => DSPTXIO_P(i),
        TXIO_N    => DSPTXIO_N(i),
        RXIO_P    => DSPRXIO_P(i),
        RXIO_N    => DSPRXIO_N(i),
        DROPLOCK  => '0',
        LOCKED    => dllocked);
    dlinkup(i) <= dllocked;


    devicemux_inst : entity work.devicemux
      port map (
        CLK      => CLK,
        ECYCLE   => ecycle,
        -- data output
        DATADOUT => datadout(i),
        DATADOEN => datadoen(i),
        -- port A
        DGRANTA  => dgrant(i*4 + 0),
        EARXA    => earx(DMOFFSET + i*4 + 0),
        EDRXA    => edrx(DMOFFSET + i*4 + 0),
        EDSELRXA => edselrx,
        EATXA    => eatx(DMOFFSET + i*4 + 0),
        EDTXA    => edtx,
        -- port B
        DGRANTB  => dgrant(i*4 + 1),
        EARXB    => earx(DMOFFSET + i*4 + 1),
        EDRXB    => edrx(DMOFFSET + i*4 + 1),
        EDSELRXB => edselrx,
        EATXB    => eatx(DMOFFSET + i*4 + 1),
        EDTXB    => edtx,
        -- port C
        DGRANTC  => dgrant(i*4 + 2),
        EARXC    => earx(DMOFFSET + i*4 + 2),
        EDRXC    => edrx(DMOFFSET + i*4 + 2),
        EDSELRXC => edselrx,
        EATXC    => eatx(DMOFFSET + i*4 + 2),
        EDTXC    => edtx,
        -- port D
        DGRANTD  => dgrant(i*4 + 3),
        EARXD    => earx(DMOFFSET + i*4 + 3),
        EDRXD    => edrx(DMOFFSET + i*4 + 3),
        EDSELRXD => edselrx,
        EATXD    => eatx(DMOFFSET + i*4 + 3),
        EDTXD    => edtx,
        -- IO
        TXDOUT   => txdin,
        TXKOUT   => txkin,
        RXDIN    => rxdout,
        RXKIN    => rxkout,
        LOCKED   => dllocked);

  end generate devicelinks_and_mux;

  ----------------------------------------------------------------------------
  -- ADIO DeviceLink
  ----------------------------------------------------------------------------
  dl_adio : entity work.coredevicelink
    generic map (
      N => 4)
    port map (
      CLK       => clk,
      RXBITCLK  => clkbitrx,
      TXHBITCLK => clkbittx,
      TXWORDCLK => clkwordtx,
      RESET     => RESET,
      TXDIN     => txdinadio,
      TXKIN     => txkinadio,
      RXDOUT    => rxdoutadio,
      RXKOUT    => rxkoutadio,
      TXIO_P    => ADIOTXIO_P,
      TXIO_N    => ADIOTXIO_N,
      RXIO_P    => ADIORXIO_P,
      RXIO_N    => ADIORXIO_N,
      DROPLOCK  => '0',
      LOCKED    => dllockedadio);

  dlinkup(16) <= dllockedadio;

  devicemux_adio_inst : entity work.devicemux
    port map (
      CLK      => CLK,
      ECYCLE   => ecycle,
      -- port A
      DGRANTA  => '0',
      EARXA    => earx(73),
      EDRXA    => edrx(73),
      EDSELRXA => edselrx,
      EATXA    => eatx(73),
      EDTXA    => edtx,
      -- port B
      DGRANTB  => '0',
      EARXB    => earx(74),
      EDRXB    => edrx(74),
      EDSELRXB => edselrx,
      EATXB    => eatx(74),
      EDTXB    => edtx,
      -- port C
      DGRANTC  => '0',
      EARXC    => earx(75),
      EDRXC    => edrx(75),
      EDSELRXC => edselrx,
      EATXC    => eatx(75),
      EDTXC    => edtx,
      -- port D
      DGRANTD  => '0',
      EARXD    => open,
      EDRXD    => open,
      EDSELRXD => edselrx,
      EATXD    => (others => '0'),
      EDTXD    => X"00",
      -- IO
      TXDOUT   => txdinadio,
      TXKOUT   => txkinadio,
      RXDIN    => rxdoutadio,
      RXKIN    => rxkoutadio,
      LOCKED   => dllockedadio);

  ----------------------------------------------------------------------------
  -- SYS (Display) DeviceLink
  ----------------------------------------------------------------------------
  dl_sys : entity work.coredevicelink
    generic map (
      N => 1)
    port map (
      CLK       => clk,
      RXBITCLK  => clkbitrx,
      TXHBITCLK => clkbittx,
      TXWORDCLK => clkwordtx,
      RESET     => RESET,
      TXDIN     => txdinsys,
      TXKIN     => txkinsys,
      RXDOUT    => rxdoutsys,
      RXKOUT    => rxkoutsys,
      TXIO_P    => SYSTXIO_P,
      TXIO_N    => SYSTXIO_N,
      RXIO_P    => SYSRXIO_P,
      RXIO_N    => SYSRXIO_N,
      DROPLOCK  => '0',
      LOCKED    => dllockedsys);

  devicemux_sys_inst : entity work.devicemux
    port map (
      CLK      => CLK,
      ECYCLE   => ecycle,
      -- port A
      DGRANTA  => '0',
      EARXA    => earx(6),
      EDRXA    => edrx(6),
      EDSELRXA => edselrx,
      EATXA    => eatx(6),
      EDTXA    => edtx,
      -- port B
      DGRANTB  => '0',
      EARXB    => open,
      EDRXB    => open,
      EDSELRXB => edselrx,
      EATXB    => (others => '0'),
      EDTXB    => X"00",
      -- port C
      DGRANTC  => '0',
      EARXC    => open,
      EDRXC    => open,
      EDSELRXC => edselrx,
      EATXC    => (others => '0'),
      EDTXC    => X"00",
      -- port D
      DGRANTD  => '0',
      EARXD    => open,
      EDRXD    => open,
      EDSELRXD => edselrx,
      EATXD    => (others => '0'),
      EDTXD    => X"00",
      -- IO
      TXDOUT   => txdinsys,
      TXKOUT   => txkinsys,
      RXDIN    => rxdoutsys,
      RXKIN    => rxkoutsys,
      LOCKED   => dllockedsys);

  dlinkup(17) <= dllockedsys;

  dincapture_data <= netdebug(31 downto 16);
  dincapture_inst : entity dincapture
    port map (
      CLK   => clk,
      DINEN => netdebug(0),
      DIN   => dincapture_data); 

end Behavioral;
