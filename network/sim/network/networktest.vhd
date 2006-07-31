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

entity networktest is

end networktest;

architecture Behavioral of networktest is

  component network
    port (
      CLK          : in  std_logic;
      MEMCLK       : in  std_logic;
      RESET        : in  std_logic;
      -- config
      MYIP         : in  std_logic_vector(31 downto 0);
      MYMAC        : in  std_logic_vector(47 downto 0);
      MYBCAST      : in  std_logic_vector(31 downto 0);
      -- input
      NICNEXTFRAME : out std_logic;
      NICDINEN     : in  std_logic;
      NICDIN       : in  std_logic_vector(15 downto 0);
      -- output
      DOUT         : out std_logic_vector(15 downto 0);
      NEWFRAME     : out std_logic;
      IOCLOCK      : out std_logic;

      -- event bus
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0);

      -- data bus
      DIENA   : in    std_logic;
      DINA    : in    std_logic_vector(7 downto 0);
      DIENB   : in    std_logic;
      DINB    : in    std_logic_vector(7 downto 0);
      -- memory interface
      RAMDQ   : inout std_logic_vector(15 downto 0);
      RAMWE   : out   std_logic;
      RAMADDR : out   std_logic_vector(16 downto 0);
      RAMCLK  : out   std_logic

      );
  end component;

  component datareceiver
    generic (
      typ       :     integer := 0;
      src       :     integer := 0);
    port (
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      NEWFRAME  : in  std_logic;
      RXGOOD    : out std_logic;
      RXCNT     : out integer;
      RXMISSING : out std_logic);
  end component;

  component eventreceiver
    port (
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      NEWFRAME  : in  std_logic;
      RXGOOD    : out std_logic := '0';
      RXCNT     : out integer   := 0;
      RXMISSING : out std_logic := '0');
  end component;

  signal CLK    : std_logic := '0';
  signal memclk : std_logic := '0';

  signal RESET        : std_logic                     := '1';
  -- config
  signal MYIP         : std_logic_vector(31 downto 0) := (others => '0');
  signal MYMAC        : std_logic_vector(47 downto 0) := (others => '0');
  signal MYBCAST      : std_logic_vector(31 downto 0) := (others => '0');
  -- input
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');
  -- output
  signal DOUT         : std_logic_vector(15 downto 0) := (others => '0');
  signal NEWFRAME     : std_logic                     := '0';
  signal IOCLOCK      : std_logic                     := '0';

  -- event bus
  signal ECYCLE : std_logic := '0';

  signal EARX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');

  -- ram
  signal RAMCLK  : std_logic                     := '0';
  signal RAMADDR : std_logic_vector(16 downto 0) := (others => '0');
  signal RAMWE   : std_logic                     := '1';
  signal RAMDQ   : std_logic_vector(15 downto 0) := (others => 'Z');

  -- data bus
  signal dina, dinb   : std_logic_vector(7 downto 0) := (others => '0');
  signal diena, dienb : std_logic                    := '0';

-- simulated eventbus
  signal epos : integer := 0;

-- memory signals
  signal ramwel, ramwell     : std_logic := '1';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                         := (others => '0');

  signal data_rxgood    : std_logic_vector(63 downto 0) := (others => '0');
  signal data_rxmissing : std_logic_vector(63 downto 0) := (others => '0');
  type rxcntarray is array (0 to 63) of integer;
  signal data_rxcnt     : rxcntarray                    := (others => 0);

  signal event_rxgood : std_logic := '0';
  signal event_rxmissing : std_logic := '0';
  signal event_rxcnt : integer := 0;

-- event signals
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

begin  -- Behavioral


  network_uut : network
    port map (
      CLK          => CLK,
      MEMCLK       => MEMCLK,
      RESET        => RESET,
      MYIP         => MYIP,
      MYMAC        => MYMAC,
      MYBCAST      => MYBCAST,
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => NICDINEN,
      NICDIN       => NICDIN,

      DOUT     => DOUT,
      NEWFRAME => NEWFRAME,
      IOCLOCK  => IOCLOCK,

      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EATX    => EATX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EDTX    => EDTX,

      DIENA => DIENA,
      DINA  => DINA,
      DIENB => DIENB,
      DINB  => DINB,

      RAMDQ   => RAMDQ,
      RAMWE   => RAMWE,
      RAMADDR => RAMADDR,
      RAMCLK  => RAMCLK);

  MEMCLK  <= not MEMCLK after 5 ns;
  process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then
      CLK <= not CLK;
    end if;
  end process;

  RESET      <= '0' after 20 ns;
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
  -- configuration fields for device identity
  -- 
  myip    <= X"C0a80002";               -- 192.168.0.2
  mybcast <= X"C0a000FF";
  mymac   <= X"DEADBEEF1234";

  main : process
  begin
    wait for 2 us;
-- networkstack.writepkt("arpquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
    wait for 2 us;

-- networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
-- networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);

    wait;

  end process main;

  datainput                   : process
    file datafilea, datafileb : text;
    variable L                : line;
    variable doen             : std_logic                    := '0';
    variable data             : std_logic_vector(7 downto 0) := (others => '0');

  begin
    file_open(datafilea, "dataa.txt");
    file_open(datafileb, "datab.txt");

    wait until rising_edge(CLK) and ECYCLE = '1';
    while not endfile(datafilea) loop

      readline(datafilea, L);
      read(L, doen);
      hread(L, data);
      DINA  <= data;
      DIENA <= doen;

      readline(datafileb, L);
      read(L, doen);
      hread(L, data);
      DINB  <= data;
      DIENB <= doen;
      wait until rising_edge(CLK);

    end loop;
    assert false report "End of Simulation" severity failure;


  end process datainput;

  memoryinst : process(MEMCLK, ramwel)
    -- memory construct
    type ramdata is array ( 0 to 131071)
    of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    if ramwel = '0' then
      RAMDQ   <= (others => 'Z');
    end if;
    if rising_edge(MEMCLK) then
      ramwel  <= RAMWE;
      ramwell <= ramwel;

      ramaddrl  <= RAMADDR;
      ramaddrll <= ramaddrl;

      if ramwell = '0' then
        memory(TO_INTEGER(unsigned(ramaddrll))) := RAMDQ;
      else
        RAMDQ <= memory(TO_INTEGER(unsigned(ramaddrll)));
      end if;

    end if;
  end process memoryinst;

  -- retx request and verify

  datareceivers       : for i in 0 to 63 generate
    datareceiver_inst : datareceiver
      generic map (
        typ       => 0,
        src       => i)
      port map (
        CLK       => CLK,
        DIN       => DOUT,
        NEWFRAME  => NEWFRAME,
        RXGOOD    => data_rxgood(i),
        RXCNT     => data_rxcnt(i),
        RXMISSING => data_rxmissing(i));
  end generate datareceivers; 
  
  eventreceiver_inst: eventreceiver
    port map (
      CLK       => CLK,
      DIN       => DOUT,
      NEWFRAMe  => NEWFRAME,
      RXGOOD    => event_rxgood,
      RXCNt     => event_rxcnt,
      RXMISSING => event_rxmissing); 
    
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

  EATX <= (others => '1');
  
  -- time stamp event
  ts_eventgen             : process(CLK)
    variable eventtimepos : std_logic_vector(47 downto 0) := (others => '0');
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        eventinputs(0)(0) <= X"1000";
        eventinputs(0)(1) <= eventtimepos(47 downto 32);
        eventinputs(0)(2) <= eventtimepos(31 downto 16);
        eventinputs(0)(3) <= eventtimepos(15 downto 0);

        eventtimepos := eventtimepos + 1;
      end if;
    end if;
  end process;
end Behavioral;
