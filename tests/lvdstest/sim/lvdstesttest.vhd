
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all; 

entity lvdstesttest is

end lvdstesttest;

architecture Behavioral of lvdstesttest is


  component lvdstest

    port (
      TX_P     : out std_logic;
      TX_N     : out std_logic;
      RX_P     : in  std_logic;
      RX_N     : in  std_logic;
      CLKIN    : in  std_logic;
      LEDPOWER : out std_logic;
      LEDVALID : out std_logic;
      RESET    : in  std_logic;
      CLKOUT   : out std_logic
      );

  end component;

  
  component lvdsclient
    port (
      CLKIN     : in  std_logic;
      RESET     : in  std_logic;
      DOUT_P    : out std_logic;
      DOUT_N    : out std_logic;
      REFCLKOUT : out std_logic;
      RXCLK     : in  std_logic;
      DIN       : in  std_logic_vector(9 downto 0);
      LEDVALID  : out std_logic;
      LEDPOWER  : out std_logic;
      LOCKED    : in  std_logic;
      LEDLOCKED : out std_logic);
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




  signal CORECLKIN : std_logic                    := '0';
  signal DEVCLKIN  : std_logic                    := '0';
  signal RESET     : std_logic                    := '1';
  signal TXBITCLKOUT : std_logic := '0'; 
  signal TX_P      : std_logic                    := '0';
  signal TX_N      : std_logic                    := '1';
  signal RX_P      : std_logic                    := '0';
  signal RX_N      : std_logic                    := '1';
  signal REFCLKOUT : std_logic                    := '0';
  signal RXCLK     : std_logic                    := '0';
  signal DIN       : std_logic_vector(9 downto 0) := (others => '0');
  signal CORELEDVALID  : std_logic                    := '0';
  signal CORELEDPOWER  : std_logic                    := '0';
  signal DEVLEDVALID  : std_logic                    := '0';
  signal DEVLEDPOWER  : std_logic                    := '0';
  signal LOCKED    : std_logic                    := '0';
  signal DEVLEDLOCKED : std_logic                    := '0';
  signal ROUT : std_logic_vector(9 downto 0) := (others => '0');
  signal RCLK : std_logic := '0';
  

begin  -- Behavioral

  lvdstest_uut: lvdstest
    port map (
      TX_P     => TX_P,
      TX_N     => TX_N,
      RX_P     => RX_P,
      RX_N     => RX_N,
      CLKIN    => CORECLKIN,
      LEDPOWER => CORELEDPOWER,
      LEDVALID => CORELEDVALID,
      RESET    => RESET,
      CLKOUT   => TXBITCLKOUT);

  lvdsclient_uut : lvdsclient
    port map (
      CLKIN     => DEVCLKIN,
      RESET     => RESET,
      DOUT_P    => RX_P,
      DOUT_N    => RX_N,
      REFCLKOUT => REFCLKOUT,
      RXCLK     => RCLK,
      DIN       => ROUT,
      LEDVALID  => DEVLEDVALID,
      LEDPOWER  => DEVLEDPOWER,
      LOCKED    => LOCKED,
      LEDLOCKED => DEVLEDLOCKED); 
    

  
    RESET <= '0' after 100 ns;

  CORECLKIN <= not CORECLKIN after 8.3333333333333339 ns;

  process(CORECLKIN)
  begin
    if rising_edge(CORECLKIN) then
      DEVCLKIN <= not DEVCLKIN;         -- generate 30 MHz clock
    end if;
  end process;

  serdes_uut: serdes
    port map (
      RI_P   => TX_P,
      RI_N   => TX_N,
      REFCLK => REFCLKOUT,
      BITCLK => TXBITCLKOUT,
      LOCK   => LOCKED,
      RCLK   => RCLK,
      ROUT   => ROUT); 


end Behavioral;
