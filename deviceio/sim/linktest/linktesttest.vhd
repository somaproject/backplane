library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity linktesttest is
end linktesttest;

architecture behavior of linktesttest is

  component linktest

    port ( CLKIN_N  : in  std_logic;
           CLKIN_P  : in  std_logic;
           RESET    : in  std_logic;
-- DIN_P : in std_logic;
-- DIN_N : in std_logic;
-- DOUT_P : out std_logic;
-- DOUT_N : out std_logic;
           DOUT     : out std_logic;
           DIN      : in  std_logic;
           LEDGOOD  : out std_logic;
           LEDVALID : out std_logic;
           LEDPOWER : out std_logic;
           DVOUT    : out std_logic;
           DRXOUT   : out std_logic;
           RXCLKOUT : out std_logic;
           SAMPLES  : out std_logic_vector(3 downto 0);
           VALIDOUT : out std_logic);
      
  end component;


  signal CLKINA, CLKINB : std_logic := '0';
  signal RESETA, RESETB : std_logic := '1';

  signal dataAtoB_P, dataAtoB_N : std_logic := '0';
  signal dataBtoA_P, dataBtoA_N : std_logic := '0';

  signal LEDGOODA, LEDGOODB   : std_logic := '0';
  signal LEDVALIDA, LEDVALIDB : std_logic := '0';
  signal LEDPOWERA, LEDPOWERB : std_logic := '0';

  constant clkperiod : time := 20 ns;

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

  signal dina, dinb : std_logic; 
  signal douta, doutb : std_logic;

  signal CLKINA_P, CLKINA_N, CLKINB_P, CLKINB_N : std_logic := '0';

  signal DVOUTA, DVOUTB : std_logic := '0';
  signal DRXOUTA, DRXOUTB : std_logic := '0';
  
begin

  linktesta : linktest
    port map (
      CLKIN_P    => CLKINA_P,
      CLKIN_N    => CLKINA_N,
      
      RESET    => RESETA,
      DIN => DINA,
      DOUT => DOUTA, 
--       DIN_P    => dataBtoA_P,
--       DIN_N    => dataBtoA_N,
--       DOUT_P   => dataAtoB_P,
--       DOUT_N   => dataAtoB_N,
      LEDGOOD  => LEDGOODA,
      LEDVALID => LEDVALIDA,
      LEDPOWER => LEDPOWERA,
      DVOUT => DVOUTA,
      DRXOUT => DRXOUTA);

  linktestb : linktest
    port map (
      CLKIN_P    => CLKINB_P,
      CLKIN_N  => CLKINB_N, 
      RESET    => RESETB,
--       DIN_P    => dataAtoB_P,
--       DIN_N    => dataAtoB_N,
--       DOUT_P   => dataBtoA_P,
--       DOUT_N   => dataBtoA_N,
      DIN => DINB,
      DOUT => DOUTB,
      LEDGOOD  => LEDGOODB,
      LEDVALID => LEDVALIDB,
      LEDPOWER => LEDPOWERB,
      DVOUT => DVOUTB,
      DRXOUT => DRXOUTB
      );



  CLKINA_P <= not CLKINA_P after clkperiod / 2;
  CLKINA_N <= not CLKINA_P; 
  CLKINB_P <= not CLKINB_P after clkperiod / 2 *1.00;  -- half-percent diff
  CLKINB_N <= not CLKINB_P; 

  RESETA <= '0' after 100 ns;
  RESETB <= '0' after 100 ns;


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

  process (douta)
    variable timecnt:  integer range 0 to 5 := 0;
    
    begin
      if timecnt = 0 then
        DINA <= douta after 0.15 ns; 
      elsif timecnt = 1 then
        DINA <= douta after 0.35 ns; 
      else
        DINA <= douta after 0.50 ns; 
      end if; 
      if timecnt = 5 then
      timecnt := 0;

       else
         timecnt := timecnt + 1; 
      end if;

    end process; 

    DINB <= DOUTB; 
  
end;
