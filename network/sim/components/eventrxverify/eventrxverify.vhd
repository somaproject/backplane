library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;



entity eventrxverify is
  generic (
    EVENTFILENAME : in  string);
  port (
    CLK           : in  std_logic;
    ECYCLE        : in  std_logic;
    EARX          : in  std_logic_vector(79 downto 0);
    EDRX          : in  std_logic_vector(7 downto 0);
    EDRXSEL       : out std_logic_vector(3 downto 0);
    RESET         : in  std_logic;
    -- invalidate interface
    INVNUM        : in  integer;
    INVCLK        : in  std_logic;

    -- output status
    EVTERROR    : out std_logic;
    EVENTPOSOUT : out integer
    );

end eventrxverify;


architecture Behavioral of eventrxverify is

  constant BUFSIZE : integer := 2048;

  type event is record
                  valid : boolean;
                  edata : std_logic_vector(95 downto 0);
                  eaddr : std_logic_vector(79 downto 0);
                end record;

  type event_array_type is array (0 to BUFSIZE - 1) of event;

  signal ecyclepos : integer := 0;

  signal eaddrbus, eaddrbus_expected : std_logic_vector(79 downto 0) := (others => '0');

  signal edatabus, edatabus_expected : std_logic_vector(95 downto 0) :=
    (others => '0');
  --signal eventpos : integer                       := 0;

begin  -- Behavioral
  --EVENTPOSOUT <= eventpos;


  event_acquire       : process
    variable edatapos : integer := 0;

  begin
    while true loop

      wait until rising_edge(CLK);
      if ecyclepos = 10 then
        eaddrbus                      <= EARX;
        for i in 0 to 11 loop
          EDRXSEL                     <= std_logic_vector(TO_UNSIGNED(i, 4));
          wait for 0.01 us;
          edatabus(8*i +7 downto 8*i) <= EDRX;
          wait until rising_edge(CLK);
        end loop;
      end if;
    end loop;

  end process;

  position_counter : process(CLK)
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        ecyclepos <= 0;
      else
        ecyclepos <= ecyclepos + 1;
      end if;
    end if;
  end process position_counter;



  process(RESET, CLK, INVCLK)
    file event_file : text;
    variable L      : line;
    variable addrin : std_logic_vector(79 downto 0) := (others => '0');
    variable datain : std_logic_vector(95 downto 0) := (others => '0');

    variable eventarray : event_array_type;
    variable eventpos   : integer := 0;

  begin
    if falling_edge(RESET) then
      file_open(event_file, EVENTFILENAME, read_mode);
      eventpos := 0;

      while not endfile(event_file) loop
        readline(event_file, L);
        hread(L, addrin);
        hread(L, datain);
        eventarray(eventpos).valid := true;
        -- annoying byte swaps
        for i in 0 to 4 loop
          eventarray(eventpos).eaddr(16*i + 15 downto 16*i)
                                   := addrin(i*16 + 7 downto i* 16 )
            & addrin(i*16 + 15 downto i*16 + 8);
        end loop;  -- i
        -- 
        for i in 0 to 5 loop
          eventarray(eventpos).edata(16*i + 15 downto 16*i)
                                   := datain(i*16 + 7 downto i* 16 )
            & datain(i*16 + 15 downto i*16 + 8);
        end loop;  -- i 

        eventpos                   := eventpos + 1;
      end loop;

      -- clear the remaining ones
      for i in eventpos to BUFSIZE - 1 loop
        eventarray(i).valid := false;
      end loop;  -- i

      file_close(event_file);

      -- reset the pointer
      eventpos     := 0;
    elsif rising_edge(CLK) then
      if ecyclepos = 48 then
        while not eventarray(eventpos).valid and eventpos < BUFSIZE -1 loop
          eventpos := eventpos + 1;
        end loop;
      end if;

      if ecyclepos = 49 then
        eaddrbus_expected(77 downto 0) <=
          eventarray(eventpos).eaddr(77 downto 0);
        edatabus_expected <= eventarray(eventpos).edata; 
      end if;

      if ecyclepos = 50 then            -- wait for some time to stabilize 

        -- first, find a valid event

        if eaddrbus /= X"0000000000" then  --heck if this is a null event:

          assert eaddrbus(77 downto 0) = eaddrbus_expected(77 downto 0)
            report "Error in event address" severity error;

          assert edatabus = edatabus_expected
            report "Error reading event bytes" severity error;

          eventpos := eventpos + 1;
        end if;
      end if;

    end if;

    if rising_edge(INVCLK) then
      eventarray(INVNUM).valid := false;
    end if;


  end process;


end Behavioral;
