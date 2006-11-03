library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity clockgen is
  port (
    CLK       : out std_logic;
    MEMCLK    : out std_logic;
    MEMCLKn   : out std_logic;
    MEMCLK90  : out std_logic;
    MEMCLK90n : out std_logic;

    MEMCLK180  : out std_logic;
    MEMCLK180n : out std_logic;

    MEMCLK270  : out std_logic;
    MEMCLK270n : out std_logic
    );
end clockgen;

architecture Behavioral of clockgen is
  signal mainclk               : std_logic := '0';
  signal memclkint, memclk90int,
    memclk180int, memclk270int : std_logic := '0';

  signal clkpos     : integer := 0;
  signal clkslowpos : integer := 0;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.6666 ns;



begin  -- Behavioral
  mainclk <= not mainclk after (clk_period / 8);

  MEMCLK    <= MEMCLKint;
  MEMCLK90  <= MEMCLK90int;
  MEMCLK180 <= MEMCLK180int;
  MEMCLK270 <= MEMCLK270int;


  MEMCLKn    <= not MEMCLKint;
  MEMCLK90n  <= not MEMCLK90int;
  MEMCLK180n <= not MEMCLK180int;
  MEMCLK270n <= not MEMCLK270int;

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkpos = 3 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;

      if clkpos = 0 then
        MEMCLKint <= '1';
      elsif clkpos = 2 then
        MEMCLKint <= '0';
      end if;

      if clkpos = 1 then
        MEMCLK90int <= '1';
      elsif clkpos = 3 then
        MEMCLK90int <= '0';
      end if;

      if clkpos = 2 then
        MEMCLK180int <= '1';
      elsif clkpos = 0 then
        MEMCLK180int <= '0';
      end if;

      if clkpos = 3 then
        MEMCLK270int <= '1';
      elsif clkpos = 1 then
        MEMCLK270int <= '0';
      end if;

      if clkslowpos = 11 then
        clkslowpos <= 0;
      else
        clkslowpos <= clkslowpos + 1;
      end if;

      if clkslowpos = 0 then
        CLK <= '1';
      elsif clkslowpos = 6 then
        CLK <= '0';

      end if;

    end if;
  end process;



end Behavioral;
