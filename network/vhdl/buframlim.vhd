library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity buframlim is
  port (
    CLK    : in std_logic;
    DIN    : in std_logic_vector(15 downto 0);
    ADDRIN : in std_logic_vector(8 downto 0);
    WE : in std_logic;
    INDONE : in std_logic;

    -- output
    MEMCLK: in std_logic;
    WIDA : out std_logic_vector(13 downto 0);
    DOUT : out std_logic_vector(15 downto 0);
    WADDRA : out std_logic_vector(8 downto 0);
    WRA : out std_logic;
    WDONEA : out std_logic    
    );
end buframlim;

architecture Behavioral of buframlim is

begin  -- Behavioral

  

end Behavioral;

