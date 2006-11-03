library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
use WORK.somabackplane.all;
use Work.somabackplane;


entity datavalidate is
  port (
    CLK       : in  std_logic;
    DIN       : in  std_logic_vector(15 downto 0);
    NEWFRAME  : in  std_logic;
    NOMATCH   : out std_logic := '0';
    DATAERROR : out std_logic := '0';
    DATADONE  : out std_logic := '0');
end datavalidate;


architecture Behavioral of datavalidate is
-- we receive entire packets and then check them and bail if they're nto valid

  signal newframel : std_logic := '0';

  type dpacket is array (0 to 1023) of std_logic_vector(15 downto 0);

  signal datapacket : dpacket := (others => (others => '0'));

  signal datacheck : std_logic_vector(0 to 1023) := (others => '0');

  signal pktvalid, pktvalidl : std_logic := '0';
  signal pktlen   : integer   := 0;

  signal pkterror : std_logic := '0';

  signal pos : integer := 0;

begin  -- Behavioral

  process(CLK)
  begin
    if rising_edge(CLK) then
      newframel <= NEWFRAME;
      if NEWFRAME = '0' then
        pos     <= 0;
      else
        if newframel = '0' and NEWFRAME = '1' then
          pos   <= 1;
        else
          pos   <= pos + 1;
        end if;
      end if;
    end if;
  end process;

  -- network output verify
  databus_tx_verify   : process
    file datafile     : text;
    variable L        : line;
    variable len      : integer                       := 0;
    variable id       : std_logic_vector(31 downto 0) := (others => '0');
    variable src, typ : integer                       := 0;
    variable pos      : integer                              := 0;
    variable wordin : std_logic_vector(15 downto 0) := (others => '0');
    

  begin
    file_open(datafile, "data.txt");
    while not endfile(datafile) loop
      pos := 0;
      readline(datafile, L);
      read(L, len);
      hread(L, id);
      read(L, src);
      read(L, typ);

      datacheck(0)       <= '1';
      datapacket(0)      <= std_logic_vector(TO_UNSIGNED(len*2 + 20 + 14 + 2 + 8 + 6, 16));
      datacheck(1 to 3)  <= (others => '1');
      datapacket(1 to 3) <= (others => X"FFFF");

      -- udp check
      datacheck(19)  <= '1';
      datapacket(19) <= std_logic_vector(TO_UNSIGNED(4000 + typ * 64 + src, 16));
      for i  in 0 to len + 3 -1 loop
        hread(L, wordin); 
        datacheck(22 +i) <= '1';
        datapacket(22 + i) <= wordin; 
      end loop;  -- i

      for i in 22+len+3 to 1023 loop
        datacheck(i) <= '0'; 
      end loop;  -- i
      
      wait until falling_edge(newframel) and (pktvalidl= '1'); 


    end loop;
  end process databus_tx_verify;

  packet_validate : process(CLK)
  begin
    if rising_edge(CLK) then
      if NEWFRAME = '1' then
        if datacheck(pos) = '1' then
          if datapacket(pos) /= DIN then
            pkterror <= '1';
          else
            pkterror <= '0';
          end if;
        else
          pkterror   <= '0';
        end if;
      end if;
    end if;
  end process packet_validate;

  packet_validate_check : process(NEWFRAME, CLK)
  begin
    if rising_edge(NEWFRAME) then
      pktvalid    <= '1';
    elsif rising_edge(CLK) then
      if pkterror = '1' then
        pktvalid  <= '0';
      end if;
    elsif falling_edge(newframe) then
      if pktvalid = '1' then
        pktvalidl <= '1';
      else
        pktvalidl <= '0';
      end if;

    end if;

  end process packet_validate_check;
end Behavioral;
