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
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity lvdsclient is

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
end lvdsclient;


architecture Behavioral of lvdsclient is
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


  signal wcnt : integer range 0 to 3 := 0;

  signal doutbits : std_logic_vector(9 downto 0) := (others => '0');

  signal DOUT                                   : std_logic := '0';
  signal CLKIN                                  : std_logic := '0';
  signal notlocked                              : std_logic := '1';
  -- clocks
  signal lowtxclk, lowtxclkint                  : std_logic := '0';
  signal txclk, txclkint, txclk180, txclk180int : std_logic := '0';

  signal dinl       : std_logic_vector(9 downto 0) := (others => '0');
  signal cerr, derr : std_logic                    := '0';
  signal rxdata     : std_logic_vector(7 downto 0) := (others => '0');
  signal rxk        : std_logic                    := '0';

  signal ledtick : std_logic_vector(22 downto 0) := (others => '0');

  signal dcmlocked : std_logic := '0';
  signal txdata : std_logic_vector(7 downto 0) := (others => '0');
  signal txdataenc : std_logic_vector(9 downto 0) := (others => '0');


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
    CLKIN_PERIOD       => 7.7,
    CLKFX_DIVIDE       => 1,
    CLKFX_MULTIPLY     => 5,
    DFS_FREQUENCY_MODE => "HIGH")
    port map (
      CLKIN            => RXCLK,
      CLKFB            => lowtxclk,
      RST              => LOCKED,
      PSEN             => '0',
      CLK0             => lowtxclkint,
      CLKFX            => txclkint,
      CLKFX180         => txclk180int,
      LOCKED           => dcmlocked);


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



  REFCLKOUT <= CLKIN;

-----------------------------------------------------------------------------
-- Transmit data
-----------------------------------------------------------------------------

  encoder : encode8b10b
    port map (
      CLK => lowtxclk,
      kin => '0',
      din => txdata,
      dout => txdataenc
      ); 

  txdata <= X"00";
  
  serialize         : process(txclk)
    variable bitreg : std_logic_vector(4 downto 0) := "00001";
  begin
    if rising_edge(txclk) then
      bitreg := bitreg(0) & bitreg(4 downto 1);
      if bitreg(0) = '1' then
        doutbits <= txdataenc;
      else
        doutbits <= "00" & doutbits(9 downto 2);
      end if;
    end if;
end process serialize;


  LEDLOCKED <= not LOCKED;
  notlocked <= not LOCKED;


-- dummy led
  ledpowerproc : process(lowtxclk)
  begin
    if rising_edge(lowtxclk) then
      ledtick  <= ledtick + 1;
      LEDPOWER <= ledtick(22);
    end if;
  end process ledpowerproc;


-------------------------------------------------------------------------------
-- verify
-------------------------------------------------------------------------------

  decoder : decode8b10b
    port map (
      CLK      => lowtxclk,
      DIN      => dinl,
      dout     => rxdata,
      kout     => rxk,
      code_err => cerr,
      disp_err => derr);


  verify : process(lowtxclk)
  begin
    if rising_edge(lowtxclk) then

      dinl <= DIN;

      if cerr = '0' and derr = '0' then
        LEDVALID <= '1';
      else
        LEDVALID <= '0';
        
      end if;
    end if; 
  end process;


end Behavioral;
