
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity deserialize is

  port (
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    BITCLK  : in  std_logic;
    DIN     : in  std_logic;
    DOUT    : out std_logic_vector(9 downto 0);
    DLYRST  : in  std_logic;
    DLYCE   : in  std_logic;
    DLYINC  : in  std_logic;
    BITSLIP : in  std_logic);

end deserialize;


architecture Behavioral of deserialize is

  signal s1, s2 : std_logic := '0';

--   component ISERDES
--     -- synthesis translate_off
--     generic (
--       BITSLIP_ENABLE :     string  := "FALSE";    --(TRUE, FALSE)
--       DATA_RATE      :     string  := "DDR";      --(SDR, DDR)
--       DATA_WIDTH     :     integer := 4;          --(2,3,4,5,6,7,8,10)
--       INTERFACE_TYPE :     string  := "MEMORY";   --(MEMORY, NETWORKING)
--       IOBDELAY       :     string  := "NONE";     --(NONE,IBUF,IFD,BOTH)
--       IOBDELAY_TYPE  :     string  := "DEFAULT";  --(DEFAULT,FIXED, VARIABLE)
--       IOBDELAY_VALUE :     integer := 0;          --(0 to 63)
--       NUM_CE         :     integer := 2;          --(1,2)
--       SERDES_MODE    :     string  := "MASTER"   --(MASTER, SLAVE)
--       );
-- -- synthesis translate_on
--     port (
--       O              : out std_logic;
--       Q1             : out std_logic;
--       Q2             : out std_logic;
--       Q3             : out std_logic;
--       Q4             : out std_logic;
--       Q5             : out std_logic;
--       Q6             : out std_logic;
--       SHIFTOUT1      : out std_logic;
--       SHIFTOUT2      : out std_logic;
--       BITSLIP        : in  std_logic;
--       CE1            : in  std_logic;
--       CE2            : in  std_logic;
--       CLK            : in  std_logic;
--       CLKDIV         : in  std_logic;
--       D              : in  std_logic;
--       DLYCE          : in  std_logic;
--       DLYINC         : in  std_logic;
--       DLYRST         : in  std_logic;
--       OCLK           : in  std_logic;
--       REV            : in  std_logic;
--       SHIFTIN1       : in  std_logic;
--       SHIFTIN2       : in  std_logic;
--       SR             : in  std_logic
--       );
--   end component;

begin  -- Behavioral

  iserdes_1: ISERDES
    generic map (
      BITSLIP_ENABLE => True,
      DATA_RATE      => "DDR",
      DATA_WIDTH     => 10,
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY       => "BOTH",
      IOBDELAY_TYPE  => "VARIABLE",
      NUM_CE         => 1,
      SERDES_MODE    => "MASTER")
    port map (
      O         => open,
      Q1        => DOUT(9),
      Q2        => DOUT(8),
      Q3        => DOUT(7),
      Q4        => DOUT(6),
      Q5        => DOUT(5),
      Q6        => DOUT(4),
      SHIFTOUT1 => s1,
      SHIFTOUT2 => s2,
      CE1       => '1',
      CE2       => '1',
      CLK       => BITCLK,
      CLKDIV    => CLK,
      D         => DIN,
      DLYCE     => DLYCE,
      DLYINC    => DLYINC,
      DLYRST    => DLYRST,
      REV       => '0',
      SHIFTIN1  => '0',
      SHIFTIN2  => '0',
      BITSLIP => bitslip,
      OCLK =>  '0', 
      SR        => RESET);
  
    
  iserdes_2: ISERDES
    generic map (
      BITSLIP_ENABLE => True,
      DATA_RATE      => "DDR",
      DATA_WIDTH     => 10,
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY       => "BOTH",
      IOBDELAY_TYPE  => "VARIABLE",
      NUM_CE         => 1,
      SERDES_MODE    => "SLAVE")
    port map (
      O         => open,
      Q1        => open,
      Q2        => open,
      Q3        => DOUT(3),
      Q4        => DOUT(2),
      Q5        => DOUT(1),
      Q6        => DOUT(0),
      SHIFTOUT1 => open,
      SHIFTOUT2 => open,
      CE1       => '1',
      CE2       => '1',
      CLK       => BITCLK,
      CLKDIV    => CLK,
      D         => '0',
      DLYCE     => DLYCE,
      DLYINC    => DLYINC,
      DLYRST    => DLYRST,
      REV       => '0',
      SHIFTIN1  => s1,
      SHIFTIN2  => s2,
      BITSLIP => bitslip,
      OCLK =>  '0', 
      SR        => RESET);
      

end Behavioral;
