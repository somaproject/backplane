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


entity arpresponsetest is

end arpresponsetest;

architecture Behavioral of arpresponsetest is

  component arpresponse
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
      -- data retransmit request 
      DRETXSTART : out std_logic;
      DRETXADDR  : in  std_logic_vector(9 downto 0);
      DRETXDONE  : in  std_logic;
      -- event retransmit request 
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

  signal RESET      : std_logic                     := '1';
  signal NEXTFRAME  : std_logic                     := '0';
  signal DINEN      : std_logic                     := '0';
  signal DIN        : std_logic_vector(15 downto 0) := (others => '0');
  signal PKTDATA    : std_logic_vector(15 downto 0) := (others => '0');
  -- ICMP echo request IO
  signal PINGSTART  : std_logic                     := '0';
  signal PINGADDR   : std_logic_vector(9 downto 0)  := (others => '0');
  signal PINGDONE   : std_logic                     := '0';
  -- event retransmit request 
  signal DRETXSTART : std_logic                     := '0';
  signal DRETXADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal DRETXDONE  : std_logic                     := '0';
  -- event retransmit request 
  signal ERETXSTART : std_logic                     := '0';
  signal ERETXADDR  : std_logic_vector(9 downto 0)  := (others => '0');
  signal ERETXDONE  : std_logic                     := '0';


  -- ARP Request
  signal ARPSTART   : std_logic                    := '0';
  signal ARPADDR    : std_logic_vector(9 downto 0) := (others => '0');
  signal ARPDONE    : std_logic                    := '0';
  -- input event
  signal EVENTSTART : std_logic                    := '0';
  signal EVENTADDR  : std_logic_vector(9 downto 0) := (others => '0');
  signal EVENTDONE  : std_logic                    := '0';


  signal dexpected : std_logic_vector(15 downto 0) := (others => '0');
  signal doutl     : std_logic_vector(15 downto 0) := (others => '0');
  signal doenl : std_logic := '0';
  
begin  -- Behavioral

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 20 ns;

  arpresponse_uut : arpresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => ARPSTART,
      DONE      => ARPDONE,
      INPKTDATA => PKTDATA,
      INPKTADDR => ARPADDR,
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

  process


    file data_file : text open read_mode is "goodresp.txt";
    variable L     : line;
    variable word  : std_logic_vector(15 downto 0);

  begin
    wait for 2 us;
    networkstack.writepkt("goodquery.txt.crc", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and ARPSTART = '1';
    wait until rising_edge(CLK) and ARM = '1';
    wait for 20 us;
    wait until rising_edge(CLK);
    GRANT         <= '1';
    wait until rising_edge(CLK);
    GRANT         <= '0';
    while not endfile(data_file) loop
      wait until rising_edge(CLK);
      if DOEN = '1' then
        readline(data_file, L);
        hread(L, word);
        doutl     <= dout;
        dexpected <= word;
        wait for 1 ns;
        assert doutl = dexpected report "Error reading DOUT" severity error;


      end if;

    end loop;

    wait until rising_edge(CLK) and ARPDONE = '1';

    wait for 2 us;
    networkstack.writepkt("notusquery.txt.crc", CLK, DINEN, NEXTFRAME, DIN);

    wait until rising_edge(CLK) and ARPDONE = '1';

    assert false report "End of Simulation" severity failure;


    wait;

  end process;

 doencnt: process(CLK)
   variable doencnt : integer := 0;
   
   begin
     if rising_edge(CLK) then

       if doenl = '0' and DOEN = '1' then
         doencnt := 1;
       elsif doenl = '1' and doen = '0' then
         report "DOEN was high for " & integer'image(doencnt) severity note;
       elsif DOEN = '1'  then
         doencnt := doencnt + 1;
         
       end if;
       doenl <= DOEN;
     end if;

   end process; 

end Behavioral;
