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

entity inputcontroltest is

end inputcontroltest;

architecture Behavioral of inputcontroltest is

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
      -- data retransmit request 
      DRETXSTART  : out std_logic;
      DRETXADDR   : in  std_logic_vector(9 downto 0);
      DRETXDONE   : in  std_logic;
      -- event retransmit request 
      ERETXSTART  : out std_logic;
      ERETXADDR   : in  std_logic_vector(9 downto 0);
      ERETXDONE   : in  std_logic;
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


  signal CLK        : std_logic                     := '0';
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
  signal DRETXSTART  : std_logic                     := '0';
  signal DRETXADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal DRETXDONE   : std_logic                     := '0';
  -- event retransmit request 
  signal ERETXSTART  : std_logic                     := '0';
  signal ERETXADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal ERETXDONE   : std_logic                     := '0';

  
  -- ARP Request
  signal ARPSTART   : std_logic                     := '0';
  signal ARPADDR    : std_logic_vector(9 downto 0)  := (others => '0');
  signal ARPDONE    : std_logic                     := '0';
  -- input event
  signal EVENTSTART : std_logic                     := '0';
  signal EVENTADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal EVENTDONE  : std_logic                     := '0';


begin  -- Behavioral

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
      DRETXSTART  => DRETXSTART,
      DRETXADDR   => DRETXADDR,
      DRETXDONE   => DRETXDONE,
      ERETXSTART  => ERETXSTART,
      ERETXADDR   => ERETXADDR,
      ERETXDONE   => ERETXDONE,
      ARPSTART   => ARPSTART,
      ARPADDR    => ARPADDR,
      ARPDONE    => ARPDONE,
      EVENTSTART => EVENTSTART,
      EVENTADDR  => EVENTADDR,
      EVENTDONE  => EVENTDONE);


  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  main : process


  begin
    -- arp query
    networkstack.writepkt("arpquery.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and ARPSTART ='1';
    wait for 20 us;
    ARPDONE <= '1';
    wait until rising_edge(CLK);
    ARPDONE <= '0';

    -- icmp query
    
    networkstack.writepkt("icmpechoreq.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and PINGSTART ='1';
    wait for 20 us;
    PINGDONE <= '1';
    wait until rising_edge(CLK);
    PINGDONE <= '0';

    wait for 10 us;
    assert False report "End of Simulation" severity Failure;
    wait; 
    

  end process main;

end Behavioral;
