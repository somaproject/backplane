library IEEE;
use IEEE.STD_LOGIC_1164.all;

package networkstack is
  constant N : integer := 5; 
  type dataarray is array(N-1 downto 0) of std_logic_vector(15 downto 0); 
  
end networkstack; 
