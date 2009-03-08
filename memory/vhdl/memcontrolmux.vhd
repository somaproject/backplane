library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memcontrolmux is
  port (
    -- control
    IFACESEL : in  std_logic;
    -- output: 
    START    : out std_logic;
    RW       : out std_logic;
    DONE     : in  std_logic;
    ROWTGT   : out std_logic_vector(14 downto 0);
    WRADDR   : in  std_logic_vector(7 downto 0);
    WRDATA   : out std_logic_vector(31 downto 0);
    RDADDR   : in  std_logic_vector(7 downto 0);
    RDDATA   : in  std_logic_vector(31 downto 0);
    RDWE     : in  std_logic;
    -- input A: 
    STARTA   : in  std_logic;
    RWA      : in  std_logic;
    DONEA    : out std_logic;
    ROWTGTA  : in  std_logic_vector(14 downto 0);
    WRADDRA  : out std_logic_vector(7 downto 0);
    WRDATAA  : in  std_logic_vector(31 downto 0);
    RDADDRA  : out std_logic_vector(7 downto 0);
    RDDATAA  : out std_logic_vector(31 downto 0);
    RDWEA    : out std_logic;
    -- input B: 
    STARTB   : in  std_logic;
    RWB      : in  std_logic;
    DONEB    : out std_logic;
    ROWTGTB  : in  std_logic_vector(14 downto 0);
    WRADDRB  : out std_logic_vector(7 downto 0);
    WRDATAB  : in  std_logic_vector(31 downto 0);
    RDADDRB  : out std_logic_vector(7 downto 0);
    RDDATAB  : out std_logic_vector(31 downto 0);
    RDWEB    : out std_logic
    );
end memcontrolmux;


architecture Behavioral of memcontrolmux is

begin  -- Behavioral
  DONEA <= DONE;
  DONEB <= DONE;

  WRADDRA <= WRADDR;
  WRADDRB <= WRADDR;

  RDADDRA <= RDADDR;
  RDADDRB <= RDADDR;

  RDDATAA <= RDDATA;
  RDDATAB <= RDDATA;

  RDWEA <= RDWE;
  RDWEB <= RDWE;

  START  <= STARTA  when IFACESEL = '0' else STARTB;
  RW     <= RWA     when IFACESEL = '0' else RWB;
  ROWTGT <= ROWTGTA when IFACESEL = '0' else ROWTGTB;
  WRDATA <= WRDATAA when IFACESEL = '0' else WRDATAB;
  
  
end Behavioral;
