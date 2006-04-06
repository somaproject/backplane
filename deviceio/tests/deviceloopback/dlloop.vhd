-------------------------------------------------------------------------------
-- Title      : SerDesLoop
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serdesloop.vhd
-- Author     : Eric Jonas  <jonas@soma.mit.edu>
-- Company    : 
-- Last update: 2006/04/05
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Loopback test for serdes
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/02/28  1.0      jonas   Created
-------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity dlloop is
  port (
    REFCLKIN_P   : in  std_logic;
    REFCLKIN_N   : in  std_logic;
    REFCLKOUT : out std_logic; 
    TXCLKIN : in std_logic; 
    TXLOCKED : in  std_logic;
    TXDIN    : in  std_logic_vector(9 downto 0);
    RXIO_P   : out std_logic;
    RXIO_N   : out std_logic;
    LEDPOWER : out std_logic;
    LEDLOCKED : out std_logic;
    LEDVALID : out std_logic;
    DEBUGSTATE : out std_logic_vector(9 downto 0);
    DECODEERR : out std_logic
    );

end dlloop;

architecture Behavioral of dlloop is

  component devicelink
    port (
      TXCLKIN  : in  std_logic;
      TXLOCKED : in  std_logic;
      TXDIN    : in  std_logic_vector(9 downto 0);
      TXDOUT   : out std_logic_vector(7 downto 0);
      TXKOUT   : out std_logic;
      CLK      : out std_logic;
      CLK2X    : out std_logic;
      RESET    : out std_logic;
      RXDIN    : in  std_logic_vector(7 downto 0);
      RXKIN    : in  std_logic;
      RXIO_P   : out std_logic;
      RXIO_N   : out std_logic;
    DEBUGSTATE : out std_logic_vector(3 downto 0);
    
    DECODEERR : out std_logic
      );

  end component;

  signal valid : std_logic := '0';
  
  signal data : std_logic_vector(7 downto 0) := (others => '0');
  signal k : std_logic := '0';
  signal clk, clk2x : std_logic := '0';
  signal RESET : std_logic := '0';
  signal ldebugstate : std_logic_vector(3 downto 0) := (others => '0');

  
  signal pcnt : std_logic_vector(21 downto 0) := (others => '0');
  signal decodeerrint : std_logic := '0';
begin  -- Behavioral

  
  devicelink_inst: devicelink
    port map (
      TXCLKIN  => TXCLKIN,
      TXLOCKED => TXLOCKED,
      TXDIN    => TXDIN,
      TXDOUT   => data,
      TXKOUT   => k, 
      CLK      => clk,
      CLK2X    => clk2x,
      RESET    => RESET,
      RXDIN    => data,
      RXKIN    => '0', 
      RXIO_P   => RXIO_P,
      RXIO_N   => RXIO_N,
      DEBUGSTATE => ldebugstate,
      DECODEERR => decodeerrint);
  
  
  CLKIN_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      I          => REFCLKIN_P,
      IB         => REFCLKIN_N,
      O          => REFCLKOUT
      );
  
  ledpowerproc: process (clk)
    
  begin  -- process ledpowerproc
    if rising_edge(clk) then
      pcnt <= pcnt + 1;
      LEDPOWER <= pcnt(21);


      DEBUGSTATE <= TXDIN; 
      LEDVALID <= not decodeerrint;
      DECODEERR <= decodeerrint;
    end if;
  end process ledpowerproc;

  LEDLOCKED <= not TXLOCKED;

  
end Behavioral;
