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
  

  -- fsm
  type states is (none, dinst, dinw, fstart, nextpkt,
                  arppkt, arpopchk, arpqstart, arpwait,
                  ipchka, icmpchk, udpporta, udpchk, retxstarts, retxwait,
                  echoreq, icmpstart, pingwait);
  signal cs, ns : states := none;





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
        if wea = '0' then
          ns       <= fstart;
        else
          ns       <= dinw;
        end if;

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
          ns       <= nextpkt;
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
          ns       <= nextpkt;
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
          ns       <= nextpkt;
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
        if dob = X"1130" then
          ns <= retxstarts;
        else
          ns <= nextpkt; 
        end if;
        
      when retxstarts =>
        lnextframe <= '0';
        mode       <= 2;
        start      <= '1';
        intaddrb   <= X"13";
        ns <= retxwait;
        
      when retxwait =>
        lnextframe <= '0';
        mode       <= 2;
        start      <= '0';
        intaddrb   <= X"13";
        if RETXDONE ='1' then
          ns <= nextpkt;
        else
          ns <= retxwait; 
        end if;
        
      when others =>
        lnextframe <= '0';
        mode       <= 1;
        start      <= '0';
        intaddrb   <= X"00";
        ns         <= none;
    end case;

  end process fsm;

end Behavioral;

