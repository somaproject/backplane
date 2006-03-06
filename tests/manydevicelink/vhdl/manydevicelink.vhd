
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity manydevicelink is

  port (
    CLKIN  : in  std_logic;
    RESET  : in  std_logic;
    TXIO_P : out std_logic_vector(19 downto 0);
    TXIO_N : out std_logic_vector(19 downto 0);
    RXIO_P : in  std_logic_vector(19 downto 0);
    RXIO_N : in  std_logic_vector(19 downto 0);
    VALID  : out std_logic_vector(19 downto 0)
    );

end manydevicelink;

architecture Behavioral of manydevicelink is

  component linktester

    port (
      CLK          : in  std_logic;
      RXBITCLK     : in  std_logic;
      TXHBITCLK    : in  std_logic;
      TXHBITCLK180 : in  std_logic;
      RESET        : in  std_logic;
      TXIO_P       : out std_logic;
      TXIO_N       : out std_logic;
      RXIO_P       : in  std_logic;
      RXIO_N       : in  std_logic;
      VALID        : out std_logic
      );

  end component;

  signal rxhbitclk, rxhbitclk180,
    txhbitclk, txhbitclk180               : std_logic := '0';
  signal txclk, txclkint, rxclk, rxclkint : std_logic;

  signal idelayclk, idelayclkint : std_logic := '0';
  signal dc, dcint : std_logic := '0';

begin  -- Behavioral

  -- create clocks
  -- we generate clocks from a 30-MHz input clock; we go through two dlls
  -- and multiply one by 6x and one by 5x via CLKFX
  txclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 1,
    CLKFX_MULTIPLY => 6)
    port map (
      CLKIN        => CLKIN,
      CLKFB        => txclk,
      RST          => RESET,
      PSEN         => '0',
      CLK0         => txclkint,
      CLKFX        => txhbitclk,
      CLKFX180     => txhbitclk180);

  txclk_bufg : BUFG port map (
    O => txclk,
    I => txclkint);


  rxclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 1,
    CLKFX_MULTIPLY => 5)
    port map (
      CLKIN        => CLKIN,
      CLKFB        => rxclk,
      RST          => RESET,
      PSEN         => '0',
      CLK0        => rxclkint,
      CLKFX        => rxhbitclk,
      CLKFX180     => rxhbitclk180);

  rxclk_bufg : BUFG port map (
    O => rxclk,
    I => rxclkint);

  -- instantiate devices

  devicelinks : for i in 0 to 19 generate
    dl        : linktester
      port map (
        CLK          => TXCLK,
        RXBITCLK     => rxhbitclk,
        TXHBITCLK    => txhbitclk,
        TXHBITCLK180 => txhbitclk180,
        RESET        => RESET,
        TXIO_P       => TXIO_P(i),
        TXIO_N       => TXIO_N(i),
        RXIO_P       => RXIO_P(i),
        RXIO_N       => RXIO_N(i),
        VALID        => VALID(i) );

  end generate devicelinks;

  idelayclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 3,
    CLKFX_MULTIPLY => 20)
    port map (
      CLKIN        => txclk,
      CLKFB        => dc,
      RST          => RESET,
      PSEN         => '0',
      CLK0        => dcint,
      CLKFX        => idelayclkint);

  idelayclk_bufg : BUFG port map (
    O => idelayclk,
    I => idelayclkint);

  delayclk_bufg : BUFG port map (
    O => dc, 
    I => dcint);

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => idelayclk,
      RST    => RESET
      );
  
end Behavioral;
