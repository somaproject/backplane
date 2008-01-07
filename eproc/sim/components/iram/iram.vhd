library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use std.TextIO.all;

        
entity IRAM is

  generic (
    filename : string);

  port (
    CLK  : in  std_logic;
    ADDR : in  std_logic_vector(9 downto 0);
    DATA : out std_logic_vector(17 downto 0));

end IRAM;

architecture Behavioral of IRAM is

begin  -- Behavioral

  main           : process
    type mem is array (0 to 1023) of std_logic_vector(17 downto 0);
    
    variable ram : mem := (others => (others => '0'));
    variable word : bit_vector(17 downto 0) := (others => '0');
    file data_file : text open read_mode is filename;
    variable L : line;
    variable rampos : integer := 0;
    variable addrnum : natural := 0;
  begin
    while not endfile(data_file) loop
      readline(data_file, L);
      read(L, word);
      ram(rampos) := to_stdlogicvector(word); 
      rampos := rampos + 1;
    end loop;

    -- now the main loop
    while true loop
      wait until rising_edge(CLK);
      addrnum := TO_INTEGER(unsigned(ADDR));
      DATA <= ram(addrnum);
    end loop;
  end process main;

end Behavioral;
