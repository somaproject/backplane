library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

use ieee.numeric_std.all;


entity eventrxtest is

end eventrxtest;


architecture Behavioral of eventrxtest is

  component eventrx
    port (
      CLK         : in  std_logic;
      INPKTADDR   : out std_logic_vector(9 downto 0);
      INPKTDATA   : in  std_logic_vector(15 downto 0);
      START       : in  std_logic;
      DONE        : out std_logic;
      EVTRXSUC    : out std_logic;
      EVTFIFOFULL : out std_logic;
      -- input parameters
      MYMAC       : in  std_logic_vector(47 downto 0);
      MYIP        : in  std_logic_vector(31 downto 0);
      -- Event interface
      ECYCLE      : in  std_logic;
      EARX        : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX        : out std_logic_vector(7 downto 0);
      EDSELRX     : in  std_logic_vector(3 downto 0);
      -- output to TX interface
      DOUT        : out std_logic_vector(15 downto 0);
      DOEN        : out std_logic;
      ARM         : out std_logic;
      GRANT       : in  std_logic);
  end component;

  signal RESET : std_logic := '0';

  signal CLK         : std_logic := '0';
  signal START       : std_logic := '0';
  signal DONE        : std_logic := '0';
  signal EVTRXSUC    : std_logic := '0';
  signal EVTFIFOFULL : std_logic := '0';

  -- input parameters
  signal MYMAC : std_logic_vector(47 downto 0) := (others => '0');
  signal MYIP  : std_logic_vector(31 downto 0) := (others => '0');

  -- Event interface
  signal ECYCLE  : std_logic                    := '0';
  signal EARX    : std_logic_vector(79 downto 0)
                                                := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  -- output to TX interface
  signal DOUT  : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN  : std_logic                     := '0';
  signal ARM   : std_logic                     := '0';
  signal GRANT : std_logic                     := '0';

  component inputcontrol
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      NEXTFRAME  : out std_logic;
      DINEN      : in  std_logic;
      DIN        : in  std_logic_vector(15 downto 0);
      PKTDATA    : out std_logic_vector(15 downto 0);
      -- ICMP echo request IO
      PINGSTART  : out std_logic;
      PINGADDR   : in  std_logic_vector(9 downto 0);
      PINGDONE   : in  std_logic;
      -- retransmit request 
      DRETXSTART : out std_logic;
      DRETXADDR  : in  std_logic_vector(9 downto 0);
      DRETXDONE  : in  std_logic;

      ERETXSTART : out std_logic;
      ERETXADDR  : in  std_logic_vector(9 downto 0);
      ERETXDONE  : in  std_logic;
      -- ARP Request
      ARPSTART   : out std_logic;
      ARPADDR    : in  std_logic_vector(9 downto 0);
      ARPDONE    : in  std_logic;
      -- input event
      EVENTSTART : out std_logic;
      EVENTADDR  : in  std_logic_vector(9 downto 0);
      EVENTDONE  : in  std_logic
      );
  end component;

  signal NEXTFRAME  : std_logic                     := '0';
  signal DINEN      : std_logic                     := '0';
  signal DIN        : std_logic_vector(15 downto 0) := (others => '0');
  signal PKTDATA    : std_logic_vector(15 downto 0) := (others => '0');
  -- ICMP echo request IO
  signal PINGSTART  : std_logic                     := '0';
  signal PINGADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal PINGDONE   : std_logic                     := '0';
  -- retransmit request
  signal DRETXSTART : std_logic                     := '0';
  signal DRETXADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal DRETXDONE  : std_logic                     := '0';
  -- retransmit request
  signal ERETXSTART : std_logic                     := '0';
  signal ERETXADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal ERETXDONE  : std_logic                     := '0';
  -- ARP Request
  signal ARPSTART   : std_logic                     := '0';
  signal ARPADDR    : std_logic_vector(9 downto 0)  := (others => '0');
  signal ARPDONE    : std_logic                     := '0';
  -- input event
  signal EVENTSTART : std_logic                     := '0';
  signal EVENTADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal EVENTDONE  : std_logic                     := '0';
  signal data_dout  : std_logic_vector(15 downto 0) := (others => '0');

  signal data_expected : std_logic_vector(15 downto 0) := (others => '0');
  signal data_error    : std_logic                     := '0';

  signal epos : integer := 0;

  -- counters
  signal evtrxsuc_cnt : integer := 0;

  signal evtfifofull_cnt : integer := 0;

  component eventrxverify
    generic (
      EVENTFILENAME : in string);

    port (
      CLK         : in  std_logic;
      ECYCLE      : in  std_logic;
      EARX        : in  std_logic_vector(79 downto 0);
      EDRX        : in  std_logic_vector(7 downto 0);
      EDRXSEL     : out std_logic_vector(3 downto 0);
      RESET       : in  std_logic;
      -- invalidate interface
      INVNUM      : in  integer;
      INVCLK      : in  std_logic;
      -- output status
      EVTERROR    : out std_logic;
      EVENTPOSOUT : out integer
      );
  end component;

  signal invnum           : integer   := 0;
  signal invclk           : std_logic := '0';
  signal evterror         : std_logic := '0';
  signal eventposout      : integer   := 0;
  signal eventverifyreset : std_logic := '1';

  signal datagram_ecnt     : integer := 0;
  signal datagram_totalcnt : integer := 0;

  signal success_pktcnt : integer := 0;
  signal fail_pktcnt    : integer := 0;



begin  -- Behavioral
  MYMAC <= X"00E08105C58C";
  MYIP  <= X"0A000164";

  eventrx_uut : eventrx
    port map (
      CLK         => CLK,
      INPKTADDR   => EVENTADDR,
      INPKTDATA   => PKTDATA,
      START       => EVENTSTART,
      DONE        => EVENTDONE,
      EVTRXSUC    => EVTRXSUC,
      EVTfIFOFULL => EVTFIFOFULL,
      MYMAC       => MYMAC,
      MYIP        => MYIP,
      ECYCLE      => ECYCLE,
      EARX        => EARX(somabackplane.N-1 downto 0),
      EDRX        => EDRX,
      EDSELRX     => EDSELRX,
      DOUT        => DOUT,
      DOEN        => DOEN,
      ARM         => ARM,
      GRANT       => GRANT);


  CLK <= not CLK after 10 ns;


  inputcontrol_uut : inputcontrol
    port map (
      CLK        => CLK,
      RESET      => RESET,
      NEXTFRAME  => NEXTFRAME,
      DINEN      => DINEN,
      DIN        => DIN,
      PKTDATA    => PKTDATA,
      PINGSTART  => PINGSTART,
      PINGADDR   => PINGADDR,
      PINGDONE   => PINGDONE,
      DRETXSTART => DRETXSTART,
      DRETXADDR  => DRETXADDR,
      DRETXDONE  => DRETXDONE,
      ERETXSTART => ERETXSTART,
      ERETXADDR  => ERETXADDR,
      ERETXDONE  => ERETXDONE,
      ARPSTART   => ARPSTART,
      ARPADDR    => ARPADDR,
      ARPDONE    => ARPDONE,
      EVENTSTART => EVENTSTART,
      EVENTADDR  => EVENTADDR,
      EVENTDONE  => EVENTDONE);

  eventrxverify_inst : eventrxverify
    generic map (
      eventfilename => "events.txt")
    port map (
      CLK           => CLK,
      ECYCLE        => ECYCLE,
      EARX          => EARX,
      EDRX          => EDRX,
      EDRXSEL       => EDSELRX,
      RESET         => eventverifyreset,
      INVNUM        => INVNUM,
      INVCLK        => INVCLK,
      EVTERROR      => EVTERROR,
      EVENTPOSOUT   => EVENTPOSOUT);

  -- data input

  datainput       : process
    file req_file : text open read_mode is "client_requests.txt";
    variable L    : line;
    variable len  : integer := 0;
    variable word : std_logic_vector(15 downto 0);

  begin
    while not endfile(req_file) loop

      wait until rising_edge(CLK);
      readline(req_file, L);
      read(L, len);
      wait for 1 us;

      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for i in 0 to len-1 loop
        hread(L, word);
        DINEN           <= '1';
        DIN             <= word;
        wait until rising_edge(CLK);
        if i = 23 then
          datagram_ecnt <= to_integer(unsigned(DIN));
        end if;
      end loop;  -- i 
      DINEN             <= '0';
      wait until rising_edge(CLK) and EVENTDONE = '1';  -- artificial wait
      wait for 15 us;


    end loop;
    wait;
  end process datainput;

  -- output verify
  output_verify    : process
    file resp_file : text open read_mode is "server_response.txt";
    variable L     : line;
    variable len   : integer := 0;
    variable word  : std_logic_vector(15 downto 0);
    variable pos   : integer := 0;

  begin
    while true loop
      wait until rising_edge(CLK);
      wait until rising_edge(CLK) and ARM = '1';
      readline(resp_file, L);
      read(L, len);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      GRANT             <= '1';
      pos := 0;
      wait until rising_edge(CLK);
      GRANT             <= '0';
      wait until rising_edge(CLK) and DOEN = '1';
      while DOEN = '1' loop
        if pos < len then
          hread(L, word);
          data_expected <= word;
          if pos = 23 then              -- skip success
            if DOUT(0) = '0' then       -- failure, invalidate these evnts

              for i in 0 to datagram_ecnt -1 loop
                wait for 0.1 ns;
                invclk <= '0';
                wait for 0.1 ns;
                invnum <= datagram_totalcnt + i;
                wait for 0.1 ns;
                invclk <= '1';
                wait for 0.1 ns;
                wait for 0.1 ns;
                invclk <= '0';

              end loop;  -- i
              fail_pktcnt    <= fail_pktcnt + 1;
            else
              success_pktcnt <= success_pktcnt + 1;
            end if;

            datagram_totalcnt <= datagram_totalcnt + datagram_ecnt;

          else
            if word /= DOUT then
              data_error <= '1';
            else
              data_error <= '0';
            end if;

          end if;
        end if;

        pos := pos + 1;
        wait until rising_edge(CLK);

      end loop;
    end loop;
  end process output_verify;

  process(CLK)
  begin
    if rising_edge(CLK) then
      data_dout <= DOUT;
    end if;
  end process;



  --ecycle generation
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

  -- event verify
  process
  begin

    wait for 1 us;
    eventverifyreset <= '0';

  end process;

  -- counters
  process(CLK)
  begin
    if rising_edge(CLK) then
      if EVTRXSUC = '1' then
        evtrxsuc_cnt <= evtrxsuc_cnt + 1;
      end if;

      if EVTFIFOFULL = '1' then
        evtfifofull_cnt <= evtfifofull_cnt + 1;
      end if;
    end if;
  end process;
  -- wait to finish
  process
  begin
    wait for 200 us;

    wait until rising_edge(CLK) and eventposout = 2047;
    report "Received " & integer'image(evtrxsuc_cnt) & " input packets for which we had fifo space and committed to the event bus" severity note;

    report "Received " & integer'image(evtfifofull_cnt) & " input packets where we didn't have enough fifo space and had to abort" severity note;


    report "End of Simulation" severity failure;

  end process;

end Behavioral;
