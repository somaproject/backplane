library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


package netports is

  -- from network to backplane, requesting data retransmission
  
  constant DATARETXREQ_INT : integer := 4400;
  constant DATARETXREQ : std_logic_vector(15 downto 0)
    := std_logic_vector(TO_UNSIGNED(DATARETXREQ_INT, 16));
  
  constant EVENTRETXREQ_INT : integer := 5500;
  constant EVENTRETXREQ : std_logic_vector(15 downto 0)
    := std_logic_vector(TO_UNSIGNED(EVENTRETXREQ_INT, 16));

  constant EVENTRX_INT : integer := 5100;
  constant EVENTRX : std_logic_vector(15 downto 0)
    := std_logic_vector(TO_UNSIGNED(EVENTRX_INT, 16));

  constant EVENTTX_INT : integer := 5000;
  constant EVENTTX : std_logic_vector(15 downto 0)
    := std_logic_vector(TO_UNSIGNED(EVENTTX_INT, 16));


end package;

