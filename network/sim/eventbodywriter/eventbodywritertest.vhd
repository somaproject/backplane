library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
library soma;
use soma.somabackplane;


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
  signal ramaddr : integer range 0 to 2047 := 0;
  signal ramdata : std_logic_vector(15 downto 0);

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

  ramwriter           : process(CLK, ramaddr)
    type eventram_t is array(2047 downto 0) of
    std_logic_vector(15 downto 0);
    variable eventram : eventram_t := (others => (others => '0'));

  begin
    if rising_edge(CLK) then
      if WEOUT = '1' then
        eventram(to_integer(unsigned(ADDR))) := DOUT;
      end if;
    end if;
    ramdata <= eventram(ramaddr);

  end process ramwriter;


  main : process
  begin

    wait until rising_edge(CLK) and ECYCLE = '1';

    eventinputs(0)(0) <= (others => '1');
    EATX(0)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;


    ---------------------------------------------------------------------------
    -- Basic input event
    ---------------------------------------------------------------------------


    wait until rising_edge(CLK) and ECYCLE = '1';
    eventinputs(0)(0) <= X"0123";
    eventinputs(0)(1) <= X"4567";
    eventinputs(0)(2) <= X"89AB";
    eventinputs(0)(3) <= X"CDEF";
    eventinputs(0)(4) <= X"1357";
    eventinputs(0)(5) <= X"9bdf";
    EATX(0)           <= '1';

    wait until rising_edge(CLK) and ECYCLE = '1';

    -- verification
    ramaddr <= 0;
    wait for 1 ns;
    assert ramdata = X"0001" report "Error writing length" severity error;

    ramaddr <= 1;
    wait for 1 ns;
    assert ramdata = X"0123" report "Error reading data" severity error;

    ramaddr <= 2;
    wait for 1 ns;
    assert ramdata = X"4567" report "Error reading data" severity error;

    ramaddr <= 3;
    wait for 1 ns;
    assert ramdata = X"89ab" report "Error reading data" severity error;

    ramaddr <= 4;
    wait for 1 ns;
    assert ramdata = X"cdef" report "Error reading data" severity error;

    ramaddr <= 5;
    wait for 1 ns;
    assert ramdata = X"1357" report "Error reading data" severity error;

    ramaddr <= 6;
    wait for 1 ns;
    assert ramdata = X"9bdf" report "Error reading data" severity error;

    wait for 3 us;
    --assert addr'stable(3 us) report "ADDR changed" severity error;
    
    EATX <= eazeros;

    ---------------------------------------------------------------------------
    -- Complex multi-device event
    ---------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    for i in 0 to 31 loop
      eventinputs(i)(0) <= std_logic_vector(to_unsigned(i, 8)) & X"00";
      eventinputs(i)(1) <= std_logic_vector(to_unsigned(i, 8)) & X"01";
      eventinputs(i)(2) <= std_logic_vector(to_unsigned(i, 8)) & X"02";
      eventinputs(i)(3) <= std_logic_vector(to_unsigned(i, 8)) & X"03";
      eventinputs(i)(4) <= std_logic_vector(to_unsigned(i, 8)) & X"04";
      eventinputs(i)(5) <= std_logic_vector(to_unsigned(i, 8)) & X"05";
      EATX(i)           <= '1';
    end loop;  -- i 

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX    <= eazeros;
    -- verification
    ramaddr <= 0;
    wait for 1 ns;
    assert ramdata = X"0020" report "Error writing length" severity error;

    -- verify events
    for i in 0 to 31 loop
      for j in 0 to 5 loop
        ramaddr <= i * 6 + j + 1;
        wait for 1 ns;
        assert ramdata = ( std_logic_vector(to_unsigned(i, 8))
                           & std_logic_vector(to_unsigned(j, 8)))
          report "Error in event data" severity error;

      end loop;  -- j

    end loop;  -- i 

    assert False report "End of Simulation" severity Failure;

    wait;


  end process main;

end Behavioral;
