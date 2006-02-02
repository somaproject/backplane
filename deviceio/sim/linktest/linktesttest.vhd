library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity linktesttest is
end linktesttest;

architecture behavior of linktesttest is


  component linktest
    port ( CLKIN      : in  std_logic;
           RESET      : in  std_logic;
           DIN_P      : in  std_logic;
           DIN_N      : in  std_logic;
           DOUT_P     : out std_logic;
           DOUT_N     : out std_logic;
           LEDGOOD    : out std_logic;
           LEDVALID   : out std_logic;
           LEDPOWER   : out std_logic);
    
  end component;


  signal CLKINA, CLKINB : std_logic := '0';
  signal RESETA, RESETB : std_logic := '1';

  signal dataAtoB_P, dataAtoB_N : std_logic := '0';
  signal dataBtoA_P, dataBtoA_N : std_logic := '0';

  signal LEDGOODA, LEDGOODB   : std_logic := '0';
  signal LEDVALIDA, LEDVALIDB : std_logic := '0';
  signal LEDPOWERA, LEDPOWERB : std_logic := '0';

  constant clkperiod : time := 8 ns;

  signal RXCLK90, TXCLK, RXCLK : std_logic := '0';

  signal koutout, errout, doenout : std_logic                    := '0';
  signal doutout                  : std_logic_vector(7 downto 0) := (others => '0');

  signal SERIALDOUT, SERIALDOEN : std_logic := '0';

  constant sreglen      : integer := 50;
  signal   srega, sregb : std_logic_vector(sreglen-1 downto 0)
                                  := (others => '0');

  signal kcharrx, kchartx : std_logic := '0';
  
  signal srega1, srega2, srega3, srega4, srega5, srega6, srega7
 : std_logic_vector(sreglen-1 downto 0)
 := (others => '0');


begin

  linktesta : linktest
    port map (
      CLKIN    => CLKINA,
      RESET    => RESETA,
      DIN_P    => dataBtoA_P,
      DIN_N    => dataBtoA_N,
      DOUT_P   => dataAtoB_P,
      DOUT_N   => dataAtoB_N,
      LEDGOOD  => LEDGOODA,
      LEDVALID => LEDVALIDA,
      LEDPOWER => LEDPOWERA);

  linktestb : linktest
    port map (
      CLKIN      => CLKINB,
      RESET      => RESETB,
      DIN_P      => dataAtoB_P,
      DIN_N      => dataAtoB_N,
      DOUT_P     => dataBtoA_P,
      DOUT_N     => dataBtoA_N,
      LEDGOOD    => LEDGOODB,
      LEDVALID   => LEDVALIDB,
      LEDPOWER   => LEDPOWERB
      );



  CLKINA <= not CLKINA after clkperiod / 2;
  CLKINB <= not CLKINB after clkperiod / 2 *1.00;  -- half-percent diff

  RESETA <= '0' after 50 ns;
  RESETB <= '0' after 50 ns;


  regreada : process(clkina)
  begin
    if rising_edge(clkina) or falling_edge(clkina) then
      srega  <= databtoa_p & srega(sreglen-1 downto 1);
      srega1 <= srega;
      srega2 <= srega1;
      srega3 <= srega2;
      srega4 <= srega3;
      srega5 <= srega4;
      srega6 <= srega5; 
              
        if srega(9 downto 0) = "0101111100" or srega(9 downto 0) = "1010000011" then
          kchartx <= '1';
        else
          kchartx <= '0'; 
        end if;


    end if;

  end process;


end;
