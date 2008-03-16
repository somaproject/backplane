
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity devicelink is
  port (
    TXCLKIN    : in  std_logic;
    TXLOCKED   : in  std_logic;
    TXDIN      : in  std_logic_vector(9 downto 0);
    TXDOUT     : out std_logic_vector(7 downto 0);
    TXKOUT     : out std_logic;
    CLK        : out std_logic;
    CLK2X      : out std_logic;
    RESET      : out std_logic;
    RXDIN      : in  std_logic_vector(7 downto 0);
    RXKIN      : in  std_logic;
    RXIO_P     : out std_logic;
    RXIO_N     : out std_logic;
    DEBUGSTATE : out std_logic_vector(3 downto 0);
    DECODEERR  : out std_logic
    );

end devicelink;

architecture Behavioral of devicelink is

  signal nottxlocked                   : std_logic := '0';
  signal dcmlocked                     : std_logic := '0';
  signal txclkint, txclk               : std_logic := '0';
  signal rxhbitclk, rxhbitclkint       : std_logic := '0';
  signal rxhbitclk180, rxhbitclk180int : std_logic := '0';
  signal rst                           : std_logic := '0';


  signal txdinl, txdinll : std_logic_vector(9 downto 0) := (others => '0');
  signal ltxdout         : std_logic_vector(7 downto 0) := (others => '0');

  signal cerr    : std_logic := '0';
  signal derr    : std_logic := '0';
  signal ltxkout : std_logic := '0';

  signal rxdinl : std_logic_vector(7 downto 0) := (others => '0');
  signal rxkinl : std_logic                    := '0';
  signal dsel   : std_logic                    := '0';

  signal DIN : std_logic_vector(7 downto 0) := (others => '0');
  signal kin : std_logic                    := '0';

  signal ol, oll : std_logic_vector(9 downto 0) := (others => '0');

  signal forceerr     : std_logic                     := '0';
  signal txcodeerr    : std_logic                     := '0';
  signal txcodeerrreg : std_logic_vector(63 downto 0) := (others => '1');

  signal sout : std_logic_vector(9 downto 0) := (others => '0');

  signal rxio : std_logic := '0';

  signal outbits     : std_logic_vector(1 downto 0) := (others => '0');
  signal ldebugstate : std_logic_vector(3 downto 0) := (others => '0');


  type states is (none, sendsync, lock, unlocked);
  signal cs, ns : states := none;

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


begin  -- Behavioral

  encoder : encode8b10b
    port map (
      DIN  => din,
      KIN  => kin,
      DOUT => ol,
      CLK  => txclk);

  decoder : decode8b10b
    port map (
      CLK      => txclk,
      DIN      => txdinl,
      DOUT     => ltxdout,
      KOUT     => ltxkout,
      CODE_ERR => cerr,
      DISP_ERR => derr);

  nottxlocked <= TXLOCKED;
  rst         <= not dcmlocked;

  RESET <= rst;
  txclkdcm : dcm generic map (
    CLKIN_PERIOD       => 20.0,
    CLKFX_DIVIDE       => 1,
    CLKFX_MULTIPLY     => 5,
    DLL_FREQUENCY_MODE => "LOW",
    DFS_FREQUENCY_MODE => "HIGH")
    port map (
      CLKIN            => TXCLKIN,
      CLKFB            => txclk,
      RST              => nottxlocked,
      PSEN             => '0',
      CLK0             => txclkint,
      CLK2x            => CLK2X,
      CLKFX            => rxhbitclkint,
      CLKFX180         => rxhbitclk180int,
      LOCKED           => dcmlocked);

  txclk_bufg : BUFG port map (
    O => txclk,
    I => txclkint);

  CLK <= txclk;

  rxhbitclk_bufg : BUFG port map (
    O => rxhbitclk,
    I => rxhbitclkint);

  rxhbitclk180_bufg : BUFG port map (
    O => rxhbitclk180,
    I => rxhbitclk180int);


  DIN <= rxdinl when dsel = '0' else X"1C";
  KIN <= rxkinl when dsel = '0' else '1';


  txcodeerr <= cerr or derr;

  DECODEERR  <= txcodeerr;
  DEBUGSTATE <= ldebugstate;

  FDDRRSE_inst : FDDRRSE
    port map (
      Q  => rxio,                       -- Data output 
      C0 => RXHBITCLK,                  -- 0 degree clock input
      C1 => RXHBITCLK180,               -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => sout(1),                    -- Posedge data input
      D1 => sout(0),                    -- Negedge data input
      R  => '0',                        -- Synchronous reset input
      S  => '0'                         -- Synchronous preset input
      );


  RXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => RXIO_P,
      OB         => RXIO_N,
      I          => rxio
      );

  main : process (txclk, rst)
  begin  -- process main
    if rst = '1' then                   -- asynchronous reset

      cs           <= none;
      txcodeerrreg <= (others => '1');



    else
      if rising_edge(txclk) then
        cs <= ns;

        rxdinl <= RXDIN;
        rxkinl <= RXKIN;

        txdinl  <= TXDIN;
        txdinll <= txdinl;
        TXDOUT  <= ltxdout;
        TXKOUT  <= ltxkout;

        if forceerr = '0' then
          oll <= ol;
        else
          oll <= "0000000000";
        end if;

        txcodeerrreg <= (txcodeerrreg(62 downto 0) & txcodeerr);

      end if;
    end if;
  end process main;

  rxclkproc         : process(rxhbitclk)
    variable bitreg : std_logic_vector(4 downto 0) := "00001";

  begin
    if rising_edge(rxhbitclk) then
      bitreg := bitreg(0) & bitreg(4 downto 1);
      if bitreg(0) = '1' then
        sout <= oll;
      else
        sout <= "00" & sout(9 downto 2);
      end if;

    end if;

  end process rxclkproc;

  fsm : process (cs, ltxkout, ltxdout, txcodeerr)
  begin
    case cs is
      when none     =>
        dsel        <= '1';
        forceerr    <= '0';
        ldebugstate <= "0000";
        ns          <= sendsync;
      when sendsync =>
        dsel        <= '1';
        forceerr    <= '0';
        ldebugstate <= "0001";
        if ltxkout = '1' and ltxdout = X"FE" and txcodeerrreg = X"0000000000000000" then
          ns        <= lock;

        else
          ns        <= sendsync;
        end if;
      when lock     =>
        dsel        <= '0';
        forceerr    <= '0';
        ldebugstate <= "0011";
        if txcodeerr = '1' then
          ns        <= unlocked;
        else
          ns        <= lock;
        end if;
      when unlocked =>
        dsel        <= '0';
        forceerr    <= '1';
        ldebugstate <= "0100";
        ns          <= none;
      when others   => null;
    end case;

  end process fsm;
end Behavioral;
