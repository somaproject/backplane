



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

  signal cnt  : integer := 0;
begin  -- Behavioral

  -- main clock driver
  mainclk <= not mainclk after 1 ns;
  -- the clock is 30x;
  -- CLKA is 6 ticks, CLKB is 5 ticks,
  --
  --

  serialize_uut: serialize
    port map (
      CLKA   => CLKA,
      CLKB   => CLKB,
      RESET  => RESET,
      BITCLK => BITCLK,
      DIN    => DIN,
      DOUT   => DOUT,
      STOPTX => STOPTX);
  

  clocka_gen : process
    
  begin
    while true loop
      
      wait until rising_edge(mainclk);
      if cnt mod 6 = 0 then
        --CLKA <= not CLKA; 
      end if;

      if cnt mod 5 = 0 then
        CLKB <= not CLKB; 
      end if;

      if cnt mod 1 = 0 then
        BITCLK <= not BITCLK; 
      end if;
      cnt <= cnt + 1;
      
    end loop;   
  end process clocka_gen;



  RESET  <= '0' after 100 ns;


end Behavioral;
