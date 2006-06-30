library IEEE;
use IEEE.STD_LOGIC_1164.all;
use std.TextIO.all;

use ieee.std_logic_textio.all;

entity network is
  
  port (
    CLK       : in std_logic;
    MYIP      : in std_logic_vector(31 downto 0);
    MYMAC     : in std_logic_vector(31 downto 0);
    NEXTFRAME : out std_logic;
    DOUTEN : in std_logic;
    DOUT: in std_logic_vector(15 downto 0);
    NEWFRAME : out std_logicl
    DOUT : out std_logic_vector(15 downto 0);
    IOCLOCK : out std_logic 
    );

end network;
