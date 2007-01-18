library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity netcontrol is
  generic (
    DEVICE      :     std_logic_vector(7 downto 0) := X"01";
    CMDCNTQUERY :     std_logic_vector(7 downto 0) := X"40";
    CMDCNTRST   :     std_logic_vector(7 downto 0) := X"41";
    CMDNETWRITE :     std_logic_vector(7 downto 0) := X"42";
    CMDNETQUERY :     std_logic_vector(7 downto 0) := X"43"
    );
  port (
    CLK         : in  std_logic;
    RESET       : in  std_logic;
    -- standard event-bus interface
    ECYCLE      : in  std_logic;
    EDTX        : in  std_logic_vector(7 downto 0);
    EATX        : in  std_logic_vector(somabackplane.N - 1 downto 0);
    EARX        : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRX        : out std_logic_vector(7 downto 0);
    EDSELRX     : in  std_logic_vector(3 downto 0);
    -- tx counter input
    TXPKTLENEN  : in  std_logic;
    TXPKTLEN    : in  std_logic_vector(15 downto 0);
    TXCHAN      : in  std_logic_vector(2 downto 0);
    -- other counters
    RXIOCRCERR  : in  std_logic;
    -- output network control settings
    MYMAC       : out std_logic_vector(47 downto 0);
    MYBCAST     : out std_logic_vector(31 downto 0);
    MYIP        : out std_logic_vector(31 downto 0)

    );

end netcontrol;

architecture Behavioral of netcontrol is

  -- input from event buffer
  signal eoutd  : std_logic_vector(15 downto 0) := (others => '0');
  signal eouta  : std_logic_vector(2 downto 0)  := (others => '0');
  signal evalid : std_logic                     := '0';
  signal enext  : std_logic                     := '0';

  -- input data
  signal srcl     : std_logic_vector(7 downto 0)  := (others => '0');
  signal addr     : std_logic_vector(15 downto 0) := (others => '0');
  signal dataword : std_logic_vector(47 downto 0) := (others => '0');
  signal cmd      : std_logic_vector(7 downto 0)  := (others => '0');


  -- counter selection
  signal cntval : std_logic_vector(47 downto 0) := (others => '0');
  signal cntsel : std_logic_vector(4 downto 0)  := (others => '0');
  signal cntpos : std_logic_vector(4 downto 0)  := (others => '0');

  signal bcastdelay : std_logic_vector(15 downto 0) := (others => '1');

  -- counters

  signal rxiocrcerrcnt : std_logic_vector(47 downto 0) := (others => '0');

  signal txch0len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch0cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch0rst : std_logic                     := '0';

  signal txch1len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch1cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch1rst : std_logic                     := '0';

  signal txch2len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch2cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch2rst : std_logic                     := '0';

  signal txch3len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch3cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch3rst : std_logic                     := '0';

  signal txch4len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch4cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch4rst : std_logic                     := '0';

  signal txch5len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch5cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch5rst : std_logic                     := '0';

  signal txch6len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch6cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch6rst : std_logic                     := '0';

  signal txch7len : std_logic_vector(47 downto 0) := (others => '0');
  signal txch7cnt : std_logic_vector(47 downto 0) := (others => '0');
  signal txch7rst : std_logic                     := '0';

  -- network settings
  signal netsetting : std_logic_vector(47 downto 0) := (others => '0');
  signal mac        : std_logic_vector(47 downto 0) := (others => '0');
  signal bcast      : std_logic_vector(31 downto 0) := (others => '0');
  signal ip         : std_logic_vector(31 downto 0) := (others => '0');

  signal netsettyp : std_logic_vector(1 downto 0) := (others => '0');

  -- events
  signal countervalevt : std_logic_vector(95 downto 0) := (others => '0');
  signal netsettingevt : std_logic_vector(95 downto 0) := (others => '0');
  signal eosel         : integer range 0 to 2          := 0;

  -- event output
  signal bcastsel, bcastval : std_logic                      := '0';
  signal learx              : std_logic_vector(N-1 downto 0) := (others => '0');
  signal edrxall            : std_logic_vector(95 downto 0)  := (others => '0');
  signal edrxin             : std_logic_vector(95 downto 0)  := (others => '0');
  signal cntrsten           : std_logic                      := '0';

  -- states
  type states is (none, cmdchk, ldaddr, ldword1, ldword2, ldword3,
                  cntbcast, cntbcw, evtdone, cntqury, cntreset,
                  netwrite, netwait);

  signal cs, ns : states := none;


  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;


  component txcounter
    port (
      CLK      : in  std_logic;
      PKTLENEN : in  std_logic;
      PKTLEN   : in  std_logic_vector(15 downto 0);
      TXCHAN   : in  std_logic_vector(2 downto 0);
      -- Channel 0
      CH0LEN   : out std_logic_vector(47 downto 0);
      CH0CNT   : out std_logic_vector(47 downto 0);
      CH0RST   : in  std_logic;
      -- Channel 1
      CH1LEN   : out std_logic_vector(47 downto 0);
      CH1CNT   : out std_logic_vector(47 downto 0);
      CH1RST   : in  std_logic;
      -- Channel 2
      CH2LEN   : out std_logic_vector(47 downto 0);
      CH2CNT   : out std_logic_vector(47 downto 0);
      CH2RST   : in  std_logic;
      -- Channel 3
      CH3LEN   : out std_logic_vector(47 downto 0);
      CH3CNT   : out std_logic_vector(47 downto 0);
      CH3RST   : in  std_logic;
      -- Channel 4
      CH4LEN   : out std_logic_vector(47 downto 0);
      CH4CNT   : out std_logic_vector(47 downto 0);
      CH4RST   : in  std_logic;
      -- Channel 5
      CH5LEN   : out std_logic_vector(47 downto 0);
      CH5CNT   : out std_logic_vector(47 downto 0);
      CH5RST   : in  std_logic;
      -- Channel 6
      CH6LEN   : out std_logic_vector(47 downto 0);
      CH6CNT   : out std_logic_vector(47 downto 0);
      CH6RST   : in  std_logic;
      -- Channel 7
      CH7LEN   : out std_logic_vector(47 downto 0);
      CH7CNT   : out std_logic_vector(47 downto 0);
      CH7RST   : in  std_logic
      );

  end component;



begin  -- Behavioral

  rxeventfifo_inst: rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      EOUTD  => eoutd,
      EOUTA  => eouta,
      EVALID => evalid,
      ENEXT  => enext); 
    
  txcounter_inst : txcounter
    port map (
      CLK      => CLK,
      PKTLENEN => TXPKTLENEN,
      PKTLEN   => TXPKTLEN,
      TXCHAN   => TXCHAN,
      CH0LEN   => txch0len,
      CH0CNT   => txch0cnt,
      CH0RST   => txch0rst,
      CH1LEN   => txch1len,
      CH1CNT   => txch1cnt,
      CH1RST   => txch1rst,
      CH2LEN   => txch2len,
      CH2CNT   => txch2cnt,
      CH2RST   => txch2rst,
      CH3LEN   => txch3len,
      CH3CNT   => txch3cnt,
      CH3RST   => txch3rst,
      CH4LEN   => txch4len,
      CH4CNT   => txch4cnt,
      CH4RST   => txch4rst,
      CH5LEN   => txch5len,
      CH5CNT   => txch5cnt,
      CH5RST   => txch5rst,
      CH6LEN   => txch6len,
      CH6CNT   => txch6cnt,
      CH6RST   => txch6rst,
      CH7LEN   => txch7len,
      CH7CNT   => txch7cnt,
      CH7RST   => txch7rst);

  cntval <= X"0123456789AB" when cntsel = "00000" else
            rxiocrcerrcnt   when cntsel = "00001" else
            txch0len        when cntsel = "10000" else
            txch0cnt        when cntsel = "10001" else
            txch1len        when cntsel = "10010" else
            txch1cnt        when cntsel = "10011" else
            txch2len        when cntsel = "10100" else
            txch2cnt        when cntsel = "10101" else
            txch3len        when cntsel = "10110" else
            txch3cnt        when cntsel = "10111" else
            txch4len        when cntsel = "11000" else
            txch4cnt        when cntsel = "11001" else
            txch5len        when cntsel = "11010" else
            txch5cnt        when cntsel = "11011" else
            txch6len        when cntsel = "11100" else
            txch6cnt        when cntsel = "11101" else
            txch7len        when cntsel = "11110" else
            txch7cnt        when cntsel = "11111" else
            X"000000000000";

  EDRX <= edrxall(7 downto 0)   when EDSELRX = X"1" else
          edrxall(15 downto 8)  when EDSELRX = X"0" else
          edrxall(23 downto 16) when EDSELRX = X"3" else
          edrxall(31 downto 24) when EDSELRX = X"2" else
          edrxall(39 downto 32) when EDSELRX = X"5" else
          edrxall(47 downto 40) when EDSELRX = X"4" else
          edrxall(55 downto 48) when EDSELRX = X"7" else
          edrxall(63 downto 56) when EDSELRX = X"6" else
          edrxall(71 downto 64) when EDSELRX = X"9" else
          edrxall(79 downto 72) when EDSELRX = X"8" else
          edrxall(87 downto 80) when EDSELRX = X"B" else
          edrxall(95 downto 88);

  cntrsten <= '1' when cs = cntreset else '0';

  txch0rst <= cntrsten when dataword(32) = '1' else '0';
  txch1rst <= cntrsten when dataword(33) = '1' else '0';
  txch2rst <= cntrsten when dataword(34) = '1' else '0';
  txch3rst <= cntrsten when dataword(35) = '1' else '0';
  txch4rst <= cntrsten when dataword(36) = '1' else '0';
  txch5rst <= cntrsten when dataword(37) = '1' else '0';
  txch6rst <= cntrsten when dataword(38) = '1' else '0';
  txch7rst <= cntrsten when dataword(39) = '1' else '0';

  ENEXT <= '1' when cs = evtdone else '0';

  cntsel     <= cntpos          when bcastsel = '1'   else addr(4 downto 0);
  netsettyp  <= addr(1 downto 0);
  netsetting <= mac             when netsettyp = "00" else
                bcast & X"0000" when netsettyp = "01" else
                ip & X"0000"    when netsettyp = "10" else
                X"000000000000";

  MYMAC   <= mac;
  MYBCAST <= bcast;
  MYIP    <= ip;

  edrxin <= countervalevt when eosel = 0 else
            netsettingevt when eosel = 1 else
            (others => '0');


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;


      -- output events
      if ECYCLE = '1' then
        edrxall <= edrxin;
        earx    <= learx;
      end if;

      -- load input values
      if cs = cmdchk then
        cmd  <= EOUTD(15 downto 8);
        srcl <= EOUTD(7 downto 0);
      end if;

      if cs = ldaddr then
              addr <= EOUTD;
      end if;

      if cs = ldword1 then
        dataword(47 downto 32) <= EOUTD;
      end if;

      if cs = ldword2 then
        dataword(31 downto 16) <= EOUTD;
      end if;

      if cs = ldword3 then
        dataword(15 downto 0) <= EOUTD;
      end if;


      -- counter periodic broadcast
      if cs = cntbcast then
        cntpos       <= cntpos + 1;
        bcastdelay   <= X"FFFF";
      else
        if bcastdelay /= X"0000" then
          bcastdelay <= bcastdelay -1;
        end if;
      end if;

      -- network id update

      if cs = netwrite then
        if addr = X"0000" then
          mac   <= dataword;
        elsif addr = X"0001" then
          bcast <= dataword(47 downto 16);
        elsif addr = X"0002" then
          bcast <= dataword(47 downto 16);
        end if;
      end if;
    end if;
  end process main;


  fsm : process(cs, bcastdelay, evalid, eoutd, ecycle)
  begin
    case cs is
      when none =>
        EOUTA    <= "000";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        if bcastdelay = X"0000" then
          ns     <= cntbcast;
        else
          if EVALID = '1' then
            ns   <= cmdchk;
          else
            ns   <= none;
          end if;
        end if;

      when cmdchk =>
        EOUTA    <= "001";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        if EOUTD(15 downto 8) = CMDCNTQUERY or
          EOUTD(15 downto 8) = CMDCNTRST or
          EOUTD(15 downto 8) = CMDNETWRITE or
          EOUTD(15 downto 8) = CMDNETQUERY then
          ns     <= ldaddr;
        else
          ns     <= evtdone;
        end if;

      when ldaddr =>
        EOUTA    <= "010";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= ldword1;

      when ldword1 =>
        EOUTA    <= "011";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= ldword2;

      when ldword2 =>
        EOUTA    <= "100";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= ldword3;

      when ldword3 =>
        EOUTA    <= "101";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        if cmd = CMDCNTQUERY then
          ns     <= cntqury;
        elsif cmd = CMDCNTRST then
          ns     <= cntreset;
        elsif cmd = cmdnetwrite then
          ns     <= netwrite;
        elsif cmd = cmdnetquery then
          ns     <= netwait;
        else
          ns     <= evtdone;
        end if;

      when cntqury =>
        EOUTA    <= "000";
        bcastsel <= '0';
        bcastval <= '0';
        eosel    <= 0;
        if ECYCLE = '1' then
          ns     <= evtdone;
        else
          ns     <= cntqury;
        end if;

      when cntreset =>
        EOUTA    <= "000";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= evtdone;

      when netwrite =>
        EOUTA    <= "000";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= netwait;

      when netwait =>
        EOUTA    <= "000";
        bcastsel <= '0';
        bcastval <= '0';
        eosel    <= 1;
        if ECYCLE = '1' then
          ns     <= evtdone;
        else
          ns     <= netwait;
        end if;

      when cntbcast =>
        EOUTA    <= "000";
        bcastsel <= '0';
        bcastval <= '0';
        eosel    <= 1;
        ns       <= cntbcw;


      when cntbcw =>
        EOUTA    <= "000";
        bcastsel <= '1';
        bcastval <= '1';
        eosel    <= 0;
        if ECYCLE = '1' then
          ns     <= evtdone;
        else
          ns     <= cntbcw;
        end if;

      when evtdone =>
        EOUTA    <= "000";
        bcastsel <= '0';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= none;

      when others =>
        EOUTA    <= "000";
        bcastsel <= '1';
        bcastval <= '0';
        eosel    <= 0;
        ns       <= none;

    end case;


  end process fsm;
end Behavioral;
