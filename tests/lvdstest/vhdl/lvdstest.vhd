-------------------------------------------------------------------------------
-- Title      : LVDStest
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lvdstest.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/03/27
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
    TX_P        : out std_logic;
    TX_N        : out std_logic;
    RX_P        : in  std_logic;
    RX_N        : in  std_logic;
    CLKIN       : in  std_logic;
    LEDPOWER    : out std_logic;
    LEDVALID    : out std_logic;
    RESET       : in  std_logic;
    CLKBITTXOUT      : out std_logic;
    CLKRXOUT      : out std_logic;
    REFCLKOUT : out std_logic; 
    TXDCMLOCKED : out std_logic;
    RXDCMLOCKED : out std_logic;
    RXDATAOUT   : out std_logic_vector(9 downto 0);
    SHIFT       : in  std_logic;
    DELAYOUT    : out std_logic
    );

end lvdstest;


architecture Behavioral of lvdstest is
  signal clk, clkint : std_logic := '0';

  signal clksrc, clksrcint   : std_logic := '0';
  signal clknone, clknoneint : std_logic := '0';

  signal clkbittxint, clkbittx       : std_logic := '0';
  signal clkbittx180int, clkbittx180 : std_logic := '0';

  signal clkbitrxint, clkbitrx : std_logic := '0';
  signal clkrxint, clkrx       : std_logic := '0';


  signal ledcnt : std_logic_vector(22 downto 0) := (others => '0');

  signal rx, tx : std_logic := '0';

  signal txbits : std_logic_vector(1 downto 0) := (others => '0');

  signal rxdata                            : std_logic_vector(9 downto 0)  := (others => '0');
  signal rxdatareg, rxdatareg1, rxdatareg2 : std_logic_vector(39 downto 0) := (others => '0');

  signal rxcnt  : integer range 0 to 3          := 0;
  signal txdata : std_logic_vector(47 downto 0) :=
    '0' & "0001000000" & '1' &
    '0' & "0000001000" & '1' &
    '0' & "0010000000" & '1' &
    '0' & "0000100000" & '1';

  signal delaycnt : integer range 0 to 65535 := 65535;
  signal DELAYINC : std_logic                := '0';

  signal base_lock : std_logic := '0';
  signal base_rst : std_logic := '0';
  signal base_rst_delay : std_logic_vector(9 downto 0)  := (others => '1'); 

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


  txsrc : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 2,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 5,       -- Can be any integer from 2 to 32
      CLKIN_PERIOD          => 15.0,
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
      STARTUP_WAIT          => false)
    port map(
      CLKIN                 => CLKIN,
      CLK0                  => clkint,
      CLKFB                 => clk,
      CLKFX                 => clksrcint,
      RST                   => RESET,
      LOCKED                => base_lock
      );

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clksrc_bufg : BUFG
    port map (
      O => clksrc,
      I => clksrcint);


  clkbittx_bufg : BUFG
    port map (
      O => clkbittx,
      I => clkbittxint);

  clkbittx180_bufg : BUFG
    port map (
      O => clkbittx180,
      I => clkbittx180int);


  process(clk)
    begin
      if rising_edge(clk) then
        base_rst_delay <= base_rst_delay(8 downto 0) & (not base_lock); 
        
      end if;
    end process; 
  maindcm : DCM_BASE
    generic map (
      CLKDV_DIVIDE          => 3.0,
      CLKFX_MULTIPLY        => 5,
      CLKFX_DIVIDE          => 3,
      CLKIN_PERIOD          => 2.5,
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
      STARTUP_WAIT          => false)
    port map(
      CLKIN                 => clksrc,
      clk0                  => clknoneint,
      CLKFB                 => clknone,

      CLK2X    => clkbittxint,
      CLK2X180 => clkbittx180int,
      CLKFX    => clkbitrxint,
      CLKDV    => clkrxint,
      RST      => base_rst_delay(7),
      LOCKED   => RXDCMLOCKED
      );


  clknonebufg : BUFG
    port map (
      O => clknone,
      I => clknoneint);



  clkbitrxbufg : BUFG
    port map (
      O => clkbitrx,
      I => clkbitrxint);

  clkrxbuft : BUFG
    port map (
      O => clkrx,
      I => clkrxint);


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

  FDDRRSE_inst : FDDRRSE
    port map (
      Q  => tx,                         -- Data output 
      C0 => clkbittx,                   -- 0 degree clock input
      C1 => clkbittx180,                -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => txbits(1),                  -- Posedge data input
      D1 => txbits(0),                  -- Negedge data input
      R  => '0',                        -- Synchronous reset input
      S  => '0'                         -- Synchronous preset input
      );



  deserialize_inst : deserialize
    port map (
      CLK     => clkrx,
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

  shift_data : process(clkrx)
  begin
    if rising_edge(clkrx) then
      if delaycnt = 65530 then
        DELAYINC <= '1';
      else
        DELAYINC <= '0';
      end if;

      DELAYOUT     <= DELAYINC;
      if SHIFT = '1' then
        delaycnt   <= 0;
      else
        if delaycnt = 65535 then
        else
          delaycnt <= delaycnt + 1;
        end if;
      end if;
    end if;
  end process shift_data;

  send_txdata : process(clkbittx)
  begin
    if rising_edge(clkbittx) then
      txbits <= txdata(1 downto 0);
      txdata <= txdata(1 downto 0) & txdata(47 downto 2);
    end if;
  end process send_txdata;

  recive_data : process(clkrx)
  begin
    if rising_edge(clkrx) then

      if rxcnt = 3 then
        rxcnt <= 0;
      else
        rxcnt <= rxcnt + 1;
      end if;

      rxdatareg((rxcnt+1) * 10 -1 downto (rxcnt * 10)) <= rxdata;

      if rxcnt = 0 then
        rxdatareg1 <= rxdatareg;
        rxdatareg2 <= rxdatareg1;
        if rxdatareg2 = rxdatareg1 and (rxdatareg2 /= X"0000000000" and rxdatareg2 /= X"FFFFFFFFFF") then
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

  CLKBITTXOUT    <= clkbittx;
  CLKRXOUT <= clkrx;
  
  RXDATAOUT <= RXDATA;
end Behavioral;
