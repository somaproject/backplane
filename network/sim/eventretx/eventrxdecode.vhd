library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;


entity eventrxdecode is

  port (
    CLK         : in  std_logic;
    NICNEWFRAME : in  std_logic;
    NICDINEN    : in  std_logic;
    NICDIN      : in  std_logic_vector(15 downto 0);
    RXIDEN      : out std_logic;
    RXID        : out std_logic_vector(31 downto 0);
    RXTSEN      : out std_logic;
    RXTS        : out std_logic_vector(47 downto 0)
    );

end eventrxdecode;

architecture Behavioral of eventrxdecode is

  type packetbuff_t is array (0 to 799) of std_logic_vector(15 downto 0);
  signal packetbuff : packetbuff_t;
  signal packetpos  : integer := 0;
  signal maybegood  : integer := 0;

begin  -- Behavioral
  process
  begin
    while true loop


      -- we re%ad the entire packet and _then_ do all the processing on it
      packetpos             <= 0;
      maybegood             <= 1;
      wait until rising_edge(CLK) and NICNEWFRAME = '1';
      packetbuff(packetpos) <= NICDIN;
      packetpos             <= packetpos + 1;

      acqloop : while packetpos < 799 loop
        wait until rising_edge(CLK);
        if NICNEWFRAME = '1' then
          packetbuff(packetpos) <= NICDIN;

          packetpos <= packetpos + 1;
        else
          exit acqloop;
        end if;

      end loop;

      -- we have the packet, now verify:
      if packetbuff(1) = X"FFFF" and
        packetbuff(2) = X"FFFF" and
        packetbuff(3) = X"FFFF"
      then
        -- correct dest addr

      else
        maybegood <= 0;
      end if;

      if to_integer(unsigned(packetbuff(19))) = 5000 then
        -- correct dest port
      else
        maybegood <= 0;
      end if;

      if maybegood > 0 then
        -- did the above criteria hold? if so, it's an event packet; let's
        -- extract out the relevant data
        RXID(31 downto 16) <= packetbuff(22);
        RXID(15 downto 0)  <= packetbuff(23);

        -- extract out first set's timestamp
        RXTS(47 downto 32) <= packetbuff(26);
        RXTS(31 downto 16) <= packetbuff(27);
        RXTS(15 downto 0)  <= packetbuff(28);
        
        
      end if;
    end loop;
  end process;


end Behavioral;
