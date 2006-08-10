library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity memtesttest is
end memtesttest;

architecture Behavioral of memtesttest is

  component memtest
    port (
      CLKIN   : in    std_logic;
      RAMDQ   : inout std_logic_vector(15 downto 0);
      RAMWE   : out   std_logic;
      RAMADDR : out   std_logic_vector(16 downto 0);
      MEMCLK  : out   std_logic
      );
  end component;

  signal CLKIN  : std_logic := '0';
  signal MEMCLK : std_logic := '0';

  signal RAMDQ   : std_logic_vector(15 downto 0) := (others => '0');
  signal RAMWE   : std_logic                     := '0';
  signal RAMADDR : std_logic_vector(16 downto 0) := (others => '0');

-- memory signals
  signal ramwel, ramwell     : std_logic                     := '1';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                                             := (others => '0');
  signal ram_intq            : std_logic_vector(15 downto 0) := (others => '0');

  signal ESTATE : std_logic := '0';


  
begin  -- Behavioral

  CLKIN <= not CLKIN after 8 ns;

  memtest_uut : memtest
    port map (
      CLKIN   => CLKIN,
      RAMDQ   => RAMDQ,
      RAMWE   => RAMWE,
      RAMADDR => RAMADDR,
      MEMCLK  => MEMCLK);

  memoryinst        : process(MEMCLK, ramwel, ESTATE)
    -- memory construct
    type ramdata is array ( 0 to 131071)
    of std_logic_vector(15 downto 0);
    variable memory : ramdata := (others => X"0000");

  begin
    if ramwell = '0' then
      RAMDQ   <= (others => 'Z');
    else
      if ESTATE = '1' then
        RAMDQ <= (others => '1'); 
      else
                RAMDQ   <= ram_intq;
      end if;

    end if;
    if rising_edge(MEMCLK) then
      ramwel  <= RAMWE;
      ramwell <= ramwel;

      ramaddrl  <= RAMADDR;
      ramaddrll <= ramaddrl;

      if ramwell = '0' then
        memory(TO_INTEGER(unsigned(ramaddrll))) := RAMDQ;
      else
        ram_intq <= memory(TO_INTEGER(unsigned(ramaddrll)));
      end if;

    end if;
  end process memoryinst;

  -- check
  process
  begin
    wait for 100 us;
    ESTATE <= '1';
    wait for 1 us;
    ESTATE <= '0'; 
    wait;


  end process;

  
end Behavioral;
