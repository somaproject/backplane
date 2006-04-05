-------------------------------------------------------------------------------
-- Title      : LVDStest
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lvdstest.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/04/04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Simple test of point-to-point LVDS links.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/03/20  1.0      jonas   Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;



entity lvdstest is

  port (
    TXIO_P      : out std_logic;
    TXIO_N      : out std_logic;
    RXIO_P      : in  std_logic;
    RXIO_N      : in  std_logic;
    CLKIN       : in  std_logic;
    RESET       : in  std_logic;
    LEDPOWER    : out std_logic;
    LEDVALID    : out std_logic;
    CLKBITTXOUT : out std_logic;
    CLKRXOUT    : out std_logic;
    VALIDOUT : out std_logic
--    DCMLOCKED1 : out std_logic;
--    DCMLOCKED2 : out std_logic
    );

end lvdstest;


architecture Behavioral of lvdstest is


  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0));
  end component;


  component decode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      code_err : out std_logic;
      disp_err : out std_logic);
  end component;

  component serialize
    port (
      CLKA   : in  std_logic;
      CLKB   : in  std_logic;
      RESET  : in  std_logic;
      BITCLK : in  std_logic;
      DIN    : in  std_logic_vector(9 downto 0);
      DOUT   : out std_logic;
      STOPTX : in  std_logic
      );
  end component;


  component deserialize

    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      BITCLK  : in  std_logic;
      DIN     : in  std_logic;
      DOUT    : out std_logic_vector(9 downto 0);
      DLYRST  : in  std_logic;
      DLYCE   : in  std_logic;
      DLYINC  : in  std_logic;
      BITSLIP : in  std_logic);

  end component;

  signal txio, rxio : std_logic := '0';

  signal clk, clkint : std_logic := '0';

  signal clksrc, clksrcint   : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';

  signal clkbittxint, clkbittx : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkrxint, clkrx       : std_logic := '0';


  signal dc, dcint : std_logic                     := '0';
  signal ledtick   : std_logic_vector(23 downto 0) := (others => '0');
  signal validint  : std_logic_vector(4 downto 0)  := (others => '0');

  signal base_lock      : std_logic                    := '0';
  signal base_rst       : std_logic                    := '0';
  signal base_rst_delay : std_logic_vector(9 downto 0) := (others => '1');

  signal maindcmlocked : std_logic := '0';
  signal dcmreset      : std_logic := '1';

  signal txdin     : std_logic_vector(7 downto 0) := (others => '0');
  signal txkin     : std_logic                    := '0';
  signal txdoutenc : std_logic_vector(9 downto 0) := (others => '0');

  signal cerr, derr : std_logic                    := '0';
  signal rxdoutenc  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxdout     : std_logic_vector(7 downto 0) := (others => '0');
  signal rxkout     : std_logic                    := '0';

  signal bstick : std_logic_vector(24 downto 0) := (others => '0'); 
  signal bitslip : std_logic := '0';
  
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

      CLK2X  => clkbittxint,
      CLKFX  => clkbitrxint,
      CLKDV  => clkrxint,
      RST    => base_rst_delay(7),
      LOCKED => maindcmlocked
      );

  dcmreset <= not maindcmlocked;

--   DCMLOCKED1 <= base_lock;
--   DCMLOCKED2 <= maindcmlocked;
  
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

-------------------------------------------------------------------------------
-- TX framework
-----------------------------------------------------------------------------


  process(clkrx)
  begin
    if rising_edge(clkrx) then
--       if txdin = X"00" then
--         txdin <= X"01";
--       else
--         txdin <= X"00";
--       end if;
      txdin <= txdin + 1; 
    end if;
  end process;

  txkin <= '0';


  encoder : encode8b10b
    port map (
      DIN  => txdin,
      KIN  => txkin,
      DOUT => txdoutenc,
      CLK  => clkrx);

  serialize_inst : serialize
    port map (
      CLKA   => clkrx,
      CLKB   => clk,
      RESET  => dcmreset,
      BITCLK => clkbittx,
      DIN    => txdoutenc,
      DOUT   => txio,
      STOPTX => '0' );

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => TXIO_P,
      OB         => TXIO_N,
      I          => txio
      );

-------------------------------------------------------------------------------
-- RX Framework
-------------------------------------------------------------------------------

  RXIO_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      DIFF_TERM  => true)
    port map (
      I          => RXIO_P,
      IB         => RXIO_N,
      O          => rxio
      );

  deser_inst : deserialize
    port map (
      CLK     => clkrx,
      RESET   => dcmreset,
      BITCLK  => clkbitrx,
      DIN     => rxio,
      DOUt    => rxdoutenc,
      DLYRST  => dcmreset,
      DLYCE   => '0',
      DLYINC  => '0',
      BITSLIP => BITSLIP);

  decoder : decode8b10b
    port map (
      CLK      => clkrx,
      DIN      => rxdoutenc,
      DOUT     => rxdout,
      KOUT     => rxkout,
      CODE_ERR => cerr,
      DISP_ERR => derr);

  rxvalidate : process (clkrx)
  begin  -- process rxvalidate
    if rising_edge(clkrx) then
      if cerr = '0' and derr = '0' then
        LEDVALID <= '1';
        VALIDOUT <= '1'; 
      else
        LEDVALID <= '0';
        VALIDOUT <= '0';
        
      end if;


    end if;
  end process rxvalidate;

-----------------------------------------------------------------------------
-- misc
---------------------------------------------------------------------------

  blinkenled : process (clkrx)
  begin  -- process rxvalidate
    if rising_edge(clkrx) then
      ledtick <= ledtick + 1;

--       if bstick(24 downto 20) = "00000" then
--         LEDPOWER <= '1';
--       else
--         LEDPOWER <= '0';  
--       end if;
      LEDPOWER <= '1'; 

      bstick <= bstick + 1;
      if bstick = "0000000000000000000000000" then
        BITSLIP <= '1';
      else
        BITSLIP <= '0';
      end if; 

    end if;
  end process blinkenled;

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clkrx,
      RST    => dcmreset
      );

  CLKBITTXOUT <= clkbittx;
  CLKRXOUT    <= clkrx;

end Behavioral;
