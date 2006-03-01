-------------------------------------------------------------------------------
-- Title      : SerDesLoop
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serdesloop.vhd
-- Author     : Eric Jonas  <jonas@soma.mit.edu>
-- Company    : 
-- Last update: 2006/02/28
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

entity serdesloop is

  port (
    CLKIN_P   : in  std_logic;
    CLKIN_N   : in  std_logic;
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
end serdesloop;


architecture Behavioral of serdesloop is

  constant WCNT     : integer                                  := 4;
  signal   outsreg  : std_logic_vector(WCNT * 12 - 1 downto 0) := (others => '0');
  signal   serreg   : std_logic_vector(WCNT*12 -1 downto 0)    := (others => '0');
  signal   doutbits : std_logic_vector(1 downto 0)             := (others => '0');

  signal DOUT : std_logic := '0';

  -- clocks
  signal clkin                                  : std_logic := '0';
  signal lowtxclk, lowtxclkint                  : std_logic := '0';
  signal txclk, txclkint, txclk180, txclk180int : std_logic := '0';

  signal word                      : integer range 0 to wcnt-1;
  signal rxdata, rxdatal, rxdatall : std_logic_vector(WCNT*10 - 1 downto 0)
 := (others => '0');

  signal data : std_logic_vector(WCNT*10 - 1 downto 0) := X"0123456789";

begin  -- Behavioral

  CLKIN_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      I          => CLKIN_P,
      IB         => CLKIN_N,
      O          => CLKIN
      );

  -- create clocks
  lowtxclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 1,
    CLKFX_MULTIPLY => 6,
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

  txclk90_bufg : BUFG port map (
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

  sregout : for i in 1 to WCNT generate
    -- start/stop bits
    outsreg(i*12 - 1)  <= '0';
    outsreg(i*12 - 12) <= '1';

    -- data bit
    outsreg(i*12-2 downto i*12-11) <= data(i*10 -1 downto i*10-10);

  end generate sregout;


  REFCLKOUT <= clkin;

  serialize        : process (txclk)
    variable start : std_logic := '1';
  begin

  if rising_edge(txclk) then
    if start = '1' then
      serreg   <= outsreg;
      start := '0';
    else
      serreg   <= serreg(1 downto 0) & serreg(WCNT*12-1 downto 2);
      doutbits <= serreg(1 downto 0);
    end if;
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

    if word = WCNT-1 then
      word       <= 0;
      rxdatal    <= rxdata;
      rxdatall   <= rxdatal;
      if rxdatal = rxdatall then
        LEDVALID <= '1';
      else
        LEDVALID <= '0';
      end if;


    else
      word <= word + 1;
    end if;


    rxdata((word+1)*10 - 1 downto (word+1)*10 - 10) <= DIN;

  end if;

end process;


end Behavioral;
