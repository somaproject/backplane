library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity windowdetecttest is
end windowdetecttest;

architecture Behavioral of windowdetecttest is

  component windowdetect
    
    generic (
      MAXCNT : integer := 24;
      ADDRN  : integer := 4);
    port (
      CLK    : in  std_logic;
      START  : in  std_logic;
      ADDR   : out std_logic_vector(ADDRN-1 downto 0);
      DIN    : in  std_logic;
      -- Outputs
      OUTPOS : out std_logic_vector(ADDRN-1 downto 0);
      OUTLEN : out std_logic_vector(ADDRN -1 downto 0);
      FAIL : out std_logic;
      DONE   : out std_logic
      );

  end component;

  constant MAXCNT : integer := 24;
  constant ADDRN  : integer := 5;

  signal CLK    : std_logic                           := '0';
  signal START  : std_logic                           := '0';
  signal ADDR   : std_logic_vector(ADDRN-1 downto 0)  := (others => '0');
  signal DIN    : std_logic                           := '0';
  -- Outputs
  signal OUTPOS : std_logic_vector(ADDRN-1 downto 0)  := (others => '0');
  signal OUTLEN : std_logic_vector(ADDRN -1 downto 0) := (others => '0');
  signal DONE   : std_logic                           := '0';
  signal FAIL : std_logic := '0';

  signal test_run      : std_logic := '0';
  signal test_done     : std_logic := '0';
  signal test_data     : std_logic_vector(MAXCNT-1 downto 0);
  signal test_startpos : integer   := 0;
  signal test_len      : integer   := 0;
  signal test_shouldfail : std_logic := '0';
  

begin

  windowdetect_uut : windowdetect
    generic map (
      MAXCNT => MAXCNT,
      ADDRN  => ADDRN)
    port map (
      CLK    => CLK,
      START  => START,
      ADDR   => ADDR,
      DIN    => DIN,
      OUTPOS => OUTPOS,
      OUTLEN => OUTLEN,
      DONE   => DONE,
      FAIL => FAIL);

  CLK <= not CLK after 10 ns;

  testdataout : process(CLK)
  begin
    if rising_edge(clk) then
      DIN <= test_data(to_integer(unsigned(ADDR)));
    end if;
  end process testdataout;

  testproc : process
  begin
    wait until rising_edge(CLK) and test_run = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    START <= '1';
    wait until rising_edge(CLK);
    START <= '0';

    wait until rising_edge(CLK) and DONE = '1';

    assert to_integer(unsigned(OUTPOS)) = test_startpos
      report "Error in recovered startpos" severity error;
    assert to_integer(unsigned(OUTLEN)) = test_len
      report "Error in recovered len" severity error;
    assert FAIL = test_shouldfail report "Did not correctly fail" severity error;
    wait for 3 us;

    wait until rising_edge(CLK);
    test_done <= '1';
    wait until rising_edge(CLK);
    test_done <= '0';

  end process;


-------------------------------------------------------------------------------
-- Actual test jig
-------------------------------------------------------------------------------


  run_tests : process  is
    
    procedure test (
      constant data : in std_logic_vector(MAXCNT- 1 downto 0);
      constant correct_start : in integer;
      constant correct_len : in integer;
      constant shouldfail : in std_logic := '0') is
    begin
      test_data     <= data;
      test_startpos <= correct_start;
      test_len      <= correct_len;
      test_shouldfail <= shouldfail;
      test_run      <= '1';
      wait until rising_edge(CLK);
      test_run      <= '0';
      wait until rising_edge(CLK) and test_done = '1';
      
    end procedure test;
    
  begin
    -- edge cases
    test("000000000000000000000000", 0, 24);
    test("111111111111111111111110", 0, 1);
    test("011111111111111111111111", 23, 1);

    -- normal cases
    test("111111111111111111111101", 1, 1);
    test("111111111111111111011111", 5, 1);
    test("111111111111111100011111", 5, 3); 
    test("111111100000000000011111", 5, 12);

    -- wrap-around cases
    test("011111111111111111111110", 23, 2);

    test("011111111111111111100000", 23, 6);
    test("000111111111111111100000", 21, 8);

    -- multiple points
    test("100011000111111100011111", 5, 3); 
    
    test("101100011001111000011111", 5, 4);
    
    test("100000110001111000011111", 18, 5); 

    -- now, the "fail" case
    test("111111111111111111111111", 0, 0, '1');
    
    report "End of Simulation" severity failure;
  end process run_tests;


  
end Behavioral;
