library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dqaligntest is

end dqaligntest;

architecture Behavioral of dqaligntest is

  component dqalign
    port (
      CLK          : in    std_logic;
      CLK90        : in    std_logic;
      CLK180       : in    std_logic;
      CLK270       : in    std_logic;
      DQS          : inout std_logic;
      DQ           : inout std_logic_vector(7 downto 0);
      TS           : in    std_logic;
      DIN          : in    std_logic_vector(15 downto 0);
      DOUT         : out   std_logic_vector(15 downto 0);
      START        : in    std_logic;
      LATENCYEXTRA : out   std_logic;

      DONE : out std_logic );
  end component;

  signal CLK    : std_logic                    := '0';
  signal CLK90  : std_logic                    := '0';
  signal CLK180 : std_logic                    := '0';
  signal CLK270 : std_logic                    := '0';
  signal DQS    : std_logic                    := '0';
  signal DQ     : std_logic_vector(7 downto 0) := (others => '0');

  signal TS           : std_logic                     := '1';
  signal DIN          : std_logic_vector(15 downto 0) := (others => '0');
  signal DOUT         : std_logic_vector(15 downto 0) := (others => '0');
  signal START        : std_logic                     := '0';
  signal DONE         : std_logic                     := '0';
  signal LATENCYEXTRA : std_logic                     := '0';

  signal mainclk : std_logic := '0';
  signal clkpos  : integer   := 0;

  signal clockoffset : time := 3.2 ns;

  signal dqcnt : std_logic_vector(15 downto 0) := (others => '0');

  signal dvalid_width : time := 500 ps;
  signal clk_period   : time := 6.6666 ns;

begin  -- Behavioral

  mainclk <= not mainclk after (clk_period / 8);

  dqalign_uut : dqalign
    port map (
      CLK          => CLK,
      CLK90        => CLK90,
      CLK180       => CLK180,
      CLK270       => CLK270,
      DQS          => DQS,
      DQ           => DQ,
      TS           => TS,
      DIN          => DIN,
      DOUT         => DOUT,
      START        => START,
      DONE         => DONE,
      LATENCYEXTRA => LATENCYEXTRA);

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkpos = 3 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;

      if clkpos = 0 then
        CLK <= '1';
      elsif clkpos = 2 then
        CLK <= '0';
      end if;

      if clkpos = 1 then
        CLK90 <= '1';
      elsif clkpos = 3 then
        CLK90 <= '0';
      end if;

      if clkpos = 2 then
        CLK180 <= '1';
      elsif clkpos = 0 then
        CLK180 <= '0';
      end if;

      if clkpos = 3 then
        CLK270 <= '1';
      elsif clkpos = 1 then
        CLK270 <= '0';
      end if;
    end if;
  end process;


  -- clock and data generation
  dqs_gen : process(CLK, DQS)
  begin
    DQS     <= CLK after clockoffset;
    if rising_edge(DQS) then
      dqcnt <= dqcnt + 1;
    end if;
  end process dqs_gen;

  -- drive data outputs for a narrow window
  dq_gen : process
  begin
    wait until rising_edge(DQS);
    wait for clk_period/4- dvalid_width/2;
    DQ <= dqcnt(15 downto 8);
    wait for dvalid_width;
    DQ <= (others => 'Z');
    wait until falling_edge(DQS);
    wait for clk_period/4- dvalid_width/2;
    DQ <= dqcnt(7 downto 0);
    wait for dvalid_width;

    DQ <= (others => 'Z');

  end process;


  -- main validation
  main_validate : process
  begin

    for t in 0 to 30 loop
      clockoffset <= 100 ps * t; 

      wait for 5 us;

      wait until rising_edge(CLK);
      START <= '1';
      wait until rising_edge(CLK);
      START <= '0';
      wait until rising_edge(CLK) and DONE = '1';

      for i in 0 to 300 loop
        wait until rising_edge(CLK);
        if LATENCYEXTRA = '1' then
          assert dqcnt = DOUT + X"0003" report "Error in data read-out";
        else
          assert dqcnt = DOUT + X"0003" report "Error in data read-out";
        end if;


      end loop;  -- i
    end loop;  -- t

  end process;
end Behavioral;

