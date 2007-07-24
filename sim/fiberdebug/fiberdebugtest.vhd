library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity rxeventfifotest is

end rxeventfifotest;

architecture Behavioral of rxeventfifotest is

  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;


  signal CLK    : std_logic := '0';
  signal RESET  : std_logic := '1';
  signal ECYCLE : std_logic := '0';

  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal EDTX   : std_logic_vector(7 downto 0)  := (others => '0');
  signal EOUTD  : std_logic_vector(15 downto 0) := (others => '0');
  signal EOUTA  : std_logic_vector(2 downto 0)  := (others => '0');
  signal EVALID : std_logic                     := '0';
  signal ENEXT  : std_logic                     := '0';

  signal pos : integer := 990;

  signal expectedeventid : std_logic_vector(7 downto 0) := (others => '0');

begin  -- Behavioral

  rxeventfifo_uut : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      EOUTD  => EOUTD,
      EOUTA  => EOUTA,
      EVALID => EVALID,
      ENEXT  => ENEXT);


  CLK <= not CLK after 10 ns;

  RESET <= '0' after 50 ns;


  -- input generation

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
        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"00";
        wait until rising_edge(CLK);

        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"01";
        wait until rising_edge(CLK);

        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"02";
        wait until rising_edge(CLK);

        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"03";
        wait until rising_edge(CLK);

        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"04";
        wait until rising_edge(CLK);

        EDTX <= std_logic_vector(TO_UNSIGNED(i, 8));
        wait until rising_edge(CLK);
        EDTX <= X"05";
        wait until rising_edge(CLK);

      end loop;  -- i
    end loop;

  end process;

  event_transmission : process
  begin
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX <= (others => '0');


    wait until rising_edge(CLK) and ECYCLE = '1';

    assert EVALID = '0'
      report "Fifo incorrectly acquired an event during an empty (EATX = 0) cycle"
      severity error;


    EATX(0) <= '1';
    wait until rising_edge(CLK) and EVALID = '1';
    -- verify event
    EOUTA   <= "000";

    expectedeventid <= X"00";
    for i in 0 to 5 loop
      EOUTA         <= std_logic_vector(TO_UNSIGNED(i, 3)) after 1 ns;
      wait until rising_edge(CLK);
      wait for 1 ns;

      assert EOUTD = expectedeventid & std_logic_vector(TO_UNSIGNED(i, 8))
        report "Error reading data" severity error;


    end loop;  -- i
    wait until rising_edge(CLK);
    ENEXT <= '1' after 3 ns;
    wait until rising_edge(CLK);
    ENEXT <= '0' after 3 ns;

    -- a bunch of events
    wait until rising_edge(CLK) and ECYCLE = '1';

    -- add 22 events
    EATX(19 downto 0) <= (others => '1');
    --EATX(23 downto 22) <= (others => '1');
    wait until rising_edge(CLK) and ECYCLE = '1';

    EATX <= (others => '0');
    
    wait until rising_edge(CLK) and EVALID = '1';
    -- verify event
    EOUTA <= "000";

    expectedeventid <= X"00";
    for eventid in 0 to 19 loop
      wait until rising_edge(CLK) and EVALID = '1';
      for i in 0 to 5 loop
        EOUTA       <= std_logic_vector(TO_UNSIGNED(i, 3)) after 1 ns;
        wait until rising_edge(CLK);
        wait for 1 ns;

        assert EOUTD = std_logic_vector(TO_UNSIGNED(eventid, 8))
          & std_logic_vector(TO_UNSIGNED(i, 8))
          report "Error reading data" severity error;

      end loop;

      wait until rising_edge(CLK);
      ENEXT <= '1' after 3 ns;
      wait until rising_edge(CLK);
      ENEXT <= '0' after 3 ns;



    end loop;  -- eventid

    wait for 20 us;
    assert false report "End of Simulation" severity failure;


    wait;

  end process event_transmission;

end Behavioral;
