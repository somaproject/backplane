library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity delaylocktest is
end delaylocktest;

architecture Behavioral of delaylocktest is

  
  component delaylock
    port (
      CLK       : in  std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      LOCKED    : out std_logic;
      DEBUG     : out std_logic;
      DEBUGADDR : in  std_logic_vector(5 downto 0);
      WINPOS    : out std_logic_vector(5 downto 0);
      WINLEN    : out std_logic_vector(5 downto 0);
      -- delay interface
      DLYRST    : out std_logic;
      DLYINC    : out std_logic;
      DLYCE     : out std_logic;
      DIN       : in  std_logic_vector(9 downto 0)
      );
  end component;

  signal CLK       : std_logic                    := '0';
  signal START     : std_logic                    := '0';
  signal DONE      : std_logic                    := '0';
  signal LOCKED    : std_logic                    := '0';
  signal DEBUG     : std_logic                    := '0';
  signal DEBUGADDR : std_logic_vector(5 downto 0) := (others => '0');
  signal WINPOS    : std_logic_vector(5 downto 0) := (others => '0');
  signal WINLEN    : std_logic_vector(5 downto 0) := (others => '0');
  -- delay interface
  signal DLYRST    : std_logic                    := '0';
  signal DLYINC    : std_logic                    := '0';
  signal DLYCE     : std_logic                    := '0';
  signal DIN       : std_logic_vector(9 downto 0) := (others => '0');

  constant MAXCNT : integer := 53;
--  constant MAXCNT : integer := 24;
--  constant ADDRN  : integer := 5;

--  signal CLK    : std_logic                           := '0';
--  signal START  : std_logic                           := '0';
--  signal ADDR   : std_logic_vector(ADDRN-1 downto 0)  := (others => '0');
--  signal DIN    : std_logic                           := '0';
--  -- Outputs
--  signal OUTPOS : std_logic_vector(ADDRN-1 downto 0)  := (others => '0');
--  signal OUTLEN : std_logic_vector(ADDRN -1 downto 0) := (others => '0');
--  signal DONE   : std_logic                           := '0';
--  signal FAIL : std_logic := '0';

--  signal test_run      : std_logic := '0';
--  signal test_done     : std_logic := '0';
--  signal test_data     : std_logic_vector(MAXCNT-1 downto 0);
--  signal test_startpos : integer   := 0;
--  signal test_len      : integer   := 0;
--  signal test_shouldfail : std_logic := '0';

  component simdelay
  generic (
    BITSIZE : integer := 26);
    port (
      CLK     : in  std_logic;
      SETMASK : in  std_logic;
      MASKIN  : in  std_logic_vector(BITSIZE-1 downto 0);
      DELAY   : out integer;
      DLYRST  : in  std_logic;
      DLYINC  : in  std_logic;
      DLYCE   : in  std_logic;
      DOUT    : out std_logic_vector(9 downto 0));
  end component;

  signal delay_position : integer                       := 0;
  signal maskin         : std_logic_vector(MAXCNT-1 downto 0) := (others => '0');
  signal setmask        : std_logic                     := '0';
  
begin
  delaylock_uut : delaylock
    port map (
      CLK       => CLK,
      START     => START,
      DONE      => DONE,
      LOCKED    => LOCKED,
      DEBUG     => DEBUG,
      DEBUGADDR => DEBUGADDR,
      WINPOS    => WINPOS,
      WINLEN    => WINLEN,
      DLYRST    => DLYRST,
      DLYINC    => DLYINC,
      DLYCE     => DLYCE,
      DIN       => DIN);

  CLK <= not CLK after 10 ns;

  simdelay_inst : simdelay
    generic map (
      BITSIZE => 53)
    port map (
      CLK     => CLK,
      setmask => setmask,
      MASKIN  => maskin,
      delay   => delay_position,
      dlyrst  => DLYRST,
      DLYINC  => DLYINC,
      DLYCE   => DLYCE,
      DOUT    => DIN);


---------------------------------------------------------------------------------
---- Actual test jig
---------------------------------------------------------------------------------


  run_tests : process is
    procedure test (
      constant mask         : in std_logic_vector(MAXCNT-1 downto 0);
      constant tgtdelay : in integer;
      constant wiggle : in integer
      ) is
    type allowed_t is array (0 to MAXCNT) of boolean;
    variable allowed_delays :  allowed_t := (others => false);
    variable allowed : boolean := false;
  begin
    maskin  <= mask;
    for i in 0 to MAXCNT-1 loop
      allowed_delays(i) := false; 
    end loop;  -- i
    allowed := false;
    
    wait until rising_edge(CLK);
    setmask <= '1';
    wait until rising_edge(CLK);
    setmask <= '0';
    -- now wait a bit and then start
    wait for 10 us;
    wait until rising_edge(CLK);
    START   <= '1';
    wait until rising_edge(CLK);
    START   <= '0';
    wait until rising_edge(CLK) and DONE = '1';

    -- create bit mask of allowed values
    allowed_delays(tgtdelay) := true;
    for i in 0 to wiggle loop
      allowed_delays((tgtdelay + i) mod MAXCNT) := true;
      allowed_delays((tgtdelay -i ) mod MAXCNT) := true; 
    end loop;  -- i

    assert allowed_delays(delay_position) report "recovered delay was not in list of allowed delays" severity error;
    
    -- check for equal to or less than window
    
  end procedure test;

  begin
    -- smaller and smaller center windows
    test("00000000000000000000000000000000000000000000000000000", 26, 1);
    test("11111111110000000000000000000000000000000001111111111", 26, 1);
    test("11111111111111111111000000000000011111111111111111111", 26, 1);

    -- random locations
    test("11111100000000000000000000000000000000000000000000000", 24, 1);
    test("00000000000000000000000000000000000000000000000111111", 29, 1);

    --multiple locations, do we pick the biggest?

    test("11111111111111111111111111110000110000000000001100011", 14, 1);

    -- wrap-around
    test("00001111111111111111111111111111111111111111111110000", 0, 1);

    test("00001111110000001111111111111111111111111111111110000", 0, 1);

    test("00001111111111111111111111111111111100000000011110000", 12, 1);

    report "End of Simulation" severity failure;
  end process run_tests;



end Behavioral;
