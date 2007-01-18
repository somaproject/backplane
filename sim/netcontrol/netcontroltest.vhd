library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity netcontroltest is

end netcontroltest;

architecture Behavioral of netcontroltest is

  component netcontrol
    generic (
      DEVICE      :     std_logic_vector(7 downto 0) := X"01";
      CMDCNTQUERY :     std_logic_vector(7 downto 0) := X"40";
      CMDCNTRST   :     std_logic_vector(7 downto 0) := X"41";
      CMDNETWRITE :     std_logic_vector(7 downto 0) := X"42";
      CMDNETQUERY :     std_logic_vector(7 downto 0) := X"43"
      );
    port (
      CLK         : in  std_logic;
      RESET       : in  std_logic;
      -- standard event-bus interface
      ECYCLE      : in  std_logic;
      EARX        : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX        : out std_logic_vector(7 downto 0);
      EDSELRX     : in  std_logic_vector(3 downto 0);
      EDTX        : in  std_logic_vector(7 downto 0);
      EATX        : in  std_logic_vector(somabackplane.N - 1 downto 0);
      -- tx counter inputdtx
      TXPKTLENEN  : in  std_logic;
      TXPKTLEN    : in  std_logic_vector(15 downto 0);
      TXCHAN      : in  std_logic_vector(2 downto 0);
      -- other counters
      RXIOCRCERR  : in  std_logic;
      -- output network control settings
      MYMAC       : out std_logic_vector(47 downto 0);
      MYBCAST     : out std_logic_vector(31 downto 0);
      MYIP        : out std_logic_vector(31 downto 0)

      );

  end component;

  signal CLK    : std_logic := '0';
  signal RESET  : std_logic := '1';
  signal ECYCLE : std_logic := '0';


  signal EARX : std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0)  := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)  := (others => '0');
  signal EOUTD   : std_logic_vector(15 downto 0) := (others => '0');
  signal EOUTA   : std_logic_vector(2 downto 0)  := (others => '0');

  signal EVALID : std_logic := '0';
  signal ENEXT  : std_logic := '0';

  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDTX : std_logic_vector(7 downto 0)                  := (others => '0');

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');


  signal TXPKTLENEN : std_logic                     := '0';
  signal TXPKTLEN   : std_logic_vector(15 downto 0) := (others => '0');
  signal TXCHAN     : std_logic_vector(2 downto 0)  := (others => '0');
  -- other counters
  signal RXIOCRCERR : std_logic                     := '0';
  -- output network control settings
  signal MYMAC      : std_logic_vector(47 downto 0);
  signal MYBCAST    : std_logic_vector(31 downto 0);
  signal MYIP       : std_logic_vector(31 downto 0);


  signal pos : integer range 0 to 999 := 980;


  type settings is (none, noop, noopdone,
                    writemac, writemacdone,
                    writeip, writeipdone,
                    writebcast, writebcastdone);

  signal state : settings := none;

begin  -- Behavioral

  CLK   <= not clk after 10 ns;
  RESET <= '0'     after 100 ns;

  netcontrol_uut : netcontrol
    generic map (
      DEVICE     => x"01")
    port map (
      CLK        => CLK,
      RESET      => RESET,
      ECYCLE     => ECYCLE,
      EARx       => EARX,
      EDRX       => EDRX,
      EDSELRX    => EDSELRX,
      EDTX       => EDTX,
      EATX       => EATX,
      TXPKTLENEN => TXPKTLENEN,
      TXPKTLEN   => TXPKTLEN,
      TXCHAN     => TXCHAN,
      RXIOCRCERR => RXIOCRCERR,
      MYMAC      => MYMAC,
      MYBCAST    => MYBCAST,
      MYIP       => MYIP);





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



  main : process
    --generate the commands, read the outputs
    --
  begin
    -- first, we send no-op and make sure we have no reaction
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= noop;

    eventinputs(0)(0) <= (others => '1');
    EATX              <= (others => '1');
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;


    -- now, verify they don't do anything

    wait until rising_edge(CLK) and ECYCLE = '1';
    assert EARX'stable(20 us) report "EARX registered an event" severity
      error;
    state <= noopdone;

    -- now send a "write MAC address" event
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= writemac;
    eventinputs(4)(0) <= X"4204";
    eventinputs(4)(1) <= X"0000";
    eventinputs(4)(2) <= X"ABCD";
    eventinputs(4)(3) <= X"EF89";
    eventinputs(4)(4) <= X"1234";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;

    assert MYMAC = X"ABCDEF891234" report "Error setting MYMAC output value" severity error;

    wait;

    -- now try and acquire the event
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = X"30"
      report "1 : invalid transmitted event : command ID" severity error;

-- wait for 3 ns;
-- EDSELRX <= "0001";
-- wait until rising_edge(CLK);
-- assert EDRX = X"01"
-- report "1 : invalid transmitted event : device" severity error;


-- wait for 3 ns;
-- EDSELRX <= "0011";
-- wait until rising_edge(CLK);
-- assert EDRX = X"01"
-- report "1 : invalid transmitted event : success" severity error;

-- wait for 3 ns;
-- EDSELRX <= "0100";
-- wait until rising_edge(CLK);
-- assert EDRX = X"AB"
-- report "1 : invalid transmitted event : response" severity error;

-- wait for 3 ns;
-- EDSELRX <= "0101";
-- wait until rising_edge(CLK);
-- assert EDRX = X"CD"
-- report "1 : invalid transmitted event : response" severity error;

-- wait for 3 ns;
-- EDSELRX <= "0110";
-- wait until rising_edge(CLK);
-- assert EDRX = X"EF"
-- report "1 : invalid transmitted event : response" severity error;

-- wait for 3 ns;
-- EDSELRX <= "0111";
-- wait until rising_edge(CLK);
-- assert EDRX = X"12"
-- report "1 : invalid transmitted event : response" severity error;

-- state <= firstwritedone;



    assert false report "End of Simulation" severity failure;





  end process main;

end Behavioral;
