

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package somabackplane is
  constant N : integer := 78; 
  type dataarray is array(N-1 downto 0) of std_logic_vector(7 downto 0); 
  type addrarray is array(N-1 downto 0) of std_logic_vector(N-1 downto 0); 
  
end somabackplane;


package body somabackplane is

 
end somabackplane;
