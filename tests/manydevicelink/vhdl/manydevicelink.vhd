
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity manydevicelink is

  port (
    CLKIN    : in  std_logic;
    RESET    : in  std_logic;
    TXIO_P   : out std_logic_vector(4 downto 0);
    TXIO_N   : out std_logic_vector(4 downto 0);
    RXIO_P   : in  std_logic_vector(4 downto 0);
    RXIO_N   : in  std_logic_vector(4 downto 0);
    VALID    : out std_logic_vector(4 downto 0);
    LEDPOWER : out std_logic;
    LEDVALID : out std_logic;
    WORDCLKOUT : out std_logic;
    TXCLKOUT : out std_logic; 
    DEBUG : out std_logic_vector(23 downto 0)
    );

end manydevicelink;

architecture Behavioral of manydevicelink is

  component linktester

    port (
      CLK          : in  std_logic;
      RXBITCLK     : in  std_logic;
      TXHBITCLK    : in  std_logic;
      TXWORDCLK : in  std_logic;
      RESET        : in  std_logic;
      TXIO_P       : out std_logic;
      TXIO_N       : out std_logic;
      RXIO_P       : in  std_logic;
      RXIO_N       : in  std_logic;
      VALID        : out std_logic;
      DEBUG : out std_logic_vector(23 downto 0)
      );

  end component;

    signal clk, clkint : std_logic := '0';

  signal clksrc, clksrcint   : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';

  signal clkbittxint, clkbittx       : std_logic := '0';
  signal clkbittx180int, clkbittx180 : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkrxint, clkrx       : std_logic := '0';


  signal dc, dcint               : std_logic                     := '0';
  signal ledtick                 : std_logic_vector(23 downto 0) := (others => '0');
  signal validint                : std_logic_vector(4 downto 0) := (others => '0');

    signal base_lock : std_logic := '0';
  signal base_rst : std_logic := '0';
  signal base_rst_delay : std_logic_vector(9 downto 0)  := (others => '1'); 

  signal maindcmlocked : std_logic := '0';
  signal dcmreset : std_logic := '1';
 
  
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

  dl0 : linktester
      port map (
        CLK          =>  clkrx,
        RXBITCLK     => clkbitrx,
        TXHBITCLK    => clkbittx,
        TXWORDCLK => clk,
        RESET        => dcmreset,
        TXIO_P       => TXIO_P(0),
        TXIO_N       => TXIO_N(0),
        RXIO_P       => RXIO_P(0),
        RXIO_N       => RXIO_N(0),
        VALID        => validint(0),
        DEBUG => DEBUG);
    
  devicelinks : for i in 1 to 4 generate
    dl        : linktester
      port map (
        CLK          =>  clkrx,
        RXBITCLK     => clkbitrx,
        TXHBITCLK    =>clkbittx,
        TXWORDCLK => clk,
        RESET        => RESET,
        TXIO_P       => TXIO_P(i),
        TXIO_N       => TXIO_N(i),
        RXIO_P       => RXIO_P(i),
        RXIO_N       => RXIO_N(i),
        VALID        => validint(i),
        DEBUG => open);

  end generate devicelinks;


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

  VALID    <= validint;
  LEDVALID <= validint(0);

  WORDCLKOUT <= clkrx;
  TXCLKOUT <= clkbittx; 
               
  
end Behavioral;
