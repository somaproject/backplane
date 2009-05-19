library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity coredevicelinktest is
end coredevicelinktest;

architecture Behavioral of coredevicelinktest is

  component coredevicelink
    generic (
      N       : integer := 0;
      DCNTMAX : integer);               -- number of ticks in input bit cycle
    port (
      CLK       : in  std_logic;        -- should be a 50 MHz clock 
      RXBITCLK  : in  std_logic;        -- should be a 250 MHz clock
      TXHBITCLK : in  std_logic;        -- should be a 300 MHz clock
      TXWORDCLK : in  std_logic;        -- should be a 60 MHz clock
      RESET     : in  std_logic;
      AUTOLINK : in std_logic := '1';
      ATTEMPTLINK : in std_logic := '0'; 
      TXDIN     : in  std_logic_vector(7 downto 0);
      TXKIN     : in  std_logic;
      TXIO_P    : out std_logic;
      TXIO_N    : out std_logic;
      RXIO_P    : in  std_logic;
      RXIO_N    : in  std_logic;
      RXDOUT    : out std_logic_vector(7 downto 0);
      RXKOUT    : out std_logic;
      DROPLOCK  : in  std_logic;
      LOCKED    : out std_logic;
      DEBUG : out std_logic_vector(15 downto 0);
      DEBUGADDR : in std_logic_vector(7 downto 0)
      );
  end component;


  component devicelink
    port (
      TXCLKIN    : in  std_logic;
      TXLOCKED   : in  std_logic;
      TXDIN      : in  std_logic_vector(9 downto 0);
      TXDOUT     : out std_logic_vector(7 downto 0);
      TXKOUT     : out std_logic;
      CLK        : out std_logic;
      CLK2X      : out std_logic;
      RESET      : out std_logic;
      RXDIN      : in  std_logic_vector(7 downto 0);
      RXKIN      : in  std_logic;
      RXIO_P     : out std_logic;
      RXIO_N     : out std_logic;
      DEBUGSTATE : out std_logic_vector(3 downto 0);
      DECODEERR  : out std_logic
      );
  end component;

  signal masterclk   : integer := 0;    -- master clock counter, at 600 Mhz
  signal clk_250_cnt : integer := 0;

  signal CLK       : std_logic                    := '0';  -- should be a 50 MHz clock 
  signal RXBITCLK  : std_logic                    := '0';  -- should be a 250 MHz clock
  signal TXHBITCLK : std_logic                    := '0';  -- should be a 300 MHz clock
  signal TXWORDCLK : std_logic                    := '0';  -- should be a 60 MHz clock
  signal RESET     : std_logic                    := '1';
  signal TXDIN     : std_logic_vector(7 downto 0) := (others => '0');
  signal TXKIN     : std_logic                    := '0';
  signal RXDOUT    : std_logic_vector(7 downto 0) := (others => '0');

  signal RXKOUT   : std_logic := '0';
  signal DROPLOCK : std_logic := '0';
  signal LOCKED   : std_logic := '0';

  signal DEBUG : std_logic_vector(15 downto 0) := (others => '0');
  signal DEBUGADDR : std_logic_vector(7 downto 0) := (others => '0');
  
  signal CORE_TO_DEVICE_P : std_logic := '0';
  signal CORE_TO_DEVICE_N : std_logic := '1';

  signal DEVICE_TO_CORE_P : std_logic := '0';
  signal DEVICE_TO_CORE_N : std_logic := '0';

  signal DEVICE_TO_CORE_DELAYED_P : std_logic := '0';
  signal DEVICE_TO_CORE_DELAYED_N : std_logic := '0';


  signal DL_TXCLKIN    : std_logic                    := '0';
  signal DL_TXLOCKED   : std_logic                    := '0';
  signal DL_TXDIN      : std_logic_vector(9 downto 0) := (others => '0');
  signal DL_TXDOUT     : std_logic_vector(7 downto 0) := (others => '0');
  signal DL_TXKOUT     : std_logic                    := '0';
  signal DL_CLK        : std_logic                    := '0';
  signal DL_CLK2X      : std_logic                    := '0';
  signal DL_RESET      : std_logic                    := '0';
  signal DL_RXDIN      : std_logic_vector(7 downto 0) := (others => '0');
  signal DL_RXKIN      : std_logic                    := '0';
  signal DL_DEBUGSTATE : std_logic_vector(3 downto 0) := (others => '0');
  signal DL_DECODEERR  : std_logic                    := '0';


  component serdes
    -- Simple deserializer for unit testing
    --
    port (
      CLK    : in  std_logic;           -- true 50 Mhz clock
      BITCLK : in  std_logic;           -- 300 Mhz bit clock
      DIN    : in  std_logic;
      DOUT   : out std_logic_vector(9 downto 0);
      LOCKED : out std_logic;
      OUTCLK : out std_logic);
  end component;


  
begin
  
  coredevicelink_uut : coredevicelink
    generic map (
      N       => 4,
      DCNTMAX => 800)
    port map (
      CLK       => CLK,
      RXBITCLK  => RXBITCLK,
      TXHBITCLK => TXHBITCLK,
      TXWORDCLK => TXWORDCLK,
      RESET     => RESET,
      TXDIN     => TXDIN,
      TXKIN     => TXKIN,
      TXIO_P    => CORE_TO_DEVICE_P,
      TXIO_N    => CORE_TO_DEVICE_N,
      RXIO_P    => DEVICE_TO_CORE_DELAYED_P,
      RXIO_N    => DEVICE_TO_CORE_DELAYED_N,
      RXDOUT    => RXDOUT,
      RXKOUT    => RXKOUT,
      DROPLOCK  => DROPLOCK,
      LOCKED    => LOCKED,
      DEBUG => DEBUG,
      DEBUGADDR => DEBUGADDR);

  devicelink_uut : devicelink
    port map (
      TXCLKIN    => DL_TXCLKIN,
      TXLOCKED   => DL_TXLOCKED,
      TXDIN      => DL_TXDIN,
      TXDOUT     => DL_TXDOUT,
      TXKOUT     => DL_TXKOUT,
      CLK        => DL_CLK,
      CLK2X      => DL_CLK2X,
      RESET      => DL_RESET,
      RXDIn      => DL_RXDIN,
      RXKIN      => DL_RXKIN,
      RXIO_P     => DEVICE_TO_CORE_P,
      RXIO_N     => DEVICE_TO_CORE_N,
      DEBUGSTATE => DL_DEBUGSTATE,
      DECODEERR  => DL_DECODEERR);

  process
    variable j : integer := 0;
    constant noisecnt : integer := 65;  -- how many 10 ps bursts do we have
                                        -- noise in
    constant bitsequence : std_logic_vector(19 downto 0)
      := "10001110110010101110";
    variable lastval : std_logic := '0';
  begin
    wait until RXBITCLK'event;
    -- remember, this runs every time the input value changes
    -- initial noise
    for i in 0 to noisecnt loop
      DEVICE_TO_CORE_DELAYED_P <= lastval; 
      DEVICE_TO_CORE_DELAYED_N <= not lastval;
      lastval := bitsequence(i mod 20); 
      wait for 10 ps;
    end loop;  -- i

    -- then the good value
    DEVICE_TO_CORE_DELAYED_P <= DEVICE_TO_CORE_P;
    DEVICE_TO_CORE_DELAYED_N <= DEVICE_TO_CORE_N;
    wait for 600 ps;

    -- footer
    for i in 0 to noisecnt loop
      DEVICE_TO_CORE_DELAYED_P <= lastval; 
      DEVICE_TO_CORE_DELAYED_N <= not lastval;
      lastval := bitsequence(i mod 20); 
      wait for 10 ps;
    end loop;  -- i
        
  end process;


  serdes_inst : serdes
    port map (
      CLK    => CLK,
      BITCLK => TXHBITCLK,
      DIN    => CORE_TO_DEVICE_P,
      DOUT   => DL_TXDIN,
      LOCKED => DL_TXLOCKED,
      OUTCLK => DL_TXCLKIN);

  RESET <= '0' after 100 ns;
  -----------------------------------------------------------------------------
  --  Clock generation
  -----------------------------------------------------------------------------
  process
  begin
    while true loop
      masterclk <= masterclk + 1;

      -- this loop executes every 
      wait for 333.333333333333 ps;

      -- to get a 300 MHz clock we divide the 3GHz base clock by 10 
      if masterclk mod 10 = 5 then
        txhbitclk <= '1';
      elsif masterclk mod 10 = 0 then
        txhbitclk <= '0';
      end if;

      -- to get a 250 MHz clock we divide the 3GHz base clock by 12
      if masterclk mod 12 = 6 then
        RXBITCLK <= '1';
      elsif masterclk mod 12 = 0 then
        RXBITCLK <= '0';
      end if;

      -- to get a 60 MHz clock we divide the 3GHz base clock by 50
      if masterclk mod 50 = 25 then
        TXWORDCLK <= '1';
      elsif masterclk mod 50 = 0 then
        TXWORDCLK <= '0';
      end if;

      -- to get a 50 MHz clock we divide the 3GHz base clock by 60
      if masterclk mod 60 = 30 then
        CLK <= '1';
      elsif masterclk mod 60 = 0 then
        CLK <= '0';
      end if;

    end loop;
  end process;

-------------------------------------------------------------------------------
-- Input data
-------------------------------------------------------------------------------

  process
  begin
    for i in 0 to 255 loop
      TXDIN <= std_logic_vector(TO_UNSIGNED(i, 8));
      wait until rising_edge(CLK);
    end loop;  -- i
  end process;

  DL_RXDIN <= DL_TXDOUT;
  DL_RXKIN <= DL_TXKOUT;

  process
    variable last_din : std_logic_vector(7 downto 0) := (others => '0');
    begin
      wait for 400 us;
      wait until rising_edge(CLK);
      last_din := RXDOUT;
      for i in 0 to 1000 loop
        wait until rising_edge(CLK);

        assert RXDOUT = (last_din + 1) report "Error reading RXDOUT" severity error;
        last_din := RXDOUT; 
      end loop;  -- i
      report "End of Simulation" severity failure;
    end process; 
end Behavioral;
