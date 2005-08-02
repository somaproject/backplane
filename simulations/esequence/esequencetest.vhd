library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity esequencetest is
end esequencetest;

architecture behavior of esequencetest is

  component esequence
    port (
      CLK   : in  std_logic;
      RESET : in  STD_LOGIC;
      TINC  : in  STD_LOGIC;
      ECE   : out std_logic_vector(31 downto 0);
      EVENT : out STD_LOGIC);
  end component; 

  signal CLK            : std_logic                     := '0';
  signal RESET          : std_logic                     := '1';
  signal TINC            : std_logic                     := '0';
  signal ECE : std_logic_vector(31 downto 0) := (others => '0');
  signal EVENT : std_logic := '0';

  



begin

  uut : esequence port map (
    CLK   => CLK,
    RESET => RESET,
    TINC  => TINC,
    ECE   => ECE,
    EVENT => EVENT);

  RESET <= '0'     after 120 ns;
  CLK  <= not CLK after 50 ns;


  -- TINC simulation
  TINCrementer: process (CLK, RESET)
    variable cnt : integer := 0;
    
  begin  -- process TINCrementer
    if RESET = '1' then
      cnt := 0; 
    elsif rising_edge(CLK) then
      if cnt = 400-1 then
        cnt := 0;
      else
        cnt := cnt + 1; 
      end if;
      if cnt = 4 then
        TINC <= '1';
      else
        TINC <= '0';
      end if;
    end if;
  end process TINCrementer;
  
  -- an interesting question is how to properly access and test this module,
  -- especially given that the eventual execution of the unit is dependent on
  -- the exact contents of the EEPROM. Oh well.


  
end;
