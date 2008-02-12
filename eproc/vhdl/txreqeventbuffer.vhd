library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

library SOMA;
use SOMA.somabackplane.all;
use soma.somabackplane;


entity txreqeventbuffer is
  port (
    CLK       : in  std_logic;
    EVENTIN   : in  std_logic_vector(95 downto 0);
    EADDRIN   : in  std_logic_vector(somabackplane.N -1 downto 0);
    NEWEVENT  : in  std_logic;
    ECYCLE    : in  std_logic;
    -- outputs
    SENDREQ   : out std_logic;
    SENDGRANT : in  std_logic;
    SENDDONE  : out std_logic;
    DOUT      : out std_logic_vector(7 downto 0));
end txreqeventbuffer;

architecture Behavioral of txreqeventbuffer is

  -- counters
  signal cnt : std_logic_vector(3 downto 0) := (others => '1');

  signal empty, dec : std_logic := '0';

  signal eventout, eol : std_logic_vector(95 downto 0)                 := (others => '0');
  signal eaddrout, eal : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal nel : std_logic := '0';

  signal outbytecnt : integer range 0 to 22 := 0;

  signal currentlysending : std_logic := '0';
  

begin  -- Behavioral

  eventbuffer       : for i in 0 to 95 generate
    eventbuf_srl16e : SRL16E
      port map (Q   => eventout(i),
                A0  => cnt(0),
                A1  => cnt(1),
                A2  => cnt(2),
                A3  => cnt(3),
                CE  => NEWEVENT,
                CLK => CLK,
                D   => EVENTIN(i));
  end generate eventbuffer;

  eaddrbuffer       : for i in 0 to somabackplane.N-1 generate
    eaddrbuf_srl16e : SRL16E
      port map (Q   => eaddrout(i),
                A0  => cnt(0),
                A1  => cnt(1),
                A2  => cnt(2),
                A3  => cnt(3),
                CE  => NEWEVENT,
                CLK => CLK,
                D   => EADDRIN(i));

  end generate eaddrbuffer;

  empty   <= '1' when cnt = "1111" else '0';
  SENDREQ <= not empty;

  dec <= '1' when outbytecnt = 21 else '0';
  
  DOUT <= eaddrout(7 downto 0)   when outbytecnt = 00 else
          eaddrout(15 downto 8)  when outbytecnt = 01 else
          eaddrout(23 downto 16) when outbytecnt = 02 else
          eaddrout(31 downto 24) when outbytecnt = 03 else
          eaddrout(39 downto 32) when outbytecnt = 04 else
          eaddrout(47 downto 40) when outbytecnt = 05 else
          eaddrout(55 downto 48) when outbytecnt = 06 else
          eaddrout(63 downto 56) when outbytecnt = 07 else
          eaddrout(71 downto 64) when outbytecnt = 08 else
          "00" & eaddrout(77 downto 72) when outbytecnt = 09 else
          eventout(7 downto 0)   when outbytecnt = 10 else
          eventout(15 downto 8)  when outbytecnt = 11 else
          eventout(23 downto 16) when outbytecnt = 12 else
          eventout(31 downto 24) when outbytecnt = 13 else
          eventout(39 downto 32) when outbytecnt = 14 else
          eventout(47 downto 40) when outbytecnt = 15 else
          eventout(55 downto 48) when outbytecnt = 16 else
          eventout(63 downto 56) when outbytecnt = 17 else
          eventout(71 downto 64) when outbytecnt = 18 else
          eventout(79 downto 72) when outbytecnt = 19 else
          eventout(87 downto 80) when outbytecnt = 20 else
          eventout(95 downto 88);
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      if newevent = '1' and dec = '0' then
        cnt <= cnt + 1;
      elsif newevent = '0' and dec = '1' then
        cnt <= cnt - 1;
      end if;

      if SENDGRANT = '1' then
        currentlysending <= '1';
      else
        if outbytecnt = 21 then
          currentlysending <= '0'; 
        end if;
      end if;

      if SENDGRANT = '1'  then
        outbytecnt <= 0;
      else
        if currentlysending = '1' then
          outbytecnt <= outbytecnt + 1;
        end if;
      end if;

      if outbytecnt = 20 then
        SENDDONE <= '1';
      else
        SENDDONE <= '0'; 
      end if;
        
    end if;
  end process main;


end Behavioral;
