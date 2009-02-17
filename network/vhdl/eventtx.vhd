library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library soma;
use SOMA.somabackplane.all;
use soma.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.netports;

entity eventtx is
  port (
    CLK         : in  std_logic;
    RESET       : in  std_logic;
    -- header fields
    MYMAC       : in  std_logic_vector(47 downto 0);
    MYIP        : in  std_logic_vector(31 downto 0);
    MYBCAST     : in  std_logic_vector(31 downto 0);
    -- event interface
    ECYCLE      : in  std_logic;
    EDTX        : in  std_logic_vector(7 downto 0);
    EATX        : in  std_logic_vector(somabackplane.N-1 downto 0);
    -- network tx IF
    DOUT        : out std_logic_vector(15 downto 0);
    DOEN        : out std_logic;
    GRANT       : in  std_logic;
    ARM         : out std_logic;
    PKTSUCCESS  : out std_logic;
    -- Retx write interface
    RETXID      : out std_logic_vector(13 downto 0) := (others => '0');
    RETXDOUT    : out std_logic_vector(15 downto 0);
    RETXADDR    : out std_logic_vector(8 downto 0);
    RETXDONE    : out std_logic;
    RETXPENDING : in  std_logic;
    RETXWE      : out std_logic
    );
end eventtx;

architecture Behavioral of eventtx is


-- input side
  signal hdrstart, hdrdone : std_logic := '0';

  signal douthdr  : std_logic_vector(15 downto 0) := (others => '0');
  signal weouthdr : std_logic                     := '0';
  signal addrhdr  : std_logic_vector(9 downto 0)  := (others => '0');

  signal doutbody  : std_logic_vector(15 downto 0) := (others => '0');
  signal weoutbody : std_logic                     := '0';
  signal addrbody  : std_logic_vector(8 downto 0)  := (others => '0');

  signal ebdone : std_logic := '0';

  signal datalen : std_logic_vector(8 downto 0) := (others => '0');
  signal wlen    : std_logic_vector(9 downto 0) := (others => '0');


  signal osel : integer range 0 to 2 := 0;

  signal dataaddr, idaddr : std_logic_vector(8 downto 0) := (others => '0');

  signal nextbuf : std_logic := '0';

  -- counters
  signal bits : std_logic_vector(95 downto 0) := (others => '0');

  signal ecnt : integer range 0 to 31 := 0;

  signal ebcnt, lebcnt : std_logic_vector(6 downto 0) := (others => '0');
  signal ebcntdone     : std_logic                    := '0';
  signal ecyclel       : std_logic                    := '0';

  signal id : std_logic_vector(31 downto 0) := (others => '0');

  signal idword : std_logic_vector(15 downto 0) := (others => '0');
  signal idsel  : std_logic                     := '0';

  signal nextpktsize : std_logic_vector(10 downto 0) := (others => '0');

  -- Buffer write interface
  signal dia   : std_logic_vector(15 downto 0) := (others => '0');
  signal wea   : std_logic                     := '0';
  signal addra : std_logic_vector(8 downto 0)  := (others => '0');

  type   instates is (none, firstchk, fullchk, hdrs, hdrw, idwrh, idwrl, flipbuf);
  signal ics, ins : instates := none;

  -- TX Mux output side

  signal odout         : std_logic_vector(15 downto 0) := (others => '0');
  signal olen          : std_logic_vector(15 downto 0) := (others => '0');
  signal oaddr         : std_logic_vector(8 downto 0)  := (others => '0');
  signal outen         : std_logic                     := '0';
  signal ovalid, onext : std_logic                     := '0';

  type   outstates is (none, armw, pktout, pktsuc, done);
  signal ocs, ons : outstates := none;

  -- retx output side
  signal redata : std_logic_vector(15 downto 0) := (others => '0');
  signal readdr : std_logic_vector(8 downto 0)  := (others => '0');
  signal reen   : std_logic                     := '0';

  signal revalid, renext : std_logic := '0';

  type   restates is (none, fifowr, fifodone, fifow, done);
  signal recs, rens : restates := none;


  -- components
  component udpheaderwriter
    port (
      CLK      : in  std_logic;
      SRCMAC   : in  std_logic_vector(47 downto 0);
      SRCIP    : in  std_logic_vector(31 downto 0);
      DESTMAC  : in  std_logic_vector(47 downto 0);
      DESTIP   : in  std_logic_vector(31 downto 0);
      DESTPORT : in  std_logic_vector(15 downto 0);
      START    : in  std_logic;
      WLEN     : in  std_logic_vector(9 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      WEOUT    : out std_logic;
      ADDR     : out std_logic_vector(9 downto 0);
      DONE     : out std_logic);
  end component;

  component eventbodywriter
    port (
      CLK    : in  std_logic;
      ECYCLE : in  std_logic;
      EDTX   : in  std_logic_vector(7 downto 0);
      EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
      DONE   : out std_logic;
      DOUT   : out std_logic_vector(15 downto 0);
      WEOUT  : out std_logic;
      ADDR   : out std_logic_vector(8 downto 0));
  end component;


  component eventtxpktfifo
    port (
      CLK      : in  std_logic;
      DIN      : in  std_logic_vector(15 downto 0);
      ADDRIN   : in  std_logic_vector(8 downto 0);
      WE       : in  std_logic;
      DONE     : in  std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      ADDROUT  : in  std_logic_vector(8 downto 0);
      VALID    : out std_logic;
      FIFONEXT : in  std_logic);
  end component;

  component bitcnt
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic_vector(95 downto 0);
      DOUT  : out std_logic_vector(6 downto 0);
      START : in  std_logic;
      DONE  : out std_logic
      );
  end component;

begin  -- Behavioral

  udpheaderwriter_inst : udpheaderwriter
    port map (
      CLK      => CLK,
      SRCMAC   => MYMAC,
      SRCIP    => MYIP,
      DESTIP   => MYBCAST,
      DESTMAC  => X"FFFFFFFFFFFF",
      DESTPORT => netports.EVENTTX,
      START    => hdrstart,
      WLEN     => wlen,
      DOUT     => douthdr,
      WEOUT    => weouthdr,
      ADDR     => addrhdr,
      DONE     => hdrdone);

  eventbodywriter_inst : eventbodywriter
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      EDTX   => EDTX,
      EATX   => EATX,
      DONE   => ebdone,
      DOUT   => doutbody,
      WEOUT  => weoutbody,
      ADDR   => addrbody);

  bits(somabackplane.N -1 downto 0) <= eatx;
  eventbitcnt : bitcnt
    port map (
      CLK   => CLK,
      DIN   => bits,
      DOUT  => lebcnt,
      START => ecyclel,
      DONE  => ebcntdone);

  -- combinationals, input side

  dia <= idword when osel = 0 else
         douthdr when osel = 1 else
         doutbody;

  wea <= '1' when osel = 0 else
         weouthdr when osel = 1
         else weoutbody;

  addra <= idaddr when osel = 0 else
           addrhdr(8 downto 0) when osel = 1 else
           (dataaddr + "000011000");

  idword <= id(15 downto 0) when idsel = '0'
            else id(31 downto 16);

  idaddr <= "000010111" when idsel = '0' else
            "000010110";

  wlen     <= ('0' & datalen) + "0000000010";
  dataaddr <= addrbody + datalen;

  nextpktsize <= ('0' & ebcnt & "000") + ("00" & datalen);

  PKTSUCCESS <= '1' when ocs = pktsuc else '0';
  main_input : process(CLK, RESET)
  begin
    if RESET = '1' then

    else
      if rising_edge(CLK) then
        ics <= ins;

        if ebcntdone = '1' then
          ebcnt <= lebcnt;
        end if;
        ecyclel <= ECYCLE;

        if nextbuf = '1' then
          datalen <= (others => '0');
        else
          if ebdone = '1' then
            datalen <= dataaddr;
          end if;
        end if;

        if nextbuf = '1' then
          ecnt <= 1;
        else
          if ebcntdone = '1' then
            ecnt <= ecnt + 1;
          end if;
        end if;

        if nextbuf = '1' then
          id <= id + 1;
        end if;
      end if;
    end if;
  end process main_input;


  input_fsm : process(ics, ebcntdone, ecnt, dataaddr, ebcnt, hdrdone)
  begin
    case ics is
      when none =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 2;
        idsel    <= '0';
        if ebcntdone = '1' then
          ins <= firstchk;
        else
          ins <= none;
        end if;

      when firstchk =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 2;
        idsel    <= '0';
        if ecnt = 1 then
          ins <= none;
        else
          ins <= fullchk;
        end if;

      when fullchk =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 2;
        idsel    <= '0';
        if ecnt = 26 or                 -- we are in the 26 ecycle, so there
          -- are 25 in the buffer
          (nextpktsize > "00111101000") then
          ins <= hdrs;
        else
          ins <= none;
        end if;

      when hdrs =>
        nextbuf  <= '0';
        hdrstart <= '1';
        osel     <= 1;
        idsel    <= '0';
        ins      <= hdrw;

      when hdrw =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 1;
        idsel    <= '0';
        if hdrdone = '1' then
          ins <= idwrh;
        else
          ins <= hdrw;
        end if;

      when idwrh =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 0;
        idsel    <= '1';
        ins      <= idwrl;

      when idwrl =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 0;
        idsel    <= '0';
        ins      <= flipbuf;

      when flipbuf =>
        nextbuf  <= '1';
        hdrstart <= '0';
        osel     <= 1;
        idsel    <= '0';
        ins      <= none;

      when others =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel     <= 1;
        idsel    <= '0';
        ins      <= none;

    end case;
  end process input_fsm;

  ----------------------------------------------------------------------------
  -- TX output Interface
  --------------------------------------------------------------------------  

  tx_pktfifo : eventtxpktfifo
    port map (
      CLK      => CLK,
      DIN      => dia,
      ADDRIN   => addra,
      WE       => wea,
      DONE     => nextbuf,
      DOUT     => odout,
      ADDROUT  => oaddr,
      VALID    => ovalid,
      FIFONEXT => onext);

  outen <= '1' when ocs = pktout else '0';
  ARM   <= '1' when ocs = armw   else '0';

  DOUT <= odout;

  main_txoutput : process(CLK)
  begin
    if rising_edge(CLK) then
      ocs <= ons;

      if ocs = armw then
        olen <= odout;
      end if;

      DOEN <= outen;

      if ocs = none then
        oaddr <= (others => '0');
      else
        if outen = '1' then
          oaddr <= oaddr + 1;
        end if;
      end if;

    end if;
  end process main_txoutput;



  output_fsm : process(ocs, ovalid, GRANT, olen, oaddr)
  begin
    case ocs is
      when none =>
        onext <= '0';
        if ovalid = '1' then
          ons <= armw;
        else
          ons <= none;
        end if;

      when armw =>
        onext <= '0';
        if grant = '1' then
          ons <= pktout;
        else
          ons <= armw;
        end if;

      when pktout =>
        onext <= '0';
        if olen(10 downto 1) = oaddr then
          
          ons <= pktsuc;
        else
          ons <= pktout;
        end if;
      when pktsuc =>
        onext <= '0';
        ons   <= done;
      when done =>
        onext <= '1';
        ons   <= none;
      when others =>
        onext <= '0';
        ons   <= none;
    end case;
  end process output_fsm;

  ----------------------------------------------------------------------------
  -- RETX Interface
  --------------------------------------------------------------------------  
  retx_pktfifo : eventtxpktfifo
    port map (
      CLK      => CLK,
      DIN      => dia,
      ADDRIN   => addra,
      WE       => wea,
      DONE     => nextbuf,
      DOUT     => redata,
      ADDROUT  => readdr,
      VALID    => revalid,
      FIFONEXT => renext);

  RETXDOUT <= redata;

  main_retxoutput : process(CLK)
  begin
    if rising_edge(CLK) then
      recs <= rens;
      if readdr = "000011000" then
        RETXID <= redata(13 downto 0);
      end if;

      RETXADDR <= readdr;
      RETXWE   <= reen;

      if renext = '1' then
        readdr <= (others => '0');
      else
        if reen = '1' then
          readdr <= readdr + 1;

        end if;

      end if;
    end if;

  end process main_retxoutput;

  retx_fsm : process(recs, revalid, readdr, RETXPENDING)
  begin
    case recs is
      when none =>
        reen     <= '0';
        renext   <= '0';
        RETXDONE <= '0';
        if revalid = '1' then
          rens <= fifowr;
        else
          rens <= none;
        end if;

      when fifowr =>
        reen     <= '1';
        renext   <= '0';
        RETXDONE <= '0';
        if readdr = "111111111" then
          rens <= fifodone;
        else
          rens <= fifowr;
        end if;

      when fifodone =>
        reen     <= '0';
        renext   <= '0';
        RETXDONE <= '1';
        if RETXPENDING = '1' then
          rens <= fifow;
        else
          rens <= fifodone;
        end if;

      when fifow =>
        reen     <= '0';
        renext   <= '0';
        RETXDONE <= '0';
        if RETXPENDING = '0' then
          rens <= done;
        else
          rens <= fifow;
        end if;

      when done =>
        reen     <= '0';
        renext   <= '1';
        RETXDONE <= '0';
        rens     <= none;

      when others =>
        reen     <= '0';
        renext   <= '1';
        RETXDONE <= '0';
        rens     <= none;

    end case;

  end process retx_fsm;

end Behavioral;
