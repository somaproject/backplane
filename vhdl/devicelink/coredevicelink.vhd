
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity coredevicelink is
  generic (
    N       : integer := 0;             -- number of ticks in input bit cycle
    -- needs to be at least 100k to acquire lock because DCMs are slow
    DCNTMAX : integer := 200000
    );     
  port (
    CLK       : in  std_logic;          -- should be a 50 MHz clock 
    RXBITCLK  : in  std_logic;          -- should be a 250 MHz clock
    TXHBITCLK : in  std_logic;          -- should be a 300 MHz clock
    TXWORDCLK : in  std_logic;          -- should be a 60 MHz clock
    RESET     : in  std_logic;
    TXDIN     : in  std_logic_vector(7 downto 0);
    TXKIN     : in  std_logic;
    TXIO_P    : out std_logic;
    TXIO_N    : out std_logic;
    RXIO_P    : in  std_logic;
    RXIO_N    : in  std_logic;
    RXDOUT    : out std_logic_vector(7 downto 0);
    RXKOUT    : out std_logic;
    DROPLOCK  : in  std_logic;
    LOCKED    : out std_logic;
    DEBUG     : out std_logic_vector(15 downto 0)
    );

end coredevicelink;


architecture Behavioral of coredevicelink is
  component deserialize

    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      DIN     : in  std_logic;
      BITCLK  : in  std_logic;
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


  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0));
  end component;


  component decode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      code_err : out std_logic;
      disp_err : out std_logic);
  end component;

  signal encdata, encdatal : std_logic_vector(9 downto 0) := (others => '0');
  signal oframe, ol, oll   : std_logic_vector(9 downto 0) := (others => '0');

  signal omux : integer range 0 to 1 := 0;

  signal dcntrst : std_logic                  := '0';
  signal dcnt    : integer range 0 to DCNTMAX := 0;

  signal rxio : std_logic := '0';

  signal rxword   : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordl  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordll : std_logic_vector(9 downto 0) := (others => '0');

  signal rxcodeerr : std_logic := '0';



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


  signal bitgoodcnt : integer range 0 to 15 := 0;
  
  type states is (none, snull, wnull, ssync, wsync, bitstart,
                  bitinc, bitwait, bitbad, bitgood, bitbackup,
                  wrdstart, wrdinc, wrdlock, wrddly, wrdcntr, validchk1, validchk2, validchk3, validchk4, sendlock, lock);

  signal cs, ns : states := none;

  signal oworden : std_logic                    := '0';
  signal outbits : std_logic_vector(1 downto 0) := (others => '0');

  signal bitcnt    : integer range 0 to 127 := 0;
  signal bitcntrst : std_logic              := '0';

  attribute DIFF_TERM                : string;
  attribute DIFF_TERM of RXIO_ibufds : label is "TRUE";
begin  -- Behavioral


  deser_inst : deserialize
    port map (
      CLK     => CLK,
      RESET   => RESET,
      BITCLK  => RXBITCLK,
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


  encoder : encode8b10b
    port map (
      DIN  => din,
      KIN  => kin,
      DOUT => encdata,
      CLK  => CLK);

  din <= TXDIN when cs /= sendlock else X"FE";
  kin <= TXKIN when cs /= sendlock else '1';

  decoder : decode8b10b
    port map (
      CLK      => CLK,
      DIN      => rxword,
      DOUT     => lrxdout,
      KOUT     => lrxkout,
      CODE_ERR => cerr,
      DISP_ERR => derr);


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

        -- out
        RXDOUT <= lrxdout;
        RXKOUT <= lrxkout;
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

        -- delay count for debugging
        if dlyrst = '1' then
          dlycnt <= X"00";
        else
          if dlyce = '1' then
            if dlyinc = '1' then
              dlycnt <= dlycnt + 1;
            else
              dlycnt <= dlycnt - 1;
            end if;
          end if;
        end if;

        DEBUG(7 downto 0) <= dlycnt; 
      end if;
    end if;

  end process main;




  fsm : process (cs, dcnt, rxwordl, rxwordll, lrxkout, lrxdout, rxcodeerr,
                 bitgoodcnt, droplock)
  begin  -- process fsm
    case cs is
      when none =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 1;
        dlyrst    <= '1';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= snull;
        
      when snull =>
        dcntrst   <= '1';
        llocked   <= '0';
        omux      <= 1;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '1';
        bitcntrst <= '1';
        ns        <= wnull;

      when wnull =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 1;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '1';
        bitcntrst <= '1';
        if dcnt = DCNTMAX - 1 then
          ns <= ssync;
        else
          ns <= wnull;
        end if;

      when ssync =>
        dcntrst   <= '1';
        llocked   <= '0';
        omux      <= 1;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= wsync;

      when wsync =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 1;
        dlyrst    <= '1';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if dcnt = DCNTMAX - 1 then
          ns <= bitstart;
        else
          ns <= wsync;
        end if;

      when bitstart =>
        dcntrst   <= '1';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '1';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= bitinc;

      when bitinc =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '1';
        dlyinc    <= '1';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if dcnt > 1000 then
          ns <= none;                   -- failed to establish lock
        else
          ns <= bitwait;
        end if;

      when bitwait =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '0';
        if rxwordl /= rxwordll then
          ns <= bitbad;                 -- failed to establish lock
        else
          if bitcnt = 63 then
            ns <= bitgood;
          else
            ns <= bitwait;
          end if;
        end if;
        
      when bitgood =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '0';
        if bitgoodcnt = 3 then
          ns <= bitbackup;
        else
          ns <= bitinc;
        end if;

      when bitbad =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '0';
        ns        <= bitinc;

      when bitbackup =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '1';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if bitgoodcnt = 2 then
          ns <= wrdstart;
        else
          ns <= bitbackup;
        end if;

      when wrdstart =>
        dcntrst   <= '1';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= wrdinc;
        
      when wrdinc =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '1';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= wrdlock;
        
      when wrdlock =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= wrddly;
        
      when wrddly =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '0';

        if bitcnt = 20 then
          ns <= wrdcntr;
        else
          ns <= wrddly;
        end if;


      when wrdcntr =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if dcnt > 2000 then
          ns <= none;
        else
          if (rxword = "1101000011") or (rxword = "0010111100") then
            ns <= validchk1;
          else
            ns <= wrdinc;
          end if;
        end if;
        
      when validchk1 =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
          ns <= validchk2;
        else
          ns <= none;
        end if;
        
      when validchk2 =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
          ns <= validchk3;
        else
          ns <= none;
        end if;
        
      when validchk3 =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
          ns <= validchk4;
        else
          ns <= none;
        end if;
        
      when validchk4 =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if lrxkout = '1' and lrxdout = X"1C" and rxcodeerr = '0' then
          ns <= sendlock;
        else
          ns <= none;
        end if;
        
      when sendlock =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= lock;

      when lock =>
        dcntrst   <= '0';
        llocked   <= '1';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        if rxcodeerr = '1' or DROPLOCK = '1' then
          ns <= none;
        else
          ns <= lock;
        end if;

      when others =>
        dcntrst   <= '0';
        llocked   <= '0';
        omux      <= 0;
        dlyrst    <= '0';
        dlyce     <= '0';
        dlyinc    <= '0';
        bitslip   <= '0';
        stoptx    <= '0';
        bitcntrst <= '1';
        ns        <= none;


    end case;
  end process fsm;

end Behavioral;

