library IEEE;

use std.TextIO.all;
use ieee.std_logic_textio.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
       
library UNISIM;
use UNISIM.vcomponents.all;


entity bitcnttest is
end bitcnttest;


architecture Behavioral of bitcnttest is

  component bitcnt
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic_vector(95 downto 0);
      DOUT  : out std_logic_vector(6 downto 0);
      START : in  std_logic;
      DONE  : out std_logic
      );
  end component;

  signal CLK  : std_logic                     := '0';
  signal DIN  : std_logic_vector(95 downto 0) := (others => '0');
  signal DOUT : std_logic_vector(6 downto 0)  := (others => '0');

  signal START : std_logic := '0';
  signal DONE  : std_logic := '0';

begin  -- Behavioral
  bitcnt_uut : bitcnt
    port map (
      CLK   => CLK,
      DIN   => DIN,
      DOUT  => DOUT,
      START => START,
      DONE  => DONE);

  CLK <= not CLK after 10 ns;
  
  main             : process
    file datafile  : text;
    variable L     : line;
    variable srcin : std_logic_vector(95 downto 0);
    variable value : integer;

  begin
    wait for 2 us;
    file_open(datafile, "data.txt");

    while not endfile(datafile) loop

      readline(datafile, L);
      -- read in vecfor
      for i in 0 to 95 loop
        read(L, value);
        if value = 1 then
          srcin(i) := '1';
        else
          srcin(i) := '0';
        end if;
      end loop;  -- i 

      read(L, value);                   -- value now has cnt

      -- ready to go like a republica song
      wait until rising_edge(CLK);
      DIN   <= srcin;
      START <= '1';
      wait until rising_edge(CLK);
      DIN   <= (others => '0');

      START <= '0';
      wait until rising_edge(CLK) and DONE = '1';
      assert TO_INTEGER(unsigned(DOUT)) = value
        report "Error reading value cnt" severity error;



    end loop;
    report "End of Simulation" severity Failure;
    
  end process main;



end Behavioral;
