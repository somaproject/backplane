library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use std.TextIO.all;
use ieee.std_logic_textio.all;

entity outverify is
  generic (
    filename :     string);
  port (
    CLK      : in  std_logic;
    ADDR     : in  std_logic_vector(7 downto 0);
    DATA     : in  std_logic_vector(15 downto 0);
    STROBE   : in  std_logic;
    EXPADDR  : out std_logic_vector(7 downto 0);
    EXPDATA  : out std_logic_vector(15 downto 0);
    ERR    : out std_logic := '0';
    DONE : out std_logic );
end outverify;

architecture Behavioral of outverify is

begin  -- Behavioral

  main             : process
    file data_file : text open read_mode is filename;
    variable L     : line;
    variable paddr : std_logic_vector(7 downto 0)  := (others => '0');
    variable pdata : std_logic_vector(15 downto 0) := (others => '0');

  begin
    DONE <= '0'; 
    while not endfile(data_file) loop
      readline(data_file, L);
      hread(L, paddr);
      hread(L, pdata);
      wait until rising_edge(CLK) and STROBE = '1';
      assert paddr = ADDR report "OUTPORT ADDR ERROR" severity error;
      assert pdata = DATA report "OUTPORT DATA ERROR (at : " &
        integer'image(to_integer(unsigned(paddr))) & ") " &
        integer'image(to_integer(unsigned(DATA))) & " != " &
        integer'image(to_integer(unsigned(pdata)))        
        severity error;
      EXPADDR <= paddr;
      EXPDATA <= pdata;
      if paddr /= ADDR or pdata /= DATA then
        ERR <= '1';
      else
        ERR <= '0'; 
      end if;
    end loop;
    wait for 10 ns;
    
    DONE <= '1'; 
    wait;
  end process main;

end Behavioral;
