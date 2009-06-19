
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity manydevicelinktest is
end manydevicelinktest;

architecture Behavioral of manydevicelinktest is

  component manydevicelink

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

  end component;

component dlloop 
  port (
    REFCLKIN  : in  std_logic;
    REFCLKOUT : out std_logic;
    RXCLKIN   : in  std_logic;
    RXLOCKED  : in  std_logic;
    RXDIN     : in  std_logic_vector(9 downto 0);
    TXIO_P    : out std_logic;
    TXIO_N    : out std_logic;
    LEDPOWER  : out std_logic;
    LEDLOCKED : out std_logic;
    LEDVALID  : out std_logic;
    DSPRESETA : out std_logic;
    DSPRESETB : out std_logic;
    DSPRESETC : out std_logic;
    DSPRESETD : out std_logic;

    DECODEERR : out std_logic
    );

end component;

  signal CLKIN    : std_logic                     := '0';
  signal RESET    : std_logic                     := '1';
  signal TXIO_P   : std_logic_vector(18 downto 0) := (others => '0');
  signal TXIO_N   : std_logic_vector(18 downto 0) := (others => '0');
  signal RXIO_P   : std_logic_vector(18 downto 0) := (others => '0');
  signal RXIO_N   : std_logic_vector(18 downto 0) := (others => '0');
  signal LEDPOWER : std_logic                     := '0';
  signal LEDVALID : std_logic                     := '0';


  signal devtxclk  : std_logic_vector(4 downto 0) := (others => '0');
  signal devlocked : std_logic_vector(4 downto 0) := (others => '0');
  signal devpower, devledlocked, devledvalid
 : std_logic_vector(4 downto 0) := (others => '0');

  signal devdin0   : std_logic_vector(9 downto 0) := (others => '0');
  signal devbitclk : std_logic                    := '0';

  constant clkperiod : time := 20 ns;

  signal WORDCLK, TXCLK : std_logic := '0';

  signal REFCLKIN_P, REFCLKIN_N : std_logic := '0';

  signal devrefclk : std_logic_vector(4 downto 0) := (others => '0');

  signal state  : std_logic_vector(7 downto 0) := (others => '0');
  signal rxword : std_logic_vector(9 downto 0) := (others => '0');

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

begin  -- Behavioral


  manydevicelink_uut : manydevicelink
    port map (
      CLKIN      => CLKIN,
      TXIO_P     => TXIO_P,
      TXIO_N     => TXIO_N,
      RXIO_P     => RXIO_P,
      RXIO_N     => RXIO_N,
      LEDPOWER   => LEDPOWER,
      LEDVALID   => LEDVALID,
      WORDCLKOUT => WORDCLK,
      TXCLKOUT   => TXCLK);

  devloop_inst : dlloop
    port map (
      REFCLKOUT  => open, 
      REFCLKIN => CLKIN,
      RXLOCKED => devlocked(0), 
      RXCLKIN    => devrefclk(0),
      rxdin      => devdin0,
      TXIO_P     => RXIO_P(0),
      TXIO_N     => RXIO_N(0),
      LEDPOWER   => devpower(0),
      LEDLOCKED  => devledlocked(0),
      LEDVALID   => devledvalid(0));


  serdes0 : serdes
    port map (
      CLK => CLKIN,
      BITCLK => TXCLK,
      DIN   => TXIO_P(0),
      OUTCLK => devrefclk(0),
      LOCKED   => devlocked(0),
      DOUT   => devdin0);

  RXIO_P <= (others => 'L');
  RXIO_N  <= (others => 'H');



  process
  begin
    while true loop
      wait until rising_edge(TXCLK) or falling_edge(TXCLK);
      devbitclk <= '1';
      wait for 0.8 ns;
      devbitclk <= '0';

    end loop;

  end process;

  CLKIN      <= not CLKIN after clkperiod / 2;
  REFCLKIN_P <= WORDCLK;
  REFCLKIN_N <= not WORDCLK;

  RESET <= '0' after 100 ns;

end Behavioral;
