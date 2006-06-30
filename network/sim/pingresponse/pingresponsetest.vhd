library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.TextIO.all;
use ieee.std_logic_textio.all;


library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;


entity pingresponsetest is

end pingresponsetest;

architecture Behavioral of pingresponsetest is

  component pingresponse
    port (
      CLK   : in std_logic;
      MYMAC : in std_logic_vector(47 downto 0);
      MYIP  : in std_logic_vector(31 downto 0);

      -- IO interface
      START : in std_logic;

      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);

      -- output
      ARM   : out std_logic;
      GRANT : in  std_logic;
      DOUT  : out std_logic_vector(15 downto 0);
      DOEN  : out std_logic);
  end component;


  signal CLK   : std_logic                     := '0';
  signal MYMAC : std_logic_vector(47 downto 0) := X"00095be0f790";
  signal MYIP  : std_logic_vector(31 downto 0) := X"12040e5b";

  -- output
  signal ARM   : std_logic                     := '0';
  signal GRANT : std_logic                     := '0';
  signal DOUT  : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN  : std_logic                     := '0';


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
      RETXSTART  : out std_logic;
      RETXADDR   : in  std_logic_vector(9 downto 0);
      RETXDONE   : in  std_logic;
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

  signal RESET      : std_logic                     := '1';
  signal NEXTFRAME  : std_logic                     := '0';
  signal DINEN      : std_logic                     := '0';
  signal DIN        : std_logic_vector(15 downto 0) := (others => '0');
  signal PKTDATA    : std_logic_vector(15 downto 0) := (others => '0');
  -- ICMP echo request IO
  signal PINGSTART  : std_logic                     := '0';
  signal PINGADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal PINGDONE   : std_logic                     := '0';
  -- retransmit request 
  signal RETXSTART  : std_logic                     := '0';
  signal RETXADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal RETXDONE   : std_logic                     := '0';
  -- ARP Request
  signal ARPSTART   : std_logic                     := '0';
  signal ARPADDR    : std_logic_vector(9 downto 0)  := (others => '0');
  signal ARPDONE    : std_logic                     := '0';
  -- input event
  signal EVENTSTART : std_logic                     := '0';
  signal EVENTADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal EVENTDONE  : std_logic                     := '0';


  signal dexpected : std_logic_vector(15 downto 0) := (others => '0');
  signal doutl     : std_logic_vector(15 downto 0) := (others => '0');
  signal dataerror : std_logic                     := '0';

  procedure verifypkt (
    constant filename  : in    string;
    signal   CLK       : in    std_logic;
    signal   DIN       : in    std_logic_vector(15 downto 0);
    signal   DOEN      : in    std_logic;
    signal   doutl     : inout std_logic_vector(15 downto 0);
    signal   dexpected : inout std_logic_vector(15 downto 0);
    signal   dataerror : inout std_logic) is

    file data_file : text;
    variable L     : line;
    variable word  : std_logic_vector(15 downto 0);

  begin
    file_open(data_file, filename, read_mode);
    while not endfile(data_file) loop
      wait until rising_edge(CLK);
      if DOEN = '1' then
        readline(data_file, L);
        hread(L, word);
        doutl       <= dout;
        dexpected   <= word;
        wait for 1 ns;
        assert doutl = dexpected report "Error reading DOUT" severity error;
        if doutl /= dexpected then
          dataerror <= '1';
        else
          dataerror <= '0';
        end if;

      end if;

    end loop;
    file_close(data_file);

  end procedure verifypkt;

begin  -- Behavioral


  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 20 ns;

  pingresponse_uut : pingresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => PINGSTART,
      DONE      => PINGDONE,
      INPKTDATA => PKTDATA,
      INPKTADDR => PINGADDR,
      ARM       => ARM,
      GRANT     => GRANT,
      DOUT      => DOUT,
      DOEN      => DOEN);

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
      RETXSTART  => RETXSTART,
      RETXADDR   => RETXADDR,
      RETXDONE   => RETXDONE,
      ARPSTART   => ARPSTART,
      ARPADDR    => ARPADDR,
      ARPDONE    => ARPDONE,
      EVENTSTART => EVENTSTART,
      EVENTADDR  => EVENTADDR,
      EVENTDONE  => EVENTDONE);


  process
  begin

    -- first ping response
    
    wait for 2 us;

    networkstack.writepkt("req_host1_1.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_host1_1.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';

--------------------------------------------------------------------------
-- second ping from first host
--------------------------------------------------------------------------    
    wait for 2 us;

    networkstack.writepkt("req_host1_2.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_host1_2.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';

--------------------------------------------------------------------------
-- third ping from first host
--------------------------------------------------------------------------    
    wait for 1 us;

    networkstack.writepkt("req_host1_3.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_host1_3.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';


--------------------------------------------------------------------------
-- fourth ping from first host
--------------------------------------------------------------------------    
    wait for 1 us;

    networkstack.writepkt("req_host1_4.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_host1_4.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';

--------------------------------------------------------------------------
-- first ping from windows host 
--------------------------------------------------------------------------    
    wait for 1 us;

    networkstack.writepkt("req_host2_1.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_host2_1.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';


--------------------------------------------------------------------------
-- first ping from remote (non-subnet) host
--------------------------------------------------------------------------    
    wait for 1 us;

    networkstack.writepkt("req_hostremote_1.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 5 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';

    verifypkt("resp_hostremote_1.txt", CLK, DIN, DOEN,
              doutl, dexpected, dataerror);

    wait until rising_edge(CLK) and PINGDONE = '1';

    
    assert false report "End of Simulation" severity failure;


    wait;

  end process;



end Behavioral;
