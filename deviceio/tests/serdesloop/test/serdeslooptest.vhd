library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity serdeslooptest is

end serdeslooptest;

architecture Behavioral of serdeslooptest is

  component serdesloop

    port (
      CLKIN_P   : in  std_logic;
      CLKIN_N   : in  std_logic;
      RESET     : in  std_logic;
      DOUT      : out std_logic;
      REFCLKOUT : out std_logic;
      RXCLK     : in  std_logic;
      DIN       : in  std_logic_vector(9 downto 0);
      LEDVALID  : out std_logic;
      LEDPOWER  : out std_logic;
      LOCKED    : in  std_logic;
      LEDLOCKED : out std_logic);
  end component;


  signal CLKIN_P, CLKIN_N              : std_logic                    := '0';
  signal RESET                         : std_logic                    := '1';
  signal DOUT                          : std_logic                    := '0';
  signal REFCLKOUT                     : std_logic                    := '0';
  signal RXCLK                         : std_logic                    := '0';
  signal DIN                           : std_logic_vector(9 downto 0) := (others => '0');
  signal LEDVALID, LEDPOWER, LEDLOCKED : std_logic                    := '0';

  signal LOCKED : std_logic;

  signal BITCLK : std_logic := '0';

  signal rxreg, rxregl, rxregll : std_logic_vector(11 downto 0) := (others => '0');
  signal bitpos                 : integer                       := 0;
  signal pos                    : integer range 0 to 11         := 0;

begin  -- Behavioral


  serdesloop_uut : serdesloop
    port map (
      CLKIN_P   => CLKIN_P,
      CLKIN_N   => CLKIN_N,
      RESET     => RESET,
      DOUT      => DOUT,
      REFCLKOUT => REFCLKOUT,
      RXCLK     => RXCLK,
      DIN       => DIN,
      LEDVALID  => LEDVALID,
      LEDPOWER  => LEDPOWER,
      LOCKED    => LOCKED,
      LEDLOCKED => LEDLOCKED);

  CLKIN_P <= not CLKIN_P after 18 ns;
  CLKIN_N <= not CLKIN_P;

  RESET <= '0' after 100 ns;

  RXCLK <= REFCLKOUT;

  BITCLK <= not BITCLK after 1.5 ns;


  -- test deserialize
  deser : process (BITCLK)

  begin
    if rising_edge(bitclk) then
      rxreg    <= DOUT & rxreg(11 downto 1);
      if bitpos mod 12 = pos then
        rxregl <= rxreg;
      end if;

      bitpos <= bitpos + 1;


    end if;
  end process deser;

  deser2 : process
  begin
    while true loop
      wait until rising_edge(refclkout);
      DIN <= rxregll(10 downto 1); 
      rxregll <= rxregl;
      if not (rxregl(11) = '0' and rxregl(0) = '1') then
        wait for 1 us;
        
        pos   <= (pos + 1) mod 12;
        wait for 1 us;
      end if;


    end loop;

  end process deser2;


end Behavioral;
