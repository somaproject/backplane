library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library soma;
use soma.somabackplane.all;
use soma.somabackplane;


library UNISIM;
use UNISIM.VComponents.all;

entity eproctest is

end eproctest;

architecture Behavioral of eproctest is

  component eproc
    port (
      CLK         : in  std_logic;
      RESET       : in  std_logic;
      -- Event Interface, CLK rate
      EDTX        : in  std_logic_vector(7 downto 0);
      EATX        : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE      : in  std_logic;
      -- Event output interface
      EAOUT       : out std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
      EDOUT       : out std_logic_vector(95 downto 0);
      ENEWOUT     : out std_logic;
      -- High-speed interface
      CLKHI       : in  std_logic;
      -- instruction interface
      IADDR       : out std_logic_vector(9 downto 0);
      IDATA       : in  std_logic_vector(17 downto 0);
      --outport signals
      OPORTADDR   : out std_logic_vector(7 downto 0);
      OPORTDATA   : out std_logic_vector(15 downto 0);
      OPORTSTROBE : out std_logic;
      IPORTADDR   : out std_logic_vector(7 downto 0);
      IPORTDATA   : in  std_logic_vector(15 downto 0);
      IPORTSTROBE : out std_logic;
      DEVICE      : in  std_logic_vector(7 downto 0)
      );
  end component;

  signal CLK     : std_logic                                     := '0';
  signal RESET   : std_logic                                     := '1';
  -- Event Interface, CLK rate
  signal EDTX    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EATX    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal ECYCLE  : std_logic                                     := '0';
  signal EARX    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                                 := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)                  := (others => '0');

  signal EAOUT   : std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
  signal EDOUT   : std_logic_vector(95 downto 0);
  signal ENEWOUT : std_logic;

  -- High-speed interface
  signal CLKHI       : std_logic                     := '0';
  -- instruction interface
  signal IADDR       : std_logic_vector(9 downto 0)  := (others => '0');
  signal IDATA       : std_logic_vector(17 downto 0) := (others => '0');
  --outport signals
  signal OPORTADDR   : std_logic_vector(7 downto 0)  := (others => '0');
  signal OPORTDATA   : std_logic_vector(15 downto 0) := (others => '0');
  signal OPORTSTROBE : std_logic                     := '0';

  --inport signals
  signal IPORTADDR   : std_logic_vector(7 downto 0)  := (others => '0');
  signal IPORTDATA   : std_logic_vector(15 downto 0) := (others => '0');
  signal IPORTSTROBE : std_logic                     := '0';

  signal clkstate : integer   := 0;
  signal mainclk  : std_logic := '0';

  ---------------------------------------------------------------------------
  -- DEBUG
  ---------------------------------------------------------------------------

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal pos : integer range 0 to 999 := 0;

  constant DEVICE : std_logic_vector(7 downto 0) := X"27";


  component IRAM
    generic (
      filename :     string);
    port (
      CLK      : in  std_logic;
      ADDR     : in  std_logic_vector(9 downto 0);
      DATA     : out std_logic_vector(17 downto 0));
  end component;

  component txeventbuffer
    port (
      CLK      : in  std_logic;
      EVENTIN  : in  std_logic_vector(95 downto 0);
      EADDRIN  : in  std_logic_vector(somabackplane.N -1 downto 0);
      NEWEVENT : in  std_logic;
      ECYCLE   : in  std_logic;
      -- outputs
      EDRX     : out std_logic_vector(7 downto 0);
      EDRXSEL  : in  std_logic_vector(3 downto 0);
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
  end component;


begin  -- Behavioral

  eproc_uut : eproc
    port map (
      CLK         => CLK,
      RESET       => RESET,
      EDTX        => EDTX,
      EATX        => EATX,
      ECYCLE      => ECYCLE,
      EAOUT       => EAOUT,
      EDOUT       => EDOUT,
      ENEWOUT     => ENEWOUT,
      CLKHI       => CLKHI,
      IADDR       => IADDR,
      IDATA       => IDATA,
      OPORTADDR   => OPORTADDR,
      OPORTDATA   => OPORTDATA,
      OPORTSTROBE => OPORTSTROBE,
      IPORTADDR   => IPORTADDR,
      IPORTDATA   => IPORTDATA,
      IPORTSTROBE => IPORTSTROBE,
      DEVICE      => DEVICE);

  txeventbuffer_inst : txeventbuffer
    port map (
      CLK      => CLKHI,
      EVENTIN  => EDOUT,
      EADDRIN  => EAOUT,
      NEWEVENT => ENEWOUT,
      ECYCLe   => ECYCLE,
      EDRX     => EDRX,
      EDRXSEL  => EDSELRX,
      EARX     => EARX);

  mainclk <= not mainclk after 2.5 ns;
  reset   <= '0'         after 100 ns;

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkstate = 3 then
        clkstate <= 0;
      else
        clkstate <= clkstate + 1;
      end if;

      if clkstate = 0 or clkstate = 2 then
        CLKHI <= '0';
      else
        CLKHI <= '1';
      end if;

      if clkstate = 1 then
        CLK <= '0';
      elsif clkstate = 3 then
        CLK <= '1';
      end if;
    end if;
  end process;

  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;

  event_packet_generation : process
  begin
    while true loop
      wait until rising_edge(CLK) and pos = 47;
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


  IRAM_inst : iram
    generic map (
      filename => "loadtest.iram")
    port map (
      CLK      => CLKHI,
      ADDR     => IADDR,
      DATA     => IDATA);


  process
  begin
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= X"0123";
    eventinputs(0)(1) <= X"4567";
    eventinputs(0)(2) <= X"89AB";
    eventinputs(0)(3) <= X"CDEF";
    eventinputs(0)(4) <= X"1122";
    eventinputs(0)(5) <= X"3344";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '0';
    wait until rising_edge(CLK) and ECYCLE = '1';
    -- now verify we got the handle!
    wait;
  end process;

  -----------------------------------------------------------------------------
  -- CountVal events
  -----------------------------------------------------------------------------
  countval_proc                 : process(CLK, CLKHI)
    variable mostRecentCountVal : std_logic_vector(15 downto 0) := (others => '0');

  begin
    -- event transmission, every ecycle
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        EATX(1)           <= '1';
        eventinputs(1)(0) <= X"0000";
        eventinputs(1)(1) <= mostRecentCountVal;
        mostRecentCountVal := mostRecentCountVal +1;
      end if;
    end if;

    -- now the verification
    if rising_edge(CLKHI) then
      if oportstrobe = '1' and oportaddr = X"01" then
        if mostRecentCountVal > 2 then
          assert oportdata = (mostRecentCountVal - 2)
            report "Incorrect CountVal, expecting "
            & integer'image(to_integer(unsigned(mostRecentCountVal - 2))) &
            "but got " &
            integer'image(to_integer(unsigned(oportdata))) severity error;
        end if;

      end if;
    end if;

  end process countval_proc;

  -----------------------------------------------------------------------------
  -- total0 counter events
  -- uses src 30 through 39
  --
  -----------------------------------------------------------------------------
  total0_proc           : process(CLK, CLKHI)
    variable total0     : integer := 0;
    variable t0src      : integer := 30;
    variable cmd        : integer := 16;
    variable lastdelta  : integer := 100;
    variable sum0, sum1 : integer := 0;
  begin
    -- event transmission, every ecycle
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        if cmd < 31 then
          cmd                     := cmd + 1;
        else
          cmd                     := 16;
        end if;

        if t0src < 39 then
          t0src := t0src + 1;
        else
          t0src := 30;
        end if;

        -- T0 event
        lastdelta := lastdelta + 1;
        EATX(30)                        <= '1';
        eventinputs(30)(0)(15 downto 8) <= std_logic_vector(TO_UNSIGNED(cmd, 8));
        eventinputs(30)(0)(7 downto 0)  <= std_logic_vector(TO_UNSIGNED(t0src, 8));
        eventinputs(30)(1)              <= std_logic_vector(TO_UNSIGNED(lastdelta, 16));
        sum1      := sum0;
        sum0      := (sum0 + lastdelta) mod 2**16;

      end if;
    end if;

    -- now the verification
    if rising_edge(CLKHI) then
      if oportstrobe = '1' and oportaddr = X"02" then
        if lastdelta > 102 then
          assert oportdata = std_logic_vector(to_unsigned(sum1, 16))
            report "Incorrect CountVal, expecting "
            & integer'image(sum1) &
            "but got " &
            integer'image(to_integer(unsigned(oportdata))) severity error;
        end if;

      end if;
    end if;

  end process total0_proc;

  -----------------------------------------------------------------------------
  -- Initial event tx receive
  -----------------------------------------------------------------------------
  first_event_proc     : process
    variable state     : integer := 00;
    variable iteration : integer := 0;
  begin
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    if earx(7) = '1' then

      if state = 0 then
        EDSELRX <= "0000";
        wait until rising_edge(CLK);
        if EDRX = X"05" then
          state := 1;
        end if;

      elsif state = 1 then
        wait until rising_edge(CLK);
        EDSELRX <= "0000";
        wait until rising_edge(CLK);
        if EDRX = X"06" then
          state := 2;
        end if;

        EDSELRX <= "0010";
        wait until rising_edge(CLK);
        if EDRX = X"AA" and state = 2 then
          state := 3;
        end if;

        EDSELRX <= "0011";
        wait until rising_edge(CLK);
        if EDRX = X"BB" and state = 3 then
          state := 4;
        end if;

        EDSELRX <= "0100";
        wait until rising_edge(CLK);
        if EDRX = X"CC" and state = 4 then
          state := 5;
        end if;

        EDSELRX <= "0101";
        wait until rising_edge(CLK);
        if EDRX = X"DD" and state = 5 then
          state := 6;
        end if;


      end if;

      if state = 6 then
        report "Successful RX of init events" severity note;
        report "End of Simulation" severity failure;
      end if;
    end if;

  end process first_event_proc;


  -- input port test
  process(clkhi)
  begin
    if rising_edge(clkhi) then
      if IPORTADDR = X"10" and IPORTSTROBE = '1' then
        IPORTDATA <= X"1234";
      elsif IPORTADDR = X"11" and IPORTSTROBE = '1' then
        IPORTDATA <= X"5678";
      elsif IPORTSTROBE = '1' then
        IPORTDATA <= (others => '0');
      end if;
    end if;

  end process;

--  -----------------------------------------------------------------------------
--   -- ECHO event
--   -----------------------------------------------------------------------------
--   echo_event_proc : process

-- variable iteration : integer := 0;
-- begin
-- wait until rising_edge(CLK) and ECYCLE = '1';
-- EATX(60) <= '1';
-- eventinputs(60)(0)(15 downto 8) <= std_logic_vector(TO_UNSIGNED(128, 8));
-- eventinputs(60)(0)(7 downto 0) <= std_logic_vector(TO_UNSIGNED(60, 8));
-- eventinputs(60)(1) <= X"0123";
-- eventinputs(60)(2) <= X"4567";
-- eventinputs(60)(3) <= X"89AB";
-- eventinputs(60)(4) <= X"CDEF";
-- eventinputs(60)(5) <= std_logic_vector(TO_UNSIGNED(iteration, 16));

-- wait until rising_edge(CLK) and ECYCLE = '1';
-- EATX(60) <= '0';
-- wait until rising_edge(CLK) and EARX(60) = '1';
-- EDSELRX <= "0010";
-- wait until rising_edge(CLK);
-- assert EDRX = X"01" report "Error receiving echo Data1[15:8]" severity Error;
-- :

-- report "Received Event" severity note;
-- wait until rising_edge(CLK) and ECYCLE = '1';

-- end process echo_event_proc;


end Behavioral;
