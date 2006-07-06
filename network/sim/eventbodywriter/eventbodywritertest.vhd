library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
use WORK.somabackplane;


entity eventbodywritertest is

end eventbodywritertest;

architecture Behavioral of eventbodywritertest is

  component eventbodywriter
    port (
      CLK    : in  std_logic;
      ECYCLE : in  std_logic;
      EDTX   : in  std_logic_vector(7 downto 0);
      EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
      DOUT   : out std_logic_vector(15 downto 0);
      WEOUT  : out std_logic;
      ADDR   : out std_logic_vector(8 downto 0);
      DONE   : out std_logic);
  end component;


  signal CLK    : std_logic := '0';
  signal ECYCLE : std_logic := '0';

  signal EDTX : std_logic_vector(7 downto 0)  := (others => '0');
  signal EATX : std_logic_vector(somabackplane.N-1 downto 0)
                                              := (others => '0');
  signal DOUT : std_logic_vector(15 downto 0) := (others => '0');

  signal WEOUT : std_logic                    := '0';
  signal ADDR  : std_logic_vector(8 downto 0) := (others => '0');
  signal DONE  : std_logic                    := '0';

-- simulated eventbus
  signal epos : integer := 0;
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;



  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal bootaddr : std_logic_vector(15 downto 0) := (others => '0');
  signal bootlen  : std_logic_vector(15 downto 0) := (others => '0');


  -- simulated ram

begin  -- Behavioral

  eventbodywriter_uut : eventbodywriter
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      EDTX   => EDTX,
      EATX   => EATX,
      DOUT   => DOUT,
      WEOUT  => WEOUT,
      ADDR   => ADDR,
      DONE   => DONE);


  -- basic clocking
  CLK <= not CLK after 10 ns;

  -- ecycle generation
  ecycle_gen : process(CLK)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        epos <= 0;
      else
        epos <= epos + 1;
      end if;

      if epos = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process;


  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and epos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;

  ramwriter           : process(CLK)
    type eventram_t is array(1023 downto 0) of
    std_logic_vector(15 downto 0);
    variable eventram : eventram_t := (others => (others => '0'));


  begin
    if rising_edge(CLK) then
      if WEOUT = '1' then
        eventram(to_integer(unsigned(ADDR))) := DOUT;
      end if;

    end if;

  end process ramwriter;
  main : process

  begin

    wait until rising_edge(CLK) and ECYCLE = '1';

    eventinputs(0)(0) <= (others => '1');
    EATX(0)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;

    wait until rising_edge(CLK) and ECYCLE = '1';
    eventinputs(0)(0) <= X"0123";
    eventinputs(0)(1) <= X"4567";
    eventinputs(0)(2) <= X"89AB";
    eventinputs(0)(3) <= X"CDEF";
    eventinputs(0)(4) <= X"1357";
    eventinputs(0)(5) <= X"9bdf";
    EATX(0)           <= '1';

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX <= eazeros;




    wait;


  end process main;

end Behavioral;
