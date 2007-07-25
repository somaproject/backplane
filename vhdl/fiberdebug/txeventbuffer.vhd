library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity txeventbuffer is
  port (
    CLK      : in  std_logic;
    EVENTIN  : in  std_logic_vector(95 downto 0);
    EADDRIN  : in  std_logic_vector(somabackplane.N -1 downto 0);
    NEWEVENT : in  std_logic;
    ECYCLE : in std_logic;
    -- outputs
    EDRX     : out std_logic_vector(7 downto 0);
    EDRXSEL  : in std_logic_vector(3 downto 0);
    EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
end txeventbuffer;

architecture Behavioral of txeventbuffer is
  
  -- counters
  signal cnt           : std_logic_vector(3 downto 0) := (others => '1');

  signal empty, dec : std_logic := '0';
  
  signal eventout, eol : std_logic_vector(95 downto 0) := (others => '0');
  signal eaddrout, eal : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  
begin  -- Behavioral

  eventbuffer: for i in 0 to 95 generate
    eventbuf_srl16e: SRL16E
      port map (Q => eventout(i),
                A0 => cnt(0),
                A1 => cnt(1),
                A2 => cnt(2),
                A3 => cnt(3),
                CE => NEWEVENT,
                CLK => CLK,
                D => EVENTIN(i));
  end generate eventbuffer;

  eaddrbuffer: for i in 0 to somabackplane.N-1 generate
    eaddrbuf_srl16e: SRL16E
      port map (Q => eaddrout(i),
                A0 => cnt(0),
                A1 => cnt(1),
                A2 => cnt(2),
                A3 => cnt(3),
                CE => NEWEVENT,
                CLK => CLK,
                D => EADDRIN(i));

    EARX(i) <= eal(i) and nel; 
  end generate eaddrbuffer;

  empty <= '1' when cnt = "1111" else '0';

  dec <= (not empty) and ECYCLE;
  
  main: process(CLK)
    begin
      if rising_edge(CLK) then

        if ECYCLE = '1' then
          eol <= eventout;
          eal <= eaddrout;
          nel <= not empty; 
        end if;

        if newevent = '1' and dec = '0' then
          cnt <= cnt + 1;
        elsif newevent = '0' and dec = '1' then
          cnt <= cnt - 1;
        end if;
        
      end if;
    end process main; 
   

end Behavioral;
