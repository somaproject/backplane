library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.netports;

entity inputcontrol is
  port (
    CLK          : in  std_logic;
    RESET        : in  std_logic;
    NEXTFRAME    : out std_logic;
    DINEN        : in  std_logic;
    DIN          : in  std_logic_vector(15 downto 0);
    PKTDATA      : out std_logic_vector(15 downto 0);
    -- error counters
    CRCIOERR     : out std_logic;
    UNKNOWNETHER : out std_logic;
    UNKNOWNIP    : out std_logic;
    UNKNOWNUDP   : out std_logic;
    UNKNOWNARP   : out std_logic;

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
end inputcontrol;

architecture Behavioral of inputcontrol is


-- input signals
  signal lnextframe : std_logic := '0';

  signal addra : std_logic_vector(9 downto 0) := (others => '0');
  signal wea   : std_logic                    := '0';

  signal dinl  : std_logic_vector(15 downto 0) := (others => '0');
  signal lenin : std_logic_vector(15 downto 0) := (others => '0');

  signal web : std_logic := '0';

  signal crcreset, crcvalid, crcdone : std_logic := '0';
  signal crcvalidl                   : std_logic := '0';

  -- output
  signal intaddrb : std_logic_vector(7 downto 0)  := (others => '0');
  signal addrb    : std_logic_vector(9 downto 0)  := (others => '0');
  signal dob      : std_logic_vector(15 downto 0) := (others => '0');

  signal mode : integer range 0 to 5 := 0;

  signal start : std_logic := '0';

  signal len : std_logic_vector(11 downto 0) := (others => '0');

  -- crc timeout
  signal crccnt : integer range 0 to 31 := 0;


  -- fsm
  type states is (none, dinst, dinw, crcvfy, lenupd, fstart, protoread,
                  nextpkt, crcerr,
                  arppkt, arpopchk, arpqstart, arpwait,
                  ipchka, icmpchk, udpporta, udpchk, dretxst, dretxwait,
                  eretxst, eretxwait,
                  evtstart, evtwait,
                  echoreq, icmpstart, pingwait,
                  etherunk, ipunk, arpunk, udpunk
                  );
  signal cs, ns : states := none;

  component crcverify
    port (
      CLK      : in  std_logic;
      DIN      : in  std_logic_vector(15 downto 0);
      DINEN    : in  std_logic;
      RESET    : in  std_logic;
      CRCVALID : out std_logic;
      DONE     : out std_logic);
  end component;


begin  -- Behavioral

  PKTDATA  <= dob;
  lenin    <= X"0" & (len - 4);
  crcreset <= '1' when cs = none else '0';

  -- error status / signals


  CRCIOERR     <= '1' when cs = crcerr   else '0';
  UNKNOWNETHER <= '1' when cs = etherunk else '0';
  UNKNOWNIP    <= '1' when cs = ipunk    else '0';
  UNKNOWNARP   <= '1' when cs = arpunk   else '0';
  UNKNOWNUDP   <= '1' when cs = udpunk   else '0';


  crcverify_inst : crcverify
    port map (
      CLK      => CLK,
      DIN      => dinl,
      DINEN    => wea,
      RESET    => crcreset,
      CRCVALID => crcvalid,
      DONE     => crcdone);

  frame_buffer : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
    port map (
      DOA                 => open,
      DOB                 => dob,
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => dinl,
      DIB                 => lenin,
      DIPA                => "00",
      DIPB                => "00",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => wea,
      WEB                 => web
      );


  addrb <= "00" & intaddrb when mode = 0 else
           pingaddr        when mode = 1 else
           dretxaddr       when mode = 2 else
           arpaddr         when mode = 3 else
           eventaddr       when mode = 4 else
           ERETXADDR       when mode = 5 else
           "0000000000";

  -- DEBUGGING

  
  web       <= '1' when cs = lenupd else '0';
  crcvalidl <= crcvalid;

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
          DRETXSTART <= '1';
        else
          DRETXSTART <= '0';
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

        if start = '1' and mode = 5 then
          ERETXSTART <= '1';
        else
          ERETXSTART <= '0';
        end if;

        if cs = crcvfy then
          crccnt <= crccnt +1;
        else
          crccnt <= 0;
        end if;
      end if;
    end if;
  end process main;

  fsm : process(CS, WEA, dob, ARPDONE, PINGDONE, DRETXDONE,
                ERETXDONE, EVENTDONE, crcvalid, crccnt, crcdone)
  begin
    case CS is
      when none =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= dinst;

      when dinst =>
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
        lnextframe <= '1';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        if addra >= len(11 downto 1) then
          ns       <= crcvfy;
        else
          ns       <= dinw;
        end if;

      when crcvfy =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        if crccnt = 14 then             -- CRC validation timeout check
          ns <= crcerr;
        else
          if crcdone = '1' then
            if crcvalidl = '1' then
              ns <= lenupd;
            else
              ns <= crcerr;
            end if;
          else
            ns   <= crcvfy;
          end if;
        end if;
        
      when crcerr =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        ns         <= nextpkt;

      when lenupd =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= protoread;

      when protoread =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        ns         <= fstart;

      when fstart =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"07";
        if dob = X"0806" then
          ns       <= arppkt;
        elsif dob = X"0800" then
          ns       <= ipchka;
        else
          ns       <= etherunk;
        end if;

      when nextpkt =>
        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= none;

      when arppkt =>

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0B";
        ns         <= arpopchk;

      when arpopchk =>

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0B";
        if dob = X"0001" then
          ns       <= arpqstart;
        else
          ns       <= arpunk;
        end if;

      when arpqstart =>

        lnextframe <= '0';
        mode       <= 3;
        start      <= '1';
        intaddrb   <= X"00";
        ns         <= arpwait;

      when arpwait =>

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

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"0C";
        ns         <= icmpchk;

      when icmpchk =>

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"12";
        if dob(7 downto 0) = X"11" then
          ns       <= udpporta;
        elsif dob(7 downto 0) = X"01" then
          ns       <= echoreq;
        else
          ns       <= ipunk;
        end if;

      when echoreq =>

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

        lnextframe <= '0';
        mode       <= 1;
        start      <= '1';
        intaddrb   <= X"00";
        ns         <= pingwait;

      when pingwait =>

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

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"13";
        ns         <= udpchk;

      when udpchk =>

        lnextframe <= '0';
        mode       <= 0;
        start      <= '0';
        intaddrb   <= X"13";
        if dob = netports.DATARETXREQ then
          ns       <= dretxst;
        elsif dob = netports.EVENTRETXREQ then
          ns       <= eretxst;
        elsif dob = netports.EVENTRX then
          ns       <= evtstart;
        else
          ns       <= udpunk;
        end if;

      when dretxst =>

        lnextframe <= '0';
        mode       <= 2;
        start      <= '1';
        intaddrb   <= X"13";
        ns         <= dretxwait;

      when dretxwait =>

        lnextframe <= '0';
        mode       <= 2;
        start      <= '0';
        intaddrb   <= X"13";
        if DRETXDONE = '1' then
          ns       <= nextpkt;
        else
          ns       <= dretxwait;
        end if;

      when eretxst =>
        lnextframe <= '0';
        mode       <= 5;
        start      <= '1';
        intaddrb   <= X"13";
        ns         <= eretxwait;

      when eretxwait =>
        lnextframe <= '0';
        mode       <= 5;
        start      <= '0';
        intaddrb   <= X"13";
        if ERETXDONE = '1' then
          ns       <= nextpkt;
        else
          ns       <= eretxwait;
        end if;

      when evtstart =>
        lnextframe <= '0';
        mode       <= 4;
        start      <= '1';
        intaddrb   <= X"13";
        ns         <= evtwait;

      when evtwait =>
        lnextframe <= '0';
        mode       <= 4;
        start      <= '0';
        intaddrb   <= X"13";
        if EVENTDONE = '1' then
          ns       <= nextpkt;
        else
          ns       <= evtwait;
        end if;

      when etherunk =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= nextpkt;

      when ipunk =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= nextpkt;

      when arpunk =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= nextpkt;

      when udpunk =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= nextpkt;

      when others =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= none;
    end case;

  end process fsm;

end Behavioral;

