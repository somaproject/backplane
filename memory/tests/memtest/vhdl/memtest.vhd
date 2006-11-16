library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memtest is
  port (
    CLKIN    : in    std_logic;
    CLKOUT_P : out   std_logic;
    CLKOUT_N : out   std_logic;
    CKE      : out   std_logic;
    CAS      : out   std_logic;
    RAS      : out   std_logic;
    CS       : out   std_logic;
    WE       : out   std_logic;
    ADDR     : out   std_logic_vector(12 downto 0);
    BA       : out   std_logic_vector(1 downto 0);
    DQSH     : inout std_logic;
    DQSL     : inout std_logic;
    DQ       : inout std_logic_vector(15 downto 0);
    LEDERROR : out   std_logic;
    LEDRESET : out   std_logic
    );
end memtest;

architecture Behavioral of memtest is

  component memddr2
    generic (
      CASLATENCY : in integer
      ); 
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET  : in    std_logic;
      -- RAM!
      CKE    : out   std_logic;
      CAS    : out   std_logic;
      RAS    : out   std_logic;
      CS     : out   std_logic;
      WE     : out   std_logic;
      ADDR   : out   std_logic_vector(12 downto 0);
      BA     : out   std_logic_vector(1 downto 0);
      DQSH   : inout std_logic;
      DQSL   : inout std_logic;
      DQ     : inout std_logic_vector(15 downto 0);
      -- interface
      START  : in    std_logic;
      RW     : in    std_logic;
      DONE   : out   std_logic;
      ROWTGT : in    std_logic_vector(14 downto 0);
      -- write interface
      WRADDR : out   std_logic_vector(7 downto 0);
      WRDATA : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out   std_logic_vector(7 downto 0);
      RDDATA : out   std_logic_vector(31 downto 0);
      RDWE   : out   std_logic;
      -- DEBUG interface
      DEBUG : out std_logic_vector(3 downto 0)
      );
  end component;

  signal clkb, clkbint         : std_logic := '0';
  signal clkbfast, clkbfastint : std_logic := '0';

  signal CLK, clkint       : std_logic := '0';
  signal CLK90, clk90int   : std_logic := '0';
  signal CLK180, clk180int : std_logic := '0';
  signal CLK270, clk270int : std_logic := '0';
  signal RESET             : std_logic := '1';


  -- interface
  signal START  : std_logic                     := '0';
  signal RW     : std_logic                     := '0';
  signal DONE   : std_logic                     := '0';
  -- write interface
  signal ROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal WRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal WRDATA : std_logic_vector(31 downto 0) := (others => '0');
  -- read interface
  signal RDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal RDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal RDWE   : std_logic                     := '0';

  signal wraddrl : std_logic_vector(7 downto 0) := (others => '0');

  signal clkout : std_logic := '0';

  type states is (none, writestart, writedone, readstart, readdone);
  signal ocs, ons : states := none;

  signal locked, locked2 : std_logic := '0';


  signal memdebug : std_logic_vector(3 downto 0);
  
  component jtagmemif
    port (
      CLK      : in  std_logic;
      MEMSTART : out std_logic;
      MEMRW    : out std_logic;
      MEMDONE  : in  std_logic;
      ROWTGT   : out std_logic_vector(14 downto 0);
      WRADDR   : in  std_logic_vector(7 downto 0);
      WRDATA   : out std_logic_vector(31 downto 0);
      RDADDR   : in  std_logic_vector(7 downto 0);
      RDDATA   : in  std_logic_vector(31 downto 0);
      RDWE     : in  std_logic );
  end component;

  component jtagmemtest
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET  : in    std_logic;
      -- RAM!
      CKE    : out   std_logic;
      CAS    : out   std_logic;
      RAS    : out   std_logic;
      CS     : out   std_logic;
      WE     : out   std_logic;
      ADDR   : out   std_logic_vector(12 downto 0);
      BA     : out   std_logic_vector(1 downto 0);
      DQSH   : inout std_logic;
      DQSL   : inout std_logic;
      DQ     : inout std_logic_vector(15 downto 0);
      -- interface
      START  : in    std_logic;
      RW     : in    std_logic;
      DONE   : out   std_logic;
      ROWTGT : in    std_logic_vector(14 downto 0);
      -- write interface
      WRADDR : out   std_logic_vector(7 downto 0);
      WRDATA : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out   std_logic_vector(7 downto 0);
      RDDATA : out   std_logic_vector(31 downto 0);
      RDWE   : out   std_logic );
  end component;

begin

  jtagmemif_inst : jtagmemif
    port map (
      CLK      => CLK,
      MEMSTART => START,
      MEMRW    => RW,
      MEMDONE  => DONE,
      ROWTGT   => ROWTGT,
      WRADDR   => wraddr,
      WRDATA   => wrdata,
      RDADDR   => rdaddr,
      RDDATA   => rddata,
      RDWE     => rdwe);


  memddr2_inst : memddr2
    generic map (
      CASLATENCY => 5)
    port map (
      CLK    => clk,
      CLK90  => clk90,
      CLK180 => clk180,
      CLK270 => clk270,
      RESET  => reset,
      CKE    => CKE,
      CAS    => CAS,
      RAS    => RAS,
      CS     => CS,
      WE     => WE,
      ADDR   => ADDR,
      BA     => BA,
      DQSH   => DQSH,
      DQSL   => DQSL,
      DQ     => DQ,
      START  => START,
      RW     => RW,
      DONE   => DONE,
      ROWTGT => ROWTGT,
      WRADDR => WRADDR,
      WRDATA => WRDATA,
      RDADDR => RDADDR,
      RDDATA => RDDATA,
      RDWE   => RDWE,
      DEBUG => memdebug);

  DCM_BASE_inst : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKFX_DIVIDE          => 1,
      CLKFX_MULTIPLY        => 3,
      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 10.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => true)
    port map (
      CLK0                  => clkbint,      -- 0 degree DCM CLK ouptput
      CLKFX                 => clkbfastint,  -- DCM CLK synthesis out (M/D)
      CLKFB                 => clkb,
      CLKIN                 => CLKIN,
      LOCKED                => locked,
      RST                   => '0'           -- DCM asynchronous reset input
      );

  clkb_bufg : BUFG
    port map (
      O => clkb,
      I => clkbint);

  clkbfast_bufg : BUFG
    port map (
      O => clkbfast,
      I => clkbfastint);


  DCM_BASE_inst2 : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 10.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => true)
    port map (
      CLK0                  => clkint,
      CLK180                => clk180int,
      CLK270                => clk270int,
      CLK90                 => clk90int,
      CLKFB                 => clk,
      CLKIN                 => clkbfast,
      LOCKED                => locked2,
      RST                   => '0'

      );

  RESET <= not locked2;
  
  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clk90_bufg : BUFG
    port map (
      O => clk90,
      I => clk90int);

  clk180_bufg : BUFG
    port map (
      O => clk180,
      I => clk180int);

  clk270_bufg : BUFG
    port map (
      O => clk270,
      I => clk270int);

  CLKOUT <= clk;

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => CLKOUT_P,
      OB         => CLKOUT_N,
      I          => clkout
      );

  LEDRESET <= memdebug(0); 
  LEDERROR <= memdebug(1); 

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clk,
      RST    => reset
      );

end behavioral;
