
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
    DCNTMAX      : integer := 200000;
    DROPDURATION : integer := 20000000;
    SYNCDURATION : integer := 20000000;
    LOCKABORT    : integer := 200000);     
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
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0));
  end component;


  component coredldecode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      ce       : in  std_logic;
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
      DEBUGADDR : in  std_logic_vector(4 downto 0);
      WINPOS    : out std_logic_vector(4 downto 0);
      WINLEN    : out std_logic_vector(4 downto 0);
      -- delay interface
      DLYRST    : out std_logic;
      DLYINC    : out std_logic;
      DLYCE     : out std_logic;
      DIN       : in  std_logic_vector(9 downto 0)
      );
  end component;

  signal encdata, encdatal : std_logic_vector(9 downto 0) := (others => '0');
  signal oframe, ol, oll   : std_logic_vector(9 downto 0) := (others => '0');

  signal omux : integer range 0 to 1 := 0;

  signal dcntrst : std_logic                    := '0';
  signal dcnt    : integer range 0 to (DCNTMAX) := 0;

  signal rxio : std_logic := '0';

  signal rxword   : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordl  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordll : std_logic_vector(9 downto 0) := (others => '0');

  signal rxcodeerr : std_logic := '0';

  signal autolinkl    : std_logic := '0';
  signal attemptlinkl : std_logic := '0';

  signal decodece : std_logic := '0';

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

  signal din : std_logic_vector(7 downto 0) := (others => '0');
  signal kin : std_logic                    := '0';


  signal bitgoodcnt : integer range 0 to 31 := 0;
  
  type states is (none, snull, wnull, ssync, wsync, bitstart,
                  bitinc, bitwait, bitbad, bitgood, bitbackup,
                  wrdstart, wrdinc, wrdlock, wrddly, wrdcntr,
                  validchk1, validchk2, validchk3, validchk4, sendlock, lock);

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

  signal eyelockpos : std_logic_vector(4 downto 0) := (others => '0');
  signal eyelocklen : std_logic_vector(4 downto 0) := (others => '0');

  signal debugstate : std_logic_vector(7 downto 0) := (others => '0');
  
begin  -- Behavioral


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
      DIN  => din,
      KIN  => kin,
      DOUT => encdata,
      CLK  => CLK);

  din <= TXDIN when cs = lock else
         X"FE" when cs = sendlock else X"00";
  
  kin <= TXKIN when cs= lock else
         '1' when cs = sendlock else '0';

  decoder : coredldecode8b10b
    port map (
      CLK      => CLK,
      DIN      => rxword,
      DOUT     => lrxdout,
      KOUT     => lrxkout,
      CE       => decodece,
      CODE_ERR => cerr,
      DISP_ERR => derr);

  eyelock_inst : delaylock
    port map (
      CLK       => RXWORDCLK,
      START     => eyelockstart,
      DONE      => eyelockdone,
      LOCKED    => eyelocklocked,
      DEBUG     => open,
      DEBUGADDR => "00000",
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

        decodece <= not decodece;
        -- out
        if decodece = '0' then
          RXDOUT   <= lrxdout;
          RXKOUT   <= lrxkout;
          RXDOUTEN <= '1';
        else
          RXDOUTEN <= '0';
        end if;

        LOCKED <= llocked;

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
          debug(4 downto 0)  <= eyelockpos;
          debug(12 downto 8) <= eyelocklen;
        elsif debugaddr = X"01" then
          debug <= X"00" & debugstate(7 downto 0);
          
        elsif debugaddr = X"03" then
          debug <= "000000" & rxwordll;
        end if;

        DEBUGSTATEOUT <= debugstate;
        
      end if;
    end if;

  end process main;

  eyelockstart <= eyelockstartl or eyelockstartll;
  


  fsm : process (cs, dcnt, rxwordl, rxwordll, lrxkout, lrxdout, rxcodeerr,
                 autolinkl, attemptlinkl, eyelockdone, eyelocklocked,
                 bitgoodcnt, droplock)
  begin  -- process fsm
    case cs is
      when none =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"01";
        if attemptlink = '1' or autolink = '1' then
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
        debugstate <= X"02";
        ns         <= wnull;

      when wnull =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '1';
        bitcntrst  <= '1';
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
        debugstate <= X"04";
        ns         <= wsync;

      when wsync =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 1;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
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
        debugstate <= X"06";

        ns <= bitwait;

      when bitwait =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"07";
        if eyelockdone = '1' then
--          if eyelockpos = "00000" or eyelocklen = "11100" then
--            ns <= none;
--          else
          
          if eyelocklocked = '1' then
            ns <= wrdstart;
          else
            ns <= none;
          end if;
--          end if;
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
        debugstate <= X"08";
        ns         <= wrdinc;
        
      when wrdinc =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '1';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"09";
        ns         <= wrdlock;
        
      when wrdlock =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '1';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"0A";
        ns         <= wrddly;
        
      when wrddly =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '0';
        debugstate <= X"0B";

        if bitcnt = 20 then
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
        debugstate <= X"0C";
        if dcnt > LOCKABORT then
          ns <= none;
        else
          if (rxword = "1101000011") or (rxword = "0010111100") then
            ns <= validchk1;
          else
            ns <= wrdinc;
          end if;
        end if;
        
      when validchk1 =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"0D";
        --if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
        ns         <= validchk2;
--        else
--          ns <= none;
--        end if;
        
      when validchk2 =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '0';
        debugstate <= X"0E";
        if bitcnt = 20 then
          ns <= validchk3;
        else
          ns <= validchk2;
        end if;

      when validchk3 =>
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"0F";
        ns         <= validchk4;
        
      when validchk4 =>
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;

        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"10";
        if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
          ns <=  sendlock; --DEBUGGING, testing to see if something else
                      --  is causing the problem
        else
          ns <= none;
        end if;
        
      when sendlock =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"11";
        ns         <= lock;

      when lock =>
        dcntrst    <= '0';
        llocked    <= '1';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"12";
        if rxcodeerr = '1' or DROPLOCK = '1' then
          ns <= none;
        else
          ns <= lock;
        end if;

      when others =>
        dcntrst    <= '0';
        llocked    <= '0';
        omux       <= 0;
        bitslip    <= '0';
        stoptx     <= '0';
        bitcntrst  <= '1';
        debugstate <= X"00";
        ns         <= none;


    end case;
  end process fsm;

end Behavioral;

