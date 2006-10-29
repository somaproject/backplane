library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity retxbuffer is

  port (
    CLK    : in std_logic;
    CLKHI  : in std_logic;

    -- buffer set A input (write) interface
    WIDA   : in std_logic_vector(13 downto 0);
    WDINA  : in std_logic_vector(15 downto 0);
    WADDRA : in std_logic_vector(8 downto 0);
    WRA    : in std_logic;
    WDONEA : out stdlogic;

    -- output buffer A set B (reads) interface
    RIDA : in std_logic_vector (13 downto 0);
    RREQA : in std_logic;
    RDOUTA : out std_logic_vector(15 downto 0);
    RADDRA : out std_logic_vector(8 downto 0);
    RWROWOUTA : out std_logic_vector(8 downto 0);
    RDONEA : out std_logic; 

--buffer set B input (write) interfafe
    WIDB  : in std_logic_vector(13 downto 0);
    WDINB  : in std_logic_vector(15 downto 0);
    WADDRB : in std_logic_vector(8 downto 0);
    WRB    : in std_logic;
    WDONEB : out std_logic;

    -- output buffer B set Rad (reads) interface
    RIDA : in std_logic_vector (13 downto 0);
    RREQA : in std_logic;
    RDOUTA : out std_logic_vector(15 downto 0);
    RADDRA : out std_logic_vector(8 downto 0);
    RWROWOUTA : out std_logic_vector(8 downto 0);
    RDONEA : out std_logic;

    -- memory output interface
    MEMSTART : out std_logic;
    MEMRW : out std_logic;
    MEMDONE : in std_logic;
    MEMWRADDR : in std_logic_vector(7 downto 0);
    MEMWRDATA : out std_logic_vector(31 downto 0);
    MEMROWTGT : out std_logic_vector(14 downto 0);
    MEMRDDATA: in std_logic_vector(31 downto 0);
    MEMRDADDR: in std_logic_vector(7 downto 0);
    MEMRDWE : in std_logic
    );

end retxbuffer;

architecture Behavioral of retxbuffer is

-- write B signals
  signal widal : std_logic_vector(13 downto 0) := (others => '0');
  signal wdoneal : std_logic := '0';
  signal wda : std_logic_vector(31 downto 0) := (others => '0');
  
-- write B signals
  signal widbl : std_logic_vector(13 downto 0) := (others => '0');
  signal wdonebl : std_logic := '0';
  signal wdb : std_logic_vector(31 downto 0) := (others => '0');
  
-- read A signals
  signal ridal : std_logic_vector(13 downto 0) := (others => '0');
  signal rreqal : std_logic := '0';
  signal lraddra : std_logic_vector(9 downto 0) := "0100000000";
  signal rfwea : std_logic := '0';

-- read B signals
  signal ridbl : std_logic_vector(13 downto 0) := (others => '0');
  signal rreqbl : std_logic := '0';
  signal lraddrb : std_logic_vector(9 downto 0) := "0100000000"; 
  signal rfweb : std_logic := '0';

  
-- control signals
  signal asel, rw : std_logic := '0';
  signal wrtgt, rdtgt : std_logic_vector(13 downto 0);
  signal rw : std_logic := '0';

  
begin  -- Behavioral
  
  -- main muxes
  rdtgt <= ridal when asel = '1' else ridbl;
  wrtgt <= widal when asel = '1' else widbl;
  MEMROWTGT <= "1" & wrtgt when rw = '1' else "0" & rdtgt;

  MEMWRDATA <= wda when asel = '1' else wdb;

  MEMRW <= rw;

  -- write combinational
  rfwea <= asel and MEMRDWE;
  rfweb <= (not asel) and MEMRDWE;
  
  main: process(HICLK)

    
end Behavioral;
