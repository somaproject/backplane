
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
      CLKIN    : in  std_logic;
      RESET    : in  std_logic;
      TXIO_P   : out std_logic_vector(18 downto 0);
      TXIO_N   : out std_logic_vector(18 downto 0);
      RXIO_P   : in  std_logic_vector(18 downto 0);
      RXIO_N   : in  std_logic_vector(18 downto 0);
      VALID    : out std_logic_vector(18 downto 0);
      LEDPOWER : out std_logic;
      LEDVALID : out std_logic
      );

  end component;

  component dlloop

    port (
      TXCLKIN   : in  std_logic;
      TXLOCKED  : in  std_logic;
      TXDIN     : in  std_logic_vector(9 downto 0);
      RXIO_P    : out std_logic;
      RXIO_N    : out std_logic;
      LEDPOWER  : out std_logic;
      LEDLOCKED : out std_logic

      );

  end component;

  component serdes
    port (
      RI_P   : in  std_logic;
      RI_N   : in  std_logic;
      REFCLK : in  std_logic;
      BITCLK : in  std_logic;
      LOCK   : out std_logic;
      RCLK   : out std_logic;
      ROUT   : out std_logic_vector(9 downto 0));

  end component;

  signal CLKIN    : std_logic                     := '0';
  signal RESET    : std_logic                     := '1';
  signal TXIO_P   : std_logic_vector(18 downto 0) := (others => '0');
  signal TXIO_N   : std_logic_vector(18 downto 0) := (others => '0');
  signal RXIO_P   : std_logic_vector(18 downto 0) := (others => '0');
  signal RXIO_N   : std_logic_vector(18 downto 0) := (others => '0');
  signal VALID    : std_logic_vector(18 downto 0) := (others => '0');
  signal LEDPOWER : std_logic                     := '0';
  signal LEDVALID : std_logic                     := '0';


  signal devtxclk               : std_logic_vector(18 downto 0) := (others => '0');
  signal devlocked              : std_logic_vector(18 downto 0) := (others => '0');
  signal devpower, devledlocked : std_logic_vector(18 downto 0) := (others => '0');

  signal devdin0   : std_logic_vector(9 downto 0) := (others => '0');
  signal devbitclk : std_logic                    := '0';
  signal devrefclk : std_logic                    := '0';

  constant clkperiod : time := 33.333333333333334 ns;

begin  -- Behavioral


  manydevicelink_uut : manydevicelink
    port map (
      CLKIN    => CLKIN,
      RESET    => RESET,
      TXIO_P   => TXIO_P,
      TXIO_N   => TXIO_N,
      RXIO_P   => RXIO_P,
      RXIO_N   => RXIO_N,
      VALID    => VALID,
      LEDPOWER => LEDPOWER,
      LEDVALID => LEDVALID);

  devloop_inst : dlloop
    port map (
      TXCLKIN   => devtxclk(0),
      TXLOCKED  => devlocked(0),
      txdin     => devdin0,
      RXIO_P    => RXIO_P(0),
      RXIO_N    => RXIO_N(0),
      LEDPOWER  => devpower(0),
      LEDLOCKED => devledlocked(0));


  serdes0 : serdes
    port map (
      RI_P   => TXIO_P(0),
      RI_N   => TXIO_N(0),
      REFCLK => devrefclk,
      BITCLK => devbitclk,
      LOCK   => devlocked(0),
      RCLK   => devtxclk(0),
      ROUT   => devdin0);



  devrefclk <= clkin after 2 ns;

  devbitclk <= not devbitclk after clkperiod/(2*12);

  process
  begin
    while true loop
      for i  in 0 to 5 loop
        wait until rising_edge(devbitclk);
      end loop;  -- i 
      CLKIN <= not CLKIN; 
        
      
    end loop;
  end process;



  RESET <= '0' after 100 ns;


end Behavioral;
