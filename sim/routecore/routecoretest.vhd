library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;


entity routecoretest is
end routecoretest;

library WORK;
use WORK.somabackplane.all;

architecture behavior of routecoretest is


  component routecore

    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      EPOS     : out std_logic_vector(3 downto 0);
      EDATASEL : out std_logic_vector(3 downto 0);
      EDATAOUT : out std_logic_vector(7 downto 0);
      ECYCLE   : out std_logic;
      DSEL     : out std_logic_vector(3 downto 0);
      DGRANT   : out std_logic_vector(39 downto 0);
      EDATAIN  : in  dataarray);
  end component;


  signal CLK   : std_logic := '0';
  signal RESET : std_logic := '1';

  signal EPOS     : std_logic_vector(3 downto 0) := (others => '0');
  signal EDATASEL : std_logic_vector(3 downto 0) := (others => '0');
  signal EDATAOUT : std_logic_vector(7 downto 0) := (others => '0');
  signal ECYCLE   : std_logic                    := '0';
  signal DSEL     : std_logic_vector(3 downto 0) := (others => '0');
  signal DGRANT   : std_logic_vector(39 downto 0);
  signal EDATAIN  : dataarray                    := (others => X"00");


  signal epos_expected   : integer := 0;
  signal ecycle_expected : integer := 499;



begin

  routecore_uut : routecore port map (
    CLK      => CLK,
    RESET    => RESET,
    EPOS     => EPOS,
    EDATASEL => EDATASEL,
    EDATAOUT => EDATAOUT,
    ECYCLE   => ECYCLE,
    DSEL     => DSEL,
    DGRANT   => DGRANT,
    EDATAIN  => EDATAIN);

  CLK <= not CLK after 20 ns;

  RESET                     <= '0' after 100 ns;
  -- test ecycle
  ecycle_test : process(CLK)
  begin
    if RESET = '1' then
    else
      if rising_edge(CLK) then
        if ecycle_expected < 0 and
          ECYCLE = '1' then             -- start up correction
          ecycle_expected   <= 1;
        else
          if ECYCLE = '1' then
            assert ecycle_expected = 499
              report "ecycle interval longer than 500 ticks";
            ecycle_expected <= 0;
          else
            ecycle_expected <= ecycle_expected + 1;
          end if;
        end if;
      end if;
    end if;
  end process ecycle_test;

  epos_test : process(CLK)
  begin
    if RESET = '1' then

    else
      if rising_edge(CLK) then
        if epos_expected < 0 or epos_expected = 15 then
          if ECYCLE = '1' then
            epos_expected <= 1;
          end if;
        else
          assert std_logic_vector(TO_UNSIGNED(epos_expected, 4)) =
            epos report "invalid epos";
          if epos_expected < 15 then
            epos_expected <= epos_expected + 1;
          end if;
        end if;
      end if;

    end if;
  end process epos_test;


end;
