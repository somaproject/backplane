
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity coredevicelink is
  generic (
    N            : integer := 0;        -- number of ticks in input bit cycle
    -- needs to be at least 100k to acquire lock because DCMs are slow
    DCNTMAX      : integer := 220000000;
    DROPDURATION : integer := 200000000;
    SYNCDURATION : integer := 200000000;
    LOCKABORT    : integer :=  1000000);     
  port (
    CLK           : in  std_logic;      -- should be a 50 MHz clock 
    RXBITCLK      : in  std_logic;      -- should be a 125 MHz clock
    RXWORDCLK     : in  std_logic;      -- should be a 25 Mhz clock
    TXHBITCLK     : in  std_logic;      -- should be a 300 MHz clock
    TXWORDCLK     : in  std_logic;      -- should be a 60 MHz clock
    RESET         : in  std_logic;
    AUTOLINK      : in  std_logic := '1';
    ATTEMPTLINK   : in  std_logic := '0';
    TXDIN         : in  std_logic_vector(7 downto 0);
    TXKIN         : in  std_logic;
    TXIO_P        : out std_logic;
    TXIO_N        : out std_logic;
    RXIO_P        : in  std_logic;
    RXIO_N        : in  std_logic;
    RXDOUT        : out std_logic_vector(7 downto 0);
    RXKOUT        : out std_logic := '0';
    RXDOUTEN      : out std_logic;
    DROPLOCK      : in  std_logic;
    LOCKED        : out std_logic;
    DEBUGADDR     : in  std_logic_vector(7 downto 0);
    DEBUG         : out std_logic_vector(15 downto 0);
    DEBUGSTATEOUT : out std_logic_vector(7 downto 0)
    );

end coredevicelink;


architecture Behavioral of coredevicelink is
  component deserialize

    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      DIN     : in  std_logic;
      BITCLK  : in  std_logic;
      WORDCLK : in  std_logic;
      DOUT    : out std_logic_vector(9 downto 0);
      DLYRST  : in  std_logic;
      DLYCE   : in  std_logic;
      DLYINC  : in  std_logic;
      BITSLIP : in  std_logic);

  end component;


  component serialize
    port (
      CLKA   : in  std_logic;
      CLKB   : in  std_logic;
      RESET  : in  std_logic;
      BITCLK : in  std_logic;
      DIN    : in  std_logic_vector(9 downto 0);
      DOUT   : out std_logic;
      STOPTX : in  std_logic
      );
  end component;


  component coredlencode8b10b
    port (
      din        : in  std_logic_vector(7 downto 0);
      kin        : in  std_logic;
      clk        : in  std_logic;
      dout       : out std_logic_vector(9 downto 0);
      ce         : in  std_logic;
      force_disp : in  std_logic;
      disp_in    : in  std_logic
      );
  end component;


  component coredldecode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      ce       : in  std_logic;
      sinit    : in  std_logic;
      code_err : out std_logic;
      disp_err : out std_logic);
  end component;


  component delaylock
    port (
      CLK       : in  std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      LOCKED    : out std_logic;
      DEBUG     : out std_logic;
      DEBUGADDR : in  std_logic_vector(5 downto 0);
      WINPOS    : out std_logic_vector(5 downto 0);
      WINLEN    : out std_logic_vector(5 downto 0);
      -- delay interface
      DLYRST    : out std_logic;
      DLYINC    : out std_logic;
      DLYCE     : out std_logic;
      DIN       : in  std_logic_vector(9 downto 0)
      );
  end component;

  signal encdata, encdatal : std_logic_vector(9 downto 0) := (others => '0');
  signal oframe, ol        : std_logic_vector(9 downto 0) := (others => '0');

  signal omux : integer range 0 to 1 := 1;

  signal dcntrst : std_logic                    := '0';
  signal dcnt    : integer range 0 to (DCNTMAX) := 0;

  signal rxio : std_logic := '0';

  signal rxword   : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordl  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordll : std_logic_vector(9 downto 0) := (others => '0');

  signal rxcodeerr : std_logic := '0';
  signal rxcodeerrl : std_logic := '0';

  signal autolinkl    : std_logic := '0';
  signal attemptlinkl : std_logic := '0';

  signal decodece      : std_logic := '0';
  signal decodecevalid : std_logic := '0';
  signal decodecevalidl : std_logic := '0';

  signal txencce, txencrst : std_logic := '0';
  signal rxdecce, rxdecrst : std_logic := '0';

  signal dlyrst : std_logic                    := '0';
  signal dlyce  : std_logic                    := '0';
  signal dlyinc : std_logic                    := '0';
  signal dlycnt : std_logic_vector(7 downto 0) := (others => '0');

  signal bitslip : std_logic := '0';

  signal lrxkout : std_logic                    := '0';
  signal lrxdout : std_logic_vector(7 downto 0) := (others => '0');

  signal cerr, derr : std_logic := '0';

  signal llocked : std_logic := '0';

  signal stoptx : std_logic                     := '0';
  signal sout   : std_logic_vector(11 downto 0) := (others => '0');

  signal txio : std_logic := '0';

  signal encdin : std_logic_vector(7 downto 0) := (others => '0');
  signal enckin : std_logic                    := '0';


  signal bitgoodcnt : integer range 0 to 31 := 0;
  
  type states is (none, snull, wnull, ssync, wsync, bitstart,
                  bitinc, bitwait, bitbad, bitgood, bitbackup,
                  wrdstart, wrdinc, wrdlock, wrddly, wrdcntr,
                  starttx, waitrxst,
                  sendlock, lock,
                  eyelockfail, wrdcntrfail, waitrxstfail, lockfail);

  signal cs, ns : states := none;

  signal oworden : std_logic                    := '0';
  signal outbits : std_logic_vector(1 downto 0) := (others => '0');

  signal bitcnt    : integer range 0 to 127 := 0;
  signal bitcntrst : std_logic              := '0';

  attribute DIFF_TERM                : string;
  attribute DIFF_TERM of RXIO_ibufds : label is "TRUE";

  -- eye lock signals
  signal eyelockstart                  : std_logic := '0';
  signal eyelockstartl, eyelockstartll : std_logic := '0';
  signal eyelockdone                   : std_logic := '0';
  signal eyelocklocked                 : std_logic := '0';

  signal eyelockpos : std_logic_vector(5 downto 0) := (others => '0');
  signal eyelocklen : std_logic_vector(5 downto 0) := (others => '0');

  signal debugstate : std_logic_vector(7 downto 0) := (others => '0');

  -- debug "fail" counters
  constant FAILCNTN : integer := 16;
  signal eyelockfailcnt : std_logic_vector(FAILCNTN-1 downto 0) := (others => '0');
  signal wrdcntrfailcnt : std_logic_vector(FAILCNTN-1 downto 0) := (others => '0');
  signal waitrxstfailcnt : std_logic_vector(FAILCNTN-1 downto 0) := (others => '0');
  signal lockfailcnt : std_logic_vector(FAILCNTN-1 downto 0) := (others => '0');

  signal wrdcntrfail_badword,
    lockfail_pos: std_logic_vector(15 downto 0) := X"1234";
  
begin  -- Behavioral

  decodecevalid <= decodece and rxdecce;

  deser_inst : deserialize
    port map (
      CLK     => CLK,
      RESET   => RESET,
      BITCLK  => RXBITCLK,
      WORDCLK => RXWORDCLK,
      DIN     => rxio,
      DOUt    => rxword,
      DLYRST  => DLYRST,
      DLYCE   => DLYCE,
      DLYINC  => DLYINC,
      BITSLIP => BITSLIP);

  ser_inst : serialize
    port map (
      CLKA   => CLK,
      CLKB   => TXWORDCLK,
      RESET  => RESET,
      BITCLK => TXHBITCLK,
      DIN    => ol,
      DOUT   => txio,
      stoptx => stoptx);


  encoder : coredlencode8b10b
    port map (
      DIN        => encdin,
      KIN        => enckin,
      DOUT       => encdata,
      CLK        => CLK,
      force_disp => txencrst,
      disp_in    => '1',
      ce         => txencce
      );

  encdin <= TXDIN when cs = lock else
            X"3c" when cs = starttx  else
            X"FE" when cs = sendlock else
            X"00";
  
  enckin <= TXKIN when cs = lock else
            '1' when cs = starttx  else
            '1' when cs = sendlock else
            '0';

  decoder : coredldecode8b10b
    port map (
      CLK      => CLK,
      DIN      => rxwordl,
      DOUT     => lrxdout,
      KOUT     => lrxkout,
      CE       => decodecevalid,
      SINIT    => rxdecrst,
      CODE_ERR => cerr,
      DISP_ERR => derr);

  eyelock_inst : delaylock
    port map (
      CLK       => RXWORDCLK,
      START     => eyelockstart,
      DONE      => eyelockdone,
      LOCKED    => eyelocklocked,
      DEBUG     => open,
      DEBUGADDR => "000000",
      WINPOS    => eyelockpos,
      WINLEN    => eyelocklen,
      DLYRST    => DLYRST,
      DLYINC    => DLYINC,
      DLYCE     => DLYCE,
      DIN       => rxword); 

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O  => TXIO_P,
      OB => TXIO_N,
      I  => txio
      );


  
  RXIO_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      DIFF_TERM  => true)
    port map (
      I  => RXIO_P,
      IB => RXIO_N,
      O  => rxio
      );


  
  rxcodeerr <= cerr or derr;

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        -- tx side
        encdatal <= encdata;            -- Debuggin
        --encdatal <= "0000000001"; 
        if omux = 0 then
          ol <= encdatal;
        elsif omux = 1 then
          ol <= (others => '0');
        else
          ol <= (others => '0');
        end if;

        if dcntrst = '1' then
          dcnt <= 0;
        else
          if dcnt = DCNTMAX - 1 then
            dcnt <= 0;
          else
            dcnt <= dcnt + 1;
          end if;
        end if;

        rxwordl  <= rxword;
        rxwordll <= rxwordl;

        autolinkl    <= AUTOLINK;
        attemptlinkl <= ATTEMPTLINK;
        if cs = starttx then
          decodece <= '0';
        else
          decodece <= not decodece;
        end if;

        -- out
        if decodece = '0' then
          RXDOUT   <= lrxdout;
          RXKOUT   <= lrxkout;
          RXDOUTEN <= '1';
        else
          RXDOUTEN <= '0';
        end if;

        LOCKED <= llocked;

        decodecevalidl <= decodecevalid; 
        if rxdecrst = '1' then          -- the error flag tends to be "sticky"
          -- coming out of the 8b/10b decoder
          rxcodeerrl <= '0';
        else
          if decodecevalidl = '1' then
            rxcodeerrl <= rxcodeerr;
          end if;
        end if; 
          
        -- bitcount
        if bitcntrst = '1' then
          bitcnt <= 0;
        else
          bitcnt <= bitcnt + 1;
        end if;

        if cs = bitstart or cs = bitbad then
          bitgoodcnt <= 0;
        else
          if cs = bitgood then
            bitgoodcnt <= bitgoodcnt + 1;
          else
            if cs = bitbackup then
              bitgoodcnt <= bitgoodcnt - 1;
            end if;
          end if;
        end if;

        if cs = bitstart then
          eyelockstartl <= '1';
        else
          eyelockstartl <= '0';
        end if;

        eyelockstartll <= eyelockstartl;
        if debugaddr = X"00" then
          debug(5 downto 0)  <= eyelockpos;
          debug(13 downto 8) <= eyelocklen;
        elsif debugaddr = X"01" then
          debug <= X"00" & debugstate(7 downto 0);
        elsif debugaddr = X"03" then
          debug <= cerr & derr & "0" & decodecevalid & "00" & rxwordl;
        elsif debugaddr = X"04" then
          debug <= eyelockfailcnt;
        elsif debugaddr = X"05" then
          debug <= wrdcntrfailcnt;
        elsif debugaddr = X"06" then
          debug <= waitrxstfailcnt;
        elsif debugaddr = X"07" then
          debug <= lockfailcnt;
        elsif debugaddr = X"08" then
          debug <= wrdcntrfail_badword; 
        elsif debugaddr = X"09" then
          debug <= lockfail_pos;  
        end if;

        DEBUGSTATEOUT <= debugstate;

        if cs = eyelockfail then
          eyelockfailcnt <= eyelockfailcnt + 1; 
        end if;

        if cs = wrdcntrfail then
          wrdcntrfailcnt <= wrdcntrfailcnt + 1;
          wrdcntrfail_badword(9 downto 0) <= rxwordl;
        end if;

        if cs = waitrxstfail then
          waitrxstfailcnt <= waitrxstfailcnt + 1; 
        end if;

        if cs = lockfail then
          lockfailcnt <= lockfailcnt + 1;
          lockfail_pos <= "00" & eyelocklen & "00" & eyelockpos; 
        end if;
        
      end if;
    end if;

  end process main;

  eyelockstart <= eyelockstartl or eyelockstartll;
  


  fsm : process (cs, dcnt, rxwordl, rxwordll, lrxkout, lrxdout, rxcodeerrl,
                 autolinkl, attemptlinkl, eyelockdone, eyelocklocked,
                 bitgoodcnt, droplock)
  begin  -- process fsm
    case cs is
      when none =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '1';
        bitcntrst  <= '1';
        txencce    <= '1';
        txencrst   <= '1';
        rxdecce    <= '1';
        rxdecrst   <= '1';
        debugstate <= X"01";
        if attemptlinkl = '1' or autolinkl = '1' then
          ns <= snull;
        else
          ns <= none;
        end if;

        
      when snull =>
        dcntrst    <= '1';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '1';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"02";
        ns         <= wnull;

      when wnull =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '1';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"03";
        if dcnt >= DROPDURATION then
          ns <= ssync;
        else
          ns <= wnull;
        end if;

      when ssync =>
        dcntrst    <= '1';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"04";
        ns         <= wsync;

      when wsync =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"05";
        if dcnt >= SYNCDURATION then
          ns <= bitstart;
        else
          ns <= wsync;
        end if;

      when bitstart =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '0';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"06";

        ns <= bitwait;

      when bitwait =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"07";
        if eyelockdone = '1' then
          if eyelocklocked = '1' then
            ns <= wrdstart;
          else
            ns <= eyelockfail;
          end if;
        else
          ns <= bitwait;
        end if;

      when wrdstart =>
        dcntrst    <= '1';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"08";
        ns         <= wrdinc;
        
      when wrdinc =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '1';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"09";
        ns         <= wrdlock;
        
      when wrdlock =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '1';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"0A";
        ns         <= wrddly;
        
      when wrddly =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '0';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"0B";

        if bitcnt = 10 then
          ns <= wrdcntr;
        else
          ns <= wrddly;
        end if;


      when wrdcntr =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"0C";
        if dcnt > LOCKABORT then
          ns <= wrdcntrfail;
        else
          if (rxword = "1011110000") then
            ns <= starttx;
          else
            ns <= wrdinc;
          end if;
        end if;
        
      when starttx =>
        dcntrst    <= '1';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '1';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"0D";
        ns         <= waitrxst;
        
        
      when waitrxst =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '1';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"0E";
        if dcnt > LOCKABORT then
          ns <= waitrxstfail;
        else
          if rxword = "0110000011" or rxword = "1001111100" then
            ns <= sendlock;
          else
            ns <= waitrxst;
          end if;
        end if;

      when sendlock =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '1';
        txencrst   <= '0';
        rxdecce    <= '1';
        rxdecrst   <= '0';
        debugstate <= X"11";
        ns         <= lock;
        
      when lock =>
        dcntrst    <= '0';
        llocked    <= '1';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '1';
        txencrst   <= '0';
        rxdecce    <= '1';
        rxdecrst   <= '0';
        debugstate <= X"14";
        if rxcodeerrl = '1' or DROPLOCK = '1' then
          ns <= lockfail;
        else
          ns <= lock;
        end if;

      when eyelockfail =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"00";
        ns         <= none;

      when wrdcntrfail =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"00";
        ns         <= none;

      when waitrxstfail =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"00";
        ns         <= none;

      when lockfail =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"00";
        ns         <= none;

      when others =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        txencce    <= '0';
        txencrst   <= '0';
        rxdecce    <= '0';
        rxdecrst   <= '0';
        debugstate <= X"00";
        ns         <= none;


    end case;
  end process fsm;

end Behavioral;

