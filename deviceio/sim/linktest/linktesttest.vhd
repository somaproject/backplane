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
           DIN      : in  std_logic;
           DOUT     : out std_logic;
           LEDERROR : out std_logic;
           LEDVALID : out std_logic;
           LEDPOWER : out std_logic
           );
  end component;


  signal CLKINA, CLKINB : std_logic := '0';
  signal RESETA, RESETB : std_logic := '1';

  signal dataAtoB : std_logic := '0';
  signal dataBtoA : std_logic := '0';

  signal LEDERRORA, LEDERRORB : std_logic := '0';
  signal LEDVALIDA, LEDVALIDB : std_logic := '0';
  signal LEDPOWERA, LEDPOWERB : std_logic := '0';

  constant clkperiod : time := 8 ns;



begin

  linktesta : linktest
    port map (
      CLKIN    => CLKINA,
      RESET    => RESETA,
      DIN      => dataBtoA,
      DOUT     => dataAtoB,
      LEDERROR => LEDERRORA,
      LEDVALID => LEDVALIDA,
      LEDPOWER => LEDPOWERA);

  linktestb : linktest
    port map (
      CLKIN    => CLKINB,
      RESET    => RESETB,
      DIN      => dataBtoA,
      DOUT     => dataAtoB,
      LEDERROR => LEDERRORB,
      LEDVALID => LEDVALIDB,
      LEDPOWER => LEDPOWERB);



  CLKINA <= not CLKINA after clkperiod / 2;
  CLKINB <= not CLKINB after clkperiod / 2  *1.005;  -- half-percent diff

end;
