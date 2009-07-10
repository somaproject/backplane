library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity serdes is
  -- Simple deserializer for unit testing
  --
  port (
    CLK    : in  std_logic;             -- true 50 Mhz clock
    BITCLK : in  std_logic;             -- 300 Mhz bit clock
    DIN    : in  std_logic;
    DOUT   : out std_logic_vector(9 downto 0);
    LOCKED : out std_logic;
    OUTCLK : out std_logic);
end serdes;


architecture Behavioral of serdes is

  signal bitrecover : std_logic_vector(12 * 8 -1 downto 0) := (others => '0');
  signal high_12    : std_logic_vector(7 downto 0)         := (others => '0');
  signal low_12     : std_logic_vector(7 downto 0)         := (others => '0');
  signal bitpos     : integer                              := 0;
  
  signal outword, outwordrev : std_logic_vector(11 downto 0) := (others => '0');
  signal nolock_delay : integer := 500;
  
begin  -- Behavioral

  bitsels : for i in 0 to 7 generate
    high_12(i) <= bitrecover(12*i + 11);
    low_12(i)  <= bitrecover(12*i);
  end generate bitsels;

  revword: for i in 0 to 11 generate
    outwordrev(i) <= outword(11 -i); 
  end generate revword;

  bitrecovering : process(BITCLK)
  begin
    if rising_edge(BITCLK) or falling_edge(BITCLK) then
      bitrecover(12 * 8 -1 downto 0) <= bitrecover(12*8-2 downto 0) & DIN;
      if bitpos = 0 then
        outword <= bitrecover(11 downto 0);
        if high_12 = X"FF" and low_12 = X"00" then
          -- call this a lock?
          if nolock_delay > 0 then
            nolock_delay <= nolock_delay - 1; 
          end if;
          bitpos <= bitpos + 1;
        else
          bitpos <= bitpos + 2;         -- precess
          nolock_delay <= 500; 
        end if;
      else
        if bitpos = 11 then
          bitpos <= 0;
        else
          bitpos <= bitpos + 1;
        end if;
      end if;
    end if;
  end process bitrecovering;

  LOCKED <= '0' when nolock_delay = 0 else '1';  -- inverted signal
  OUTCLK <= CLK; --  when nolock_delay = 0 else '0';
  DOUT <= outwordrev(10 downto 1) when nolock_delay = 0 else (others => '0'); 
          
  
end Behavioral;
