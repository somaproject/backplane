
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity devicelinkclk is
  port (
    CLKIN       : in  std_logic;        -- 50 MHz input clock
    RESET : in std_logic; 
    CLKBITTX    : out std_logic;        -- 300 MHz output clock
    CLKBITTX180 : out std_logic;        -- 300 MHz output clock, 180 phase
    CLKBITRX    : out std_logic;        -- 250 MHz output clock 
    CLKWORDTX   : out std_logic;        -- 60 MHz output clock
    STARTUPDONE : out std_logic);
end devicelinkclk;


architecture Behavioral of devicelinkclk is
  -- DEVICELINKCLK : takes care of generating all deviceLink-related
  -- clocks. expects a globally-buffered clock as input; outputs are all
  -- globally buffered

  signal base_lock : std_logic := '0';


  signal clk, clkint : std_logic := '0';
  signal clksrc, clksrcint : std_logic := '0';

  signal clkbittxint, clkbittx180int : std_logic := '0';
  signal clkbitrxint  : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';
  signal clknone2, clknone2int : std_logic := '0';
  
  signal base_rst_delay : std_logic_vector(9 downto 0) := (others => '0');

  signal dcmreset, maindcmlocked : std_logic := '0';

  signal clkwordtxout, clkwordtxint : std_logic := '0';
  signal clkwordtxdc, clkwordtxdcint : std_logic := '0';

  signal clkdelayctrl : std_logic := '0';
  signal clkdelayctrlint : std_logic := '0';
  signal txworddc_lock : std_logic := '0';

  signal delayready : std_logic := '0';

  signal startupdoneint : std_logic := '0';
  signal delayctrlrst : std_logic := '1';
  
begin  -- Behavioral

  -- Turn the 50 MHz clock into a 150 MHz Clock
  txsrc : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 2,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 6,       -- Can be any integer from 2 to 32
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


  process(clk)
  begin
    if rising_edge(clk) then
      base_rst_delay <= base_rst_delay(8 downto 0) & (not base_lock);
    end if;
  end process;

  maindcm : DCM_BASE
    generic map (
      CLKDV_DIVIDE          => 2.5,
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
      CLKDV    => clkwordtxdcint,
      RST      => base_rst_delay(7),
      LOCKED   => maindcmlocked
      );

    clkbittx_bufg : BUFG
    port map (
      O => CLKBITTX,
      I => clkbittxint);

  clkbittx180_bufg : BUFG
    port map (
      O => CLKBITTX180,
      I => clkbittx180int);



  dcmreset <= not maindcmlocked;

  
  clknonebufg : BUFG
    port map (
      O => clknone,
      I => clknoneint);


  clkbitrxbufg : BUFG
    port map (
      O => CLKBITRX,
      I => clkbitrxint);

  clkwordtxdcbufg : BUFG
    port map (
      O => clkwordtxdc,
      I => clkwordtxdcint);

--  delayctrl_clock_dcm : DCM_BASE
--    generic map (
--      CLKFX_MULTIPLY        => 4,
--      CLKFX_DIVIDE          => 3,
--      CLKIN_PERIOD          => 2.5,
--      CLKOUT_PHASE_SHIFT    => "NONE",
--      CLK_FEEDBACK          => "1X",
--      DCM_AUTOCALIBRATION   => true,
--      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
--      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
--      DFS_FREQUENCY_MODE    => "LOW",
--      DLL_FREQUENCY_MODE    => "LOW",
--      DUTY_CYCLE_CORRECTION => true,
--      FACTORY_JF            => X"F0F0",
--      PHASE_SHIFT           => 0,
--      STARTUP_WAIT          => false)
--    port map(
--      CLKIN                 => clk,     -- input 150 MHz
--      clk0                  => clknone2int,
--      CLKFB                 => clknone2,
--      --CLK2X    => clkbittxint,
--      --CLK2X180 => clkbittx180int,
--      CLKFX    => clkdelayctrl,
--      --CLKDV    => clkwordtxdcint,
--      RST      => base_rst_delay(7)
----      LOCKED   => maindcmlocke
--      );

  delayctrl_clk_bufg : BUFG
    port map (
      O => clkdelayctrl,
      I => clkdelayctrlint);

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => delayready,
      REFCLK => clkdelayctrl,
      RST    => delayctrlrst 
      );

  
  -- Duty cycle correction

  
  txword_dcm : DCM_BASE
    generic map (
      CLKIN_PERIOD          => 2.5,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      CLKFX_MULTIPLY => 10,
      CLKFX_DIVIDE => 3,
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
      CLKIN                 => clkwordtxdc,
      clk0                  => clkwordtxint,
      CLKFB                 => clkwordtxout,
      CLKFX => clkdelayctrlint, 
      RST => dcmreset,
      LOCKED => txworddc_lock 
      );

  clkwordtxbufg : BUFG
    port map (
      O => clkwordtxout,
      I => clkwordtxint);

  CLKWORDTX <= clkwordtxout;
  
  startupdoneint <= txworddc_lock and delayready;
  delayctrlrst <= not txworddc_lock; 
  STARTUPDONE <= startupdoneint; 
end Behavioral;

