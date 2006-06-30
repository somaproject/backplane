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
  signal doutl : std_logic_vector(15 downto 0) := (others => '0');

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


    file data_file : text open read_mode is "goodresp.txt";
    variable L     : line;
    variable word  : std_logic_vector(15 downto 0);

  begin
    wait for 2 us;
    networkstack.writepkt("goodquery.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and ARPSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 20 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';
    while not endfile(data_file) loop
      wait until rising_edge(CLK);
      if DOEN = '1' then
        readline(data_file, L);
        hread(L, word);
        doutl <= dout; 
        dexpected <= word; 
        wait for 1 ns;
        assert doutl = dexpected report "Error reading DOUT" severity Error; 
        
        
      end if;

    end loop;

    wait until rising_edge(CLK) and ARPDONE = '1';
      
    wait for 2 us;
    networkstack.writepkt("notusquery.txt", CLK, DINEN, NEXTFRAME, DIN);

    wait until rising_edge(CLK) and ARPDONE = '1';

    assert False report "End of Simulation" severity Failure;

    
    wait;

  end process;



end Behavioral;
