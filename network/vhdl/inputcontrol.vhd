library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.vcomponents.all;

entity inputcontrol is
  port (
    CLK        : in  std_logic;
    RESET : in std_logic; 
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
    ARPADDR   : in  std_logic_vector(9 downto 0);
    ARPDONE    : in  std_logic;
    -- input event
    EVENTSTART : out std_logic;
    EVENTADDR  : in  std_logic_vector(9 downto 0);
    EVENTDONE  : in  std_logic
    );
end inputcontrol;

architecture Behavioral of inputcontrol is


-- input signals
  signal lnextframe : std_logic := '0';

  signal addra : std_logic_vector(9 downto 0) := (others => '0');
  signal wea   : std_logic                    := '0';

  signal dinl : std_logic_vector(15 downto 0) := (others => '0');

  -- output
  signal intaddrb : std_logic_vector(7 downto 0)  := (others => '0');
  signal addrb    : std_logic_vector(9 downto 0)  := (others => '0');
  signal dob      : std_logic_vector(15 downto 0) := (others => '0');

  signal mode : integer range 0 to 4 := 0;

  signal start : std_logic := '0';

  signal len : std_logic_vector(11 downto 0) := (others => '0');
  

  -- fsm
  type states is (none, dinst, dinw, fstart, nextpkt,
                  arppkt, arpopchk, arpqstart, arpwait,
                  ipchka, icmpchk, udpporta, udpchk, retxstarts, retxwait,
                  evtstart, evtwait, 
                  echoreq, icmpstart, pingwait);
  signal cs, ns : states := none;

-------------------------------------------------------------------------------
-- DEBUG
-------------------------------------------------------------------------------
component jtagsimpleout 
    generic (
    JTAG_CHAIN : integer := 0;
    JTAGN : integer := 32);
  port (
    CLK : in std_logic;
    DIN : in std_logic_vector(JTAGN-1 downto 0));
end component; 

signal jtagin : std_logic_vector(127 downto 0) := (others => '0');
signal statedebug : std_logic_vector(7 downto 0) := (others => '0');

-------------------------------------------------------------------------------


begin  -- Behavioral

  PKTDATA <= dob; 
  frame_buffer : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY") 
    port map (
      DOA   => open,
      DOB   => dob,
      DOPA  => open,
      DOPB  => open,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => dinl,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => WEA,
      WEB   =>'0'
      );


  addrb <= "00" & intaddrb when mode = 0 else
           pingaddr        when mode = 1 else
           retxaddr        when mode = 2 else
           arpaddr         when mode = 3 else
           eventaddr       when mode = 4 else
           "0000000000";

  -- DEBUGGING
  
  jtagin(63 downto 0) <= X"12345678" & X"0" &  LEN & X"00" & statedebug;
  jtagin(79 downto 64) <= "000000" & addrb;
  


  -----------------------------------------------------------------------------
  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;


        NEXTFRAME <= lnextframe;
        wea       <= DINEN;
        dinl      <= DIN;

        if lnextframe = '0' then
          addra   <= (others => '0');
        else
          if wea = '1' then
            addra <= addra + 1;
          end if;
        end if;


        if wea = '1' and addra = "00000000000" then
          len <= dinl(11 downto 0); 
        end if;
        
        if start = '1' and mode = 1 then
          PINGSTART <= '1';
        else
          PINGSTART <= '0';
        end if;

        if start = '1' and mode = 2 then
          RETXSTART <= '1';
        else
          RETXSTART <= '0';
        end if;

        if start = '1' and mode = 3 then
          ARPSTART <= '1';
        else
          ARPSTART <= '0';
        end if;

        if start = '1' and mode = 4 then
          EVENTSTART <= '1';
        else
          EVENTSTART <= '0';
        end if;


      end if;
    end if;
  end process main;

  fsm : process(CS, WEA, dob, ARPDONE, PINGDONE, RETXDONE, EVENTDONE)
  begin
    case CS is
      when none =>
        statedebug <= X"00"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= dinst;

      when dinst =>
        statedebug <= X"01"; 
        lnextframe <= '1';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        if wea = '1' then
          ns       <= dinw;
        else
          ns       <= dinst;
        end if;

      when dinw =>
        statedebug <= X"02"; 
        lnextframe <= '1';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
--        if wea = '0' and addra >= len(11 downto 1) then  -- DEBUGGING
        if wea = '0' and addra >= "0000001000" then
          ns       <= fstart;
        else
          ns       <= dinw;
        end if;

      when fstart =>
        statedebug <= X"03"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        if dob = X"0806" then
          ns       <= arppkt;
        elsif dob = X"0800" then
          ns       <= ipchka;
        else
          ns       <= nextpkt;
        end if;

      when nextpkt =>
        statedebug <= X"04"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= none;

      when arppkt =>
        statedebug <= X"05"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0B";
        ns         <= arpopchk;

      when arpopchk =>
        statedebug <= X"06"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0B";
        if dob = X"0001" then
          ns       <= arpqstart;
        else
          ns       <= nextpkt;
        end if;

      when arpqstart =>
        statedebug <= X"07"; 
        lnextframe <= '0';
        mode       <= 3;
        start      <= '1';
        intaddrb   <= X"00";
        ns         <= arpwait;

      when arpwait =>
        statedebug <= X"08"; 
        lnextframe <= '0';
        mode       <= 3;
        start      <= '0';
        intaddrb   <= X"00";
        if ARPDONE = '1' then
          ns       <= nextpkt;
        else
          ns       <= arpwait;
        end if;

        -------------------------------------------------------------------
        -------------------------------------------------------------------
        -- IP Check path
        -------------------------------------------------------------------
      when ipchka =>
        statedebug <= X"09"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0C";
        ns         <= icmpchk;

      when icmpchk =>
        statedebug <= X"0A"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"12";
        if dob(7 downto 0) = X"11" then
          ns       <= udpporta;
        elsif dob(7 downto 0) = X"01" then
          ns       <= echoreq;
        else
          ns       <= nextpkt;
        end if;

      when echoreq =>
        statedebug <= X"0B"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        if dob = X"0800" then
          ns       <= icmpstart;
        else
          ns       <= nextpkt;
        end if;

      when icmpstart =>
        statedebug <= X"0C"; 
        lnextframe <= '0';
        mode       <= 1;
        start      <= '1';
        intaddrb   <= X"00";
        ns         <= pingwait;

      when pingwait =>
        statedebug <= X"0D"; 
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        if PINGDONE = '1' then
          ns       <= nextpkt;
        else
          ns       <= pingwait;
        end if;

       ------------------------------------------------------------------------
        -- UDP Packets
        -----------------------------------------------------------------------

      when udpporta =>
        statedebug <= X"0E"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"13";
        ns         <= udpchk;
        
      when udpchk =>
        statedebug <= X"0F"; 
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"13";
        if dob = X"1130" then
          ns <= retxstarts;
        elsif dob = X"1388" then
          
          ns <= evtstart; 
        else
          ns <= nextpkt; 
        end if;
        
      when retxstarts =>
        statedebug <= X"10"; 
        lnextframe <= '0';
        mode       <= 2;
        start      <= '1';
        intaddrb   <= X"13";
        ns <= retxwait;
        
      when retxwait =>
        statedebug <= X"11"; 
        lnextframe <= '0';
        mode       <= 2;
        start      <= '0';
        intaddrb   <= X"13";
        if RETXDONE ='1' then
          ns <= nextpkt;
        else
          ns <= retxwait; 
        end if;
        
      when evtstart =>
        statedebug <= X"12"; 
        lnextframe <= '0';
        mode       <= 4;
        start      <= '1';
        intaddrb   <= X"13";
        ns <= evtwait;
        
      when evtwait =>
        statedebug <= X"13"; 
        lnextframe <= '0';
        mode       <= 4;
        start      <= '0';
        intaddrb   <= X"13";
        if EVENTDONE ='1' then
          ns <= nextpkt;
        else
          ns <= evtwait; 
        end if;
        
      when others =>
        statedebug <= X"14"; 
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= none;
    end case;

  end process fsm;

end Behavioral;

