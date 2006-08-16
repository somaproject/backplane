library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity readddr2 is
  port (
    CLK    : in  std_logic;
    START  : in  std_logic;
    DONE   : out std_logic;
    -- ram interface
    CS     : out std_logic;
    RAS    : out std_logic;
    CAS    : out std_logic;
    WE     : out std_logic;
    ADDR   : out std_logic_vector(12 downto 0);
    BA     : out std_logic_vector(1 downto 0);
    DIN : in std_logic_vector(31 downto 0); 
    -- input data interface
    ROWTGT : in  std_logic_vector(14 downto 0);
    RADDR  : out std_logic_vector(7 downto 0);
    RDATA  : out  std_logic_vector(31 downto 0);
    RWE : out std_logic;
    NOTERMINATE: in std_logic
    );
end readddr2;

architecture Behavioral of readddr2 is

begin  -- Behavioral
  

  

end Behavioral;
