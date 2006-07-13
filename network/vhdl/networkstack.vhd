library IEEE;
use IEEE.STD_LOGIC_1164.all;
use std.TextIO.all;

use ieee.std_logic_textio.all;



package networkstack is
  constant N : integer := 5;
  --type dataarray is array(4 downto 0) of std_logic_vector(15 downto 0);

-- synthesis translate_off 
  
  procedure writepkt (
    constant packetfile   : in  string;
    signal   CLK          : in  std_logic;
    signal   DOUTEN       : out std_logic;
    signal   NEXTFRAME    : in  std_logic;
    signal   DOUT         : out std_logic_vector(15 downto 0)
    ); 
-- synthesis translate_on
  
end networkstack;

package body networkstack is

-- synthesis translate_off 

  procedure writepkt (
    constant packetfile   : in  string;
    signal   CLK          : in  std_logic;
    signal   DOUTEN       : out std_logic;
    signal   NEXTFRAME    : in  std_logic;
    signal   DOUT         : out std_logic_vector(15 downto 0)
    ) is
    file data_file        :     text open read_mode is packetfile;
    variable L            :     line;
    variable lbyte, hbyte :     std_logic_vector(7 downto 0);
    variable word: std_logic_vector(15 downto 0); 
  begin

    wait until rising_edge(CLK) and NEXTFRAME = '1';
    wait for 5 ns;


    while not endfile(data_file) loop
      readline(data_file, L);
      while L'length /= 0 loop
        hread(L, word); 

        DOUTEN <= '1';
        DOUT   <= word; 
        wait until rising_edge(CLK) and NEXTFRAME = '1';
        wait for 5 ns;

      end loop;

      deallocate(L);

    end loop;
    DOUTEN <= '0';
    wait until rising_edge(CLK);

  end writepkt;

-- synthesis translate_on
  
end networkstack;
