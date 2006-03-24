-------------------------------------------------------------------------------
-- Title      : LVDStest
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lvdstest.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/03/24
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
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity lvdsclient is

  port (
    CLKIN    : in std_logic; 
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
end lvdsclient;


architecture Behavioral of lvdsclient is

  signal wcnt     : integer range 0 to 3  := 0;

  signal   doutbits : std_logic_vector(1 downto 0)             := (others => '0');

  signal DOUT : std_logic := '0';

  -- clocks
  signal lowtxclk, lowtxclkint                  : std_logic := '0';
  signal txclk, txclkint, txclk180, txclk180int : std_logic := '0';

  signal rxdata, rxdatal, rxdatall : std_logic_vector(39 downto 0)
 := (others => '0');

  signal txdata : std_logic_vector(39 downto 0) :=
    "0100101101" &
    "0110100101" &
    "0101001111" &
    "0111101001"; 
    

begin  -- Behavioral

  -- create clocks
  lowtxclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 1,
    CLKFX_MULTIPLY => 5,
    DFS_FREQUENCY_MODE => "HIGH")
    port map (
      CLKIN        => clkin,
      CLKFB        => lowtxclk,
      RST          => '0',
      PSEN         => '0',
      CLK0         => lowtxclkint,
      CLKFX        => txclkint,
      CLKFX180     => txclk180int,
      LOCKED       => LEDPOWER);


  lowtxclk_bufg : BUFG port map (
    O => lowtxclk,
    I => lowtxclkint);

  txclk_bufg : BUFG port map (
    O => txclk,
    I => txclkint);

  txclk180_bufg : BUFG port map (
    O => txclk180,
    I => txclk180int);

  FDDRRSE_inst : FDDRRSE
    port map (
      Q  => DOUT,                       -- Data output 
      C0 => txclk,                      -- 0 degree clock input
      C1 => txclk180,                   -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => doutbits(1),                -- Posedge data input
      D1 => doutbits(0),                -- Negedge data input
      R  => '0',                        -- Synchronous reset input
      S  => '0'                         -- Synchronous preset input
      );

  DIN_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => DOUT_P,
      OB         => DOUT_N,
      I          => DOUT
      );

  -- set up the shift output register; this will end up being a constant



  REFCLKOUT <= clkin;

  serialize        : process (txclk)
    variable start : std_logic := '1';
  begin

  if rising_edge(txclk) then
      txdata   <= txdata(1 downto 0) & txdata(39 downto 2);
      doutbits <= txdata(1 downto 0);
  end if;
end process serialize;



LEDLOCKED <= not LOCKED;

-- dummy led
ledpowerproc     : process(lowtxclk)
  variable power : std_logic := '0';
begin
  if rising_edge(lowtxclk) then
    power                    := not power;
    --LEDPOWER <= power;      
  end if;

end process ledpowerproc;


-- verify
verify : process(RXCLK)


begin
  if rising_edge(RXCLK) then

    if wcnt = 3 then
      wcnt <= 0;

    else
      wcnt <= wcnt + 1;
      
    end if;
    
    rxdata <= DIN & rxdata(39 downto 10);

    if wcnt = 3 then
      rxdatal <= rxdata;
      rxdatall <= rxdatal; 
    end if;

    if wcnt = 2 then
      if rxdatall = rxdatal and not (rxdatall = X"0000000000"  or rxdatall = X"FFFFFFFFFF") then 
        LEDVALID <= '1';
      else
        LEDVALID <= '0'; 
      end if;
    end if;

  end if;

end process;


end Behavioral;
