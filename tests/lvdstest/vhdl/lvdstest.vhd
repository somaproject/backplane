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
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;



entity lvdstest is

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

end lvdstest;


architecture Behavioral of lvdstest is

  signal clktx, clktxint : std_logic := '0';
  signal clkbittxint, clkbittx : std_logic := '0';
  signal clkrx, clkrxint : std_logic := '0';
  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkwrxint, clkwrx : std_logic := '0';
  
                                              
  signal ledcnt            : std_logic_vector(23 downto 0) := (others => '0');

  signal rx, tx                            : std_logic                     := '0';
  signal rxdata                            : std_logic_vector(9 downto 0)  := (others => '0');
  signal rxdatareg, rxdatareg1, rxdatareg2 : std_logic_vector(39 downto 0) := (others => '0');

  signal rxcnt  : integer range 0 to 7          := 0;
  signal txdata : std_logic_vector(47 downto 0) :=
    '0' & "0000100001" & '1' &
    '0' & "0001000011" & '1' &
    '0' & "0001100100" & '1' &
    '0' & "0010000111" & '1';


  component deserialize

    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      BITCLK  : in  std_logic;
      DIN     : in  std_logic;
      DOUT    : out std_logic_vector(9 downto 0);
      DLYRST  : in  std_logic;
      DLYCE   : in  std_logic;
      DLYINC  : in  std_logic;
      BITSLIP : in  std_logic);

  end component;


begin  -- Behavioral


  txdcm : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 1,           -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 6,           -- Can be any integer from 2 to 32
      CLKIN_PERIOD          => 20.0,
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
      STARTUP_WAIT          => true)
    port map(
      CLKIN                 => CLKIN,
      CLK0                  => clktxint,
      CLKFB                 => clktx,
      CLKFX                 => clkbittxint,  -- DCM CLK synthesis out (M/D)
      RST                   => RESET
      );

  clktx_bufg : BUFG
    port map (
      O => clktx,
      I => clktxint);

  clkbittx_bufg : BUFG
    port map (
      O => clkbittx,
      I => clkbittxint);




  rxdcm : DCM_BASE
    generic map (
      CLKDV_DIVIDE          => 2.0,
      CLKFX_MULTIPLY        => 5,
      CLKFX_DIVIDE          => 1, 
      CLKIN_PERIOD          => 2.5,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "HIGH",
      DUTY_CYCLE_CORRECTION => true,
      FACTORY_JF            => X"F0F0",
      PHASE_SHIFT           => 0,
      STARTUP_WAIT          => true)
    port map(
      CLKIN                 => clkin,
      clk0                  => clkrxint,
      CLKFB                 => clkrx,
      CLKFX     => clkbitrxint, 
      CLKDV                 => clkwrxint,
      RST                   => RESET
      );

  clkrxbufg : BUFG
    port map (
      O => clkrx, 
      I => clkrxint);

  clkbitrxbufg : BUFG
    port map (
      O => clkbitrx, 
      I => clkbitrxint);

  clkwrxbuft : BUFG
    port map (
      O => clkwrx,
      I => clkwrxint);


  TX_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => TX_P,
      OB         => TX_N,
      I          => tx
      );

  RX_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      DIFF_TERM  => true)
    port map (
      I          => RX_P,
      IB         => RX_N,
      O          => rx
      );


  deserialize_inst : deserialize
    port map (
      CLK     => clkwrx,
      RESET   => reset,
      BITCLK  => clkbitrx,
      DIN     => rx,
      DOUT    => rxdata,
      DLYRST  => '0',
      DLYCE   => '0',
      DLYINC  => '0',
      BITSLIP => '0');


  --ledpower


  ledpowblink : process (clkrx)
  begin  -- process ledpowblink
    if rising_edge(clkrx) then

      ledcnt   <= ledcnt + 1;
      LEDPOWER <= ledcnt(22);

    end if;
  end process ledpowblink;


  send_txdata : process(clkbittx)
  begin
    if rising_edge(clkbittx) then
      tx     <= txdata(0);
      txdata <= txdata(0) & txdata(47 downto 1);
    end if;
  end process send_txdata;

  recive_data : process(clkwrx)
  begin
    if rising_edge(clkwrx) then

      if rxcnt = 3 then
        rxcnt <= 0;
      else
        rxcnt <= rxcnt + 1;
      end if;

      rxdatareg((rxcnt+1) * 10 -1 downto (rxcnt * 10)) <= rxdata;

      if rxcnt = 0 then
        rxdatareg1 <= rxdatareg;
        rxdatareg2 <= rxdatareg1;
        if rxdatareg2 = rxdatareg1  and (rxdatareg2 /= X"0000000000" and rxdatareg2 /= X"FFFFFFFFFF")  then
          LEDVALID <= '1';
        else
          LEDVALID <= '0';
        end if;
      end if;
    end if;
  end process recive_data;

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clkrx,
      RST    => RESET
      );
  CLKOUT <= clkbittx;

end Behavioral;
