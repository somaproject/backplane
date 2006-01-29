library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity linktesttest is
end linktesttest;

architecture behavior of linktesttest is


  component linktest
    port ( CLKIN    : in  std_logic;
           RESET    : in  std_logic;
           DIN_P      : in  std_logic;
           DIN_N      : in  std_logic;           
           DOUT_P     : out std_logic;
           DOUT_N    : out std_logic; 
           LEDGOOD : out std_logic;
           LEDVALID : out std_logic;
           LEDPOWER : out std_logic
           );
  end component;


  signal CLKINA, CLKINB : std_logic := '0';
  signal RESETA, RESETB : std_logic := '1';

  signal dataAtoB_P, dataAtoB_N : std_logic := '0';
  signal dataBtoA_P, dataBtoA_N : std_logic := '0';

  signal LEDGOODA, LEDGOODB : std_logic := '0';
  signal LEDVALIDA, LEDVALIDB : std_logic := '0';
  signal LEDPOWERA, LEDPOWERB : std_logic := '0';

  constant clkperiod : time := 8 ns;



begin

  linktesta : linktest
    port map (
      CLKIN    => CLKINA,
      RESET    => RESETA,
      DIN_P      => dataBtoA_P,
      DIN_N      => dataBtoA_N,      
      DOUT_P     => dataAtoB_P,
      DOUT_N     => dataAtoB_N,      
      LEDGOOD => LEDGOODA,
      LEDVALID => LEDVALIDA,
      LEDPOWER => LEDPOWERA);

  linktestb : linktest
    port map (
      CLKIN    => CLKINB,
      RESET    => RESETB,
      DIN_P      => dataAtoB_P,
      DIN_N      => dataAtoB_N,      
      DOUT_P     => dataBtoA_P,
      DOUT_N     => dataBtoA_N,      
      LEDGOOD => LEDGOODB,
      LEDVALID => LEDVALIDB,
      LEDPOWER => LEDPOWERB);



  CLKINA <= not CLKINA after clkperiod / 2;
  CLKINB <= not CLKINB after clkperiod / 2  *1.00;  -- half-percent diff

RESETA <= '0' after 50 ns;
  RESETB<= '0' after 50 ns;
  
end;
