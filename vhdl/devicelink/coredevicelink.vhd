
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity coredevicelink is
  generic (
    N            :     integer := 0);   -- number of ticks in input bit cycle
  port (
    CLK          : in  std_logic;
    RXBITCLK     : in  std_logic;
    TXHBITCLK    : in  std_logic;
    TXHBITCLK180 : in  std_logic;
    RESET        : in  std_logic;
    TXDIN        : in  std_logic_vector(7 downto 0);
    TXKIN        : in  std_logic;
    TXIO_P       : out std_logic;
    TXIO_N       : out std_logic;
    RXIO_P       : in  std_logic;
    RXIO_N       : in  std_logic;
    RXDOUT       : out std_logic_vector(7 downto 0);
    RXKOUT       : out std_logic;
    DROPLOCK     : in  std_logic;
    LOCKED       : out std_logic;
    STATE : out std_logic_vector(7 downto 0)
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

  signal dframe          : std_logic_vector(11 downto 0) := (others => '0');
  signal oframe, ol, oll : std_logic_vector(11 downto 0) := (others => '0');

  signal omux : integer range 0 to 2 := 0;

  signal dcntrst : std_logic                := '0';
  signal dcnt    : integer range 0 to 65535 := 0;

  signal rxio : std_logic := '0';

  signal rxword   : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordl  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordll : std_logic_vector(9 downto 0) := (others => '0');

  signal rxcodeerr : std_logic := '0';

  signal lstate : std_logic_vector(7 downto 0) := (others => '0'); 
                                                  
  signal dlyrst  : std_logic := '0';
  signal dlyce   : std_logic := '0';
  signal dlyinc  : std_logic := '0';
  signal bitslip : std_logic := '0';

  signal lrxkout : std_logic                    := '0';
  signal lrxdout : std_logic_vector(7 downto 0) := (others => '0');

  signal cerr, derr : std_logic := '0';

  signal llocked : std_logic := '0';

  signal sout : std_logic_vector(11 downto 0) := (others => '0');

  signal txio : std_logic := '0';

  signal din : std_logic_vector(7 downto 0) := (others => '0');
  signal kin : std_logic := '0';



  type states is (none, snull, wnull, ssync, wsync, bitstart, bitshift, sbitcntr, wbitcntr, wrdstart, wrdinc, wrdlock, wrddly, wrdcntr, validchk1, validchk2, validchk3, validchk4, sendlock, lock);

  signal cs, ns : states := none;


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

  encoder : encode8b10b
    port map (
      DIN  => din,
      KIN  => kin,
      DOUT => dframe(10 downto 1),
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


  FDDRRSE_inst : FDDRRSE
    port map (
      Q  => txio,                       -- Data output 
      C0 => TXHBITCLK,                  -- 0 degree clock input
      C1 => TXHBITCLK180,               -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => sout(1),                    -- Posedge data input
      D1 => sout(0),                    -- Negedge data input
      R  => '0',                        -- Synchronous reset input
      S  => '0'                         -- Synchronous preset input
      );


  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => TXIO_P,
      OB         => TXIO_N,
      I          => txio
      );

  RXIO_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      DIFF_TERM => True)
    port map (
      I          => RXIO_P,
      IB         => RXIO_N,
      O          => rxio
      );

  rxcodeerr <= cerr or derr;

  dframe(0)  <= '1';
  dframe(11) <= '0';
  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs     <= ns;
    elsif rising_edge(CLK) then
      cs     <= ns;

      STATE <= lstate;
      
      -- tx side
      oframe <= dframe;
      if omux = 0 then
        ol   <= oframe;
      elsif omux = 1 then
        ol   <= (others => '0');
      else
        ol   <= X"001";
      end if;

      if dcntrst = '1' then
        dcnt   <= 0;
      else
        if dcnt = 65535 then
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




    end if;

  end process main;

  txout             : process (TXHBITCLK)
    variable bitcnt : std_logic_vector(5 downto 0) := "000001";

  begin
    if rising_edge(TXHBITCLK) then
      bitcnt := bitcnt(0) & bitcnt(5 downto 1);

      if bitcnt(0) = '1' then
        oll  <= ol;
        sout <= oll;
      else
        sout <= "00" & sout(11 downto 2);
      end if;
    end if;
  end process txout;

  
  fsm : process (cs, dcnt, rxwordl, rxwordll, lrxkout, lrxdout, rxcodeerr, droplock)
  begin  -- process fsm
    case cs is
      when none  =>
        lstate <= X"00"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 1;
        dlyrst  <= '1';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= snull;
      when snull =>
        lstate <= X"01"; 
        dcntrst <= '1';
        llocked <= '0';
        omux    <= 1;
        dlyrst  <= '1';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wnull;

      when wnull =>
        lstate <= X"01"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 1;
        dlyrst  <= '1';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if dcnt = 10000 then
          ns    <= ssync;
        else
          ns    <= wnull;
        end if;

      when ssync =>
        lstate <= X"02"; 
        dcntrst <= '1';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '1';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wsync;

      when wsync =>
        lstate <= X"02"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '1';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if dcnt = 10000 then
          ns    <= bitstart;
        else
          ns    <= wsync;
        end if;

      when bitstart =>
        lstate <= X"04"; 
        dcntrst <= '1';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= bitshift;

      when bitshift =>
        lstate <= X"04"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '1';
        dlyinc  <= '1';
        bitslip <= '0';
        if dcnt = 64 then
          ns    <= none;
        else
          if rxwordl /= rxwordll then
            ns  <= sbitcntr;
          else
            ns  <= bitshift;
          end if;
        end if;

      when sbitcntr =>
        lstate <= X"08"; 
        dcntrst <= '1';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wbitcntr;

      when wbitcntr =>
        lstate <= X"08"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '1';
        dlyinc  <= '1';
        bitslip <= '0';
        if dcnt = N/2 then
          ns    <= wrdstart;
        else
          ns    <= wbitcntr;
        end if;

      when wrdstart =>
        lstate <= X"10"; 
        dcntrst <= '1';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wrdinc;
      when wrdinc   =>
        lstate <= X"10"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '1';
        ns      <= wrdlock;
      when wrdlock  =>
        lstate <= X"10"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wrddly;
      when wrddly   =>
        lstate <= X"10"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= wrdcntr;

      when wrdcntr   =>
        lstate <= X"10"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 2;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if dcnt > 44 then
          ns    <= none;
        else
          if rxword = "1101000110" then
            ns  <= validchk1;
          else
            ns  <= wrdinc;
          end if;
        end if;
      when validchk1 =>
        lstate <= X"20"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if lrxkout = '0' and lrxdout = X"00" and rxcodeerr = '0' then
          ns    <= validchk2;
        else
          ns    <= none;
        end if;
      when validchk2 =>
        lstate <= X"20"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if lrxkout = '0' and lrxdout = X"00" and rxcodeerr = '0' then
          ns    <= validchk3;
        else
          ns    <= none;
        end if;
      when validchk3 =>
        lstate <= X"20"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if lrxkout = '0' and lrxdout = X"00" and rxcodeerr = '0' then
          ns    <= validchk4;
        else
          ns    <= none;
        end if;
      when validchk4 =>
        lstate <= X"20"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if lrxkout = '0' and lrxdout = X"00" and rxcodeerr = '0' then
          ns    <= sendlock;
        else
          ns    <= none;
        end if;
      when sendlock =>
        lstate <= X"20"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns <= lock; 

      when lock      =>
        lstate <= X"40"; 
        dcntrst <= '0';
        llocked <= '1';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        if rxcodeerr = '1' or DROPLOCK = '1' then
          ns    <= none;
        else
          ns    <= lock;
        end if;

      when others =>
        lstate <= X"80"; 
        dcntrst <= '0';
        llocked <= '0';
        omux    <= 0;
        dlyrst  <= '0';
        dlyce   <= '0';
        dlyinc  <= '0';
        bitslip <= '0';
        ns      <= none;


    end case;
  end process fsm;

end Behavioral;

