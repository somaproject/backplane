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
    -- outputs
    EDRX     : out std_logic_vector(7 downto 0);
    EDRXSEL  : out std_logic_vector(2 downto 0);
    EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
end txeventbuffer;

architecture Behavioral of txeventbuffer is
  
  -- counters
  signal incnt           : std_logic_vector(3 downto 0) := (others => '0');
  signal outcnt, outcntl : std_logic_vector(3 downto 0) := (others => '0');
  signal outenl          : std_logic                    := '0';

  signal eventout : std_logic_vector(95 downto 0) := (others => '0');
  signal eaddrout : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  
begin  -- Behavioral

  eventbuffer: for i in 0 to 95 generate
    eventbuf_srl16e: SRL16E
      port map (Q => eventout(i),
                A0 => outcntl(0),
                A1 => outcntl(1),
                A2 => outcntl(2),
                A3 => outcntl(3),
                CE => NEWEVENT,
                CLK => CLK,
                D => EVENTIN(i));
  end generate eventbuffer;

  eaddrbuffer: for i in 0 to somabackplane.N-1 generate
    eaddrbuf_srl16e: SRL16E
      port map (Q => eaddrout(i),
                A0 => outcntl(0),
                A1 => outcntl(1),
                A2 => outcntl(2),
                A3 => outcntl(3),
                CE => NEWEVENT,
                CLK => CLK,
                D => EADDRIN(i));

    EARX(i) <= eaddrout(i) and outenl; 
  end generate eaddrbuffer;

  outen <= '1' when outcnt != incnt else '0';
  
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        if NEWEVENT = '1' then
          incnt <= incnt + 1; 
        end if;

        if ecycle = '1' and outen = '1' then
          outcnt <= outcnt + 1; 
        end if;

        if ECYCLE = '1' then
          outenl <= outen;
        end if;

        if ECYCLE = '1' and outen = '1'  then
          outcntl <= outcnt; 
        end if;

        
      end if;
    end process main; 
   

end Behavioral;
