library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;


entity mactest is
end mactest;

architecture behavior of mactest is

begin
  acc_test         : process
    file afile     : text;
    variable aline : line;
    variable vin   : std_logic_vector(7 downto 0);

  begin
    file_open(afile, "test.dat", read_mode);
    while (not endfile(afile)) loop


      readline(afile, aline);

      while aline'length > 0 loop
        report integer'image(aline'length); 
        hread(aline, vin);

      end loop;

    end loop;

    wait;
  end process;


end;
