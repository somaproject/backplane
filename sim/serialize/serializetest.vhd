library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity serializetest is

end serializetest;


architecture Behavioral of serializetest is


  component serialize
    port (
      CLKA   : in  std_logic;
      CLKB   : in  std_logic;
      RESET  : in  std_logic;
      BITCLK : in  std_logic;
      DIN    : in  std_logic_vector(9 downto 0);
      DOUT   : out std_logic;
      STOPTX : in  std_logic
      );

  end component;

  signal CLKA   : std_logic                    := '0';
  signal CLKB   : std_logic                    := '0';
  signal RESET  : std_logic                    := '1';
  signal BITCLK : std_logic                    := '0';
  signal DIN    : std_logic_vector(9 downto 0) := (others => '0');
  signal DOUT   : std_logic                    := '0';
  signal STOPTX : std_logic                    := '0';

  signal mainclk : std_logic := '0';

  signal cnt : integer := 0;


  signal inputdata : std_logic_vector(9 downto 0) := (others => '0');

  signal DOUT_P : std_logic := '0';
  signal DOUT_N : std_logic := '1';

  component serdes

    port (
      RI_P   : in  std_logic;
      RI_N   : in  std_logic;
      REFCLK : in  std_logic;
      BITCLK : in  std_logic;
      LOCK   : out std_logic;
      RCLK   : out std_logic;
      ROUT   : out std_logic_vector(9 downto 0));

  end component;

  signal lock, rclk      : std_logic                    := '0';
  signal rxdata, rxdatal : std_logic_vector(9 downto 0) := (others => '0');

  signal rxdatacnt : integer := 0;





begin  -- Behavioral

  -- main clock driver
  mainclk <= not mainclk after 1 ns;
  -- the clock is 30x;
  -- CLKA is 6 ticks, CLKB is 5 ticks,
  --
  --

  serialize_uut : serialize
    port map (
      CLKA   => CLKA,
      CLKB   => CLKB,
      RESET  => RESET,
      BITCLK => BITCLK,
      DIN    => DIN,
      DOUT   => DOUT,
      STOPTX => STOPTX);


  serdes_inst : serdes
    port map (
      RI_P   => DOUT_P,
      RI_N   => DOUT_N,
      REFCLK => CLKA,
      BITCLK => mainclk,
      LOCK   => lock,
      RCLK   => rclk,
      ROUT   => rxdata);


  clocka_gen : process

  begin
    while true loop

      wait until rising_edge(mainclk);
      if cnt mod 6 = 0 then
        CLKA <= not CLKA;
      end if;

      if cnt mod 5 = 0 then
        CLKB <= not CLKB;
      end if;

      if cnt mod 1 = 0 then
        BITCLK <= not BITCLK;
      end if;
      cnt      <= cnt + 1;

    end loop;
  end process clocka_gen;

  RESET <= '0' after 100 ns;

  -- input data stream
  inputdata_gen : process (CLKA)
  begin
    if rising_edge(CLKA) then
      inputdata <= inputdata + 1;
      DIN       <= inputdata;
    end if;
  end process inputdata_gen;

  DOUT_P <= DOUT;
  DOUT_N <= not DOUT;

  -- data recovery
  data_recovery : process(rclk)
  begin
    if rising_edge(rclk) then
      if LOCK = '0' then
        rxdatal <= rxdata;

        if rxdatal + 1 = rxdata then
          rxdatacnt <= rxdatacnt + 1;

          if rxdatacnt = 2048 then
            assert false report "End of Simulation" severity Failure;

            
          end if;
        else
          rxdatacnt <= 0;
        end if;

      else
        rxdatacnt <= 0;
      end if;
    end if;

  end process data_recovery;
end Behavioral;
