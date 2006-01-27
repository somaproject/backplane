library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity serializetest is
end serializetest;

architecture behavior of serializetest is

  component serialize
    port ( TXBYTECLK : in  std_logic;
           TXCLK     : in  std_logic;
           DIN       : in  std_logic_vector(9 downto 0);
           DOUT      : out std_logic
           );

  end component;

  signal TXBYTECLK : std_logic                    := '0';
  signal TXCLK     : std_logic                    := '0';
  signal RXCLK     : std_logic                    := '0';
  signal DIN       : std_logic_vector(9 downto 0) := (others => '0');
  signal DOUT      : std_logic                    := '0';


  constant txclkperiod : time := 4 ns;

  signal pendingword : std_logic_vector(9 downto 0) := (others => '0');

  signal incnt : integer := 0;
  signal dat : std_logic_vector(9 downto 0) := (others => '0');
  signal datwaiting : std_logic_vector(9 downto 0) := (others => '0');  


begin

  serialize_uut : serialize
    port map (
      TXBYTECLK => TXBYTECLK,
      TXCLK     => TXCLK,
      DIN       => DIN,
      DOUT      => DOUT);


  TXCLK <= not TXCLK after txclkperiod / 2;

  TXBYTECLK <= not TXBYTECLK after txclkperiod/2*10;

  RXCLK <= TXCLK after 1.715715 ns;

  send : process (TXBYTECLK)
  begin
    if rising_edge(TXBYTECLK) then
      if incnt = 1023 then
        incnt <= 0;
      else
        incnt <= incnt + 1;               
      end if;
      DIN <= std_logic_vector(TO_UNSIGNED(incnt, 10)); 
    end if;

  end process send;



  receive : process (RXCLK)
  begin
    if rising_edge(RXCLK) then
      dat <= DOUT & dat(9 downto 1);
    end if;
  end process receive;

  verify : process
  begin
    for i in 1 to 1023 loop
      datwaiting <= std_logic_vector(TO_UNSIGNED(i, 10));
      wait until dat = datwaiting; 

    end loop;  -- i

    assert false report "End of Simulation" severity failure;

  end process verify;

end;
