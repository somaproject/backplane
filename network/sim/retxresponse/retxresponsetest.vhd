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

entity retxresponsetest is

end retxresponsetest;

architecture Behavioral of retxresponsetest is

  component retxresponse
    port (
      CLK       : in  std_logic;
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- retx interface
      RETXDIN   : in  std_logic_vector(15 downto 0);
      RETXADDR  : in  std_logic_vector(8 downto 0);
      RETXWE    : in  std_logic;
      RETXREQ   : out std_logic;
      RETXDONE  : in  std_logic;
      RETXSRC   : out std_logic_vector(5 downto 0);
      RETXTYP   : out std_logic_vector(1 downto 0);
      RETXID    : out std_logic_vector(31 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;


  signal CLK : std_logic := '0';

  -- output
  signal ARM   : std_logic                     := '0';
  signal GRANT : std_logic                     := '0';
  signal DOUT, doutl  : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN  : std_logic                     := '0';

  -- retx interface
  signal RETXDINio  : std_logic_vector(15 downto 0) := (others => '0');
  signal RETXADDRio : std_logic_vector(8 downto 0)  := (others => '0');
  signal RETXWE   : std_logic                     := '0';
  signal RETXREQ  : std_logic                     := '0';
  signal RETXDONEio : std_logic                     := '0';
  signal RETXSRC  : std_logic_vector(5 downto 0)  := (others => '0');
  signal RETXTYP  : std_logic_vector(1 downto 0)  := (others => '0');
  signal RETXID   : std_logic_vector(31 downto 0) := (others => '0');

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
  signal dataerror : std_logic                     := '0';

--   procedure verifypkt (
--     constant filename  : in    string;
--     signal   CLK       : in    std_logic;
--     signal   DIN       : in    std_logic_vector(15 downto 0);
--     signal   DOEN      : in    std_logic;
--     signal   doutl     : inout std_logic_vector(15 downto 0);
--     signal   dexpected : inout std_logic_vector(15 downto 0);
--     signal   dataerror : inout std_logic) is

--     file data_file : text;
--     variable L     : line;
--     variable word  : std_logic_vector(15 downto 0);

--   begin
--     file_open(data_file, filename, read_mode);
--     while not endfile(data_file) loop
--       wait until rising_edge(CLK);
--       if DOEN = '1' then
--         readline(data_file, L);
--         hread(L, word);
--         doutl       <= dout;
--         dexpected   <= word;
--         wait for 1 ns;
--         assert doutl = dexpected report "Error reading DOUT" severity error;
--         if doutl /= dexpected then
--           dataerror <= '1';
--         else
--           dataerror <= '0';
--         end if;

--       end if;

--     end loop;
--     file_close(data_file);

--   end procedure verifypkt;

begin  -- Behavioral


  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 20 ns;

  retxresponse_uut : retxresponse
    port map (
      CLK       => CLK,
      START     => RETXSTART,
      DONE      => RETXDONE,
      INPKTDATA => PKTDATA,
      INPKTADDR => RETXADDR,
      RETXDIN   => RETXDINio,
      RETXADDR  => RETXADDRio,
      RETXWE    => RETXWE,
      RETXREQ   => RETXREQ,
      RETXDONE  => RETXDONEio,
      RETXSRC   => RETXSRC,
      RETXTYP   => RETXTYP,
      RETXID    => RETXID,
      ARM   => ARM,
      GRANT => GRANT,
      DOUT  => DOUT,
      DOEN  => DOEN);

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
    file props_file : text;
    variable L     : line;
    variable srcin : std_logic_vector(7 downto 0);
    variable typin : std_Logic_vector(7 downto 0);
    variable idin : std_logic_vector(31 downto 0);
    
    
  begin
    ---------------------------------------------------------------------------
-- first attempt
    ---------------------------------------------------------------------------
    wait for 2 us;
    file_open(props_file, "pkt1.props.txt");
    readline(props_file, L);
    hread(L, typin);
    hread(L, srcin);
    hread(L, idin); 
    file_close(props_file); 

    networkstack.writepkt("pkt1.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and RETXSTART = '1';
    wait until rising_edge(CLK) and RETXREQ = '1';

    assert typin(1 downto 0) = retxtyp
      report "Error in acquiring packet TYP" severity Error;
    assert srcin(5 downto 0) = retxsrc
      report "Error in acquiring packet SRC" severity Error;
    assert idin = retxid
      report "Error in acquiring packet ID" severity Error;

    -- now the true test; write fake data
    wait for 1 us;
    
    -- write length
    
    wait until rising_edge(CLK);
    RETXDINio <= X"0100";
    RETXADDRio <= "000000000";
    RETXWE <= '1';
    wait until rising_edge(CLK);
    RETXDINio <= X"ABCD";               -- write  a single data value at
    RETXADDRio <= "001111111";          -- the end
    RETXWE <= '1';
    wait until rising_edge(CLK);
    RETXWE <= '0';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    RETXDONEio <= '1';
    wait until rising_edge(CLK);
    RETXDONEio <= '0'; 

    wait for 2 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';
    wait until rising_edge(CLK) and DOEN = '1';
    assert dout = X"0100" report "Error reading first word" severity Error;
    wait until rising_edge(CLK) and DOEN = '0';
    assert doutl = X"ABCD" report "Error reading late word" severity Error;
    
    ---------------------------------------------------------------------------
-- second attempt
    ---------------------------------------------------------------------------
    wait for 2 us;
    file_open(props_file, "pkt2.props.txt");
    readline(props_file, L);
    hread(L, typin);
    hread(L, srcin);
    hread(L, idin); 
    file_close(props_file); 

    networkstack.writepkt("pkt2.txt", CLK, DINEN, NEXTFRAME, DIN);
    wait until rising_edge(CLK) and RETXSTART = '1';
    wait until rising_edge(CLK) and RETXREQ = '1';

    assert typin(1 downto 0) = retxtyp
      report "Error in acquiring packet TYP" severity Error;
    assert srcin(5 downto 0) = retxsrc
      report "Error in acquiring packet SRC" severity Error;
    assert idin = retxid
      report "Error in acquiring packet ID" severity Error;

    -- now the true test; write fake data
    wait for 1 us;
    
    -- write length
    
    wait until rising_edge(CLK);
    RETXDINio <= X"0200";
    RETXADDRio <= "000000000";
    RETXWE <= '1';
    wait until rising_edge(CLK);
    RETXDINio <= X"1234";               -- write  a single data value at
    RETXADDRio <= "011111111";          -- the end
    RETXWE <= '1';
    wait until rising_edge(CLK);
    RETXWE <= '0';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    RETXDONEio <= '1';
    wait until rising_edge(CLK);
    RETXDONEio <= '0'; 

    wait for 2 us;
    wait until rising_edge(CLK);
    GRANT <= '1';
    wait until rising_edge(CLK);
    GRANT <= '0';
    wait until rising_edge(CLK) and DOEN = '1';
    assert dout = X"0200" report "Error reading first word" severity Error;
    wait until rising_edge(CLK) and DOEN = '0';
    assert doutl = X"1234" report "Error reading late word" severity Error;
    
    report "End of Simulation" severity Failure;
    
    
  end process;


  main : process(CLK)
    begin
      if rising_edge(CLK) then
        doutl <= DOUT; 
      end if;

    end process main; 
end Behavioral;
