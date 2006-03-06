
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity devicelink is
  port (
    TXCLKIN  : in  std_logic;
    TXLOCKED : in  std_logic;
    TXDIN    : in  std_logic_vector(9 downto 0);
    TXDOUT   : out std_logic_vector(7 downto 0);
    TXKOUT   : out std_logic;
    CLK      : out std_logic;
    CLK2X    : out std_logic;
    RESET    : out std_logic;
    RXDIN    : in  std_logic_vector(7 downto 0);
    RXKIN    : in  std_logic;
    RXIO_P   : out std_logic;
    RXIO_N   : out std_logic
    );

end devicelink;

architecture Behavioral of devicelink is

  signal nottxlocked  : std_logic := '0';
  signal dcmlocked    : std_logic := '0';
  signal txclkint, txclk     : std_logic := '0';
  signal rxhbitclk    : std_logic := '0';
  signal rxhbitclk180 : std_logic := '0';
  signal rst : std_logic := '0';

  
  signal txdinl  : std_logic_vector(9 downto 0) := (others => '0');
  signal ltxdout : std_logic_vector(7 downto 0) := (others => '0');

  signal cerr    : std_logic := '0';
  signal derr    : std_logic := '0';
  signal ltxkout : std_logic := '0';

  signal rxdinl : std_logic_vector(7 downto 0) := (others => '0');
  signal rxkinl : std_logic                    := '0';
  signal dsel   : std_logic                    := '0';

  signal DIN : std_logic_vector(7 downto 0) := (others => '0');
  signal kin : std_logic                    := '0';

  signal ol, oll : std_logic_vector(9 downto 0) := (others => '0');

  signal forceerr : std_logic := '0';
  signal txcodeerr : std_logic := '0';
  signal sout : std_logic_vector(9 downto 0) := (others => '0');

  signal rxio : std_logic := '0';


  type states is (none, sendsync, lock, unlocked);
  signal cs, ns : states := none;
  
                  

begin  -- Behavioral

    encoder : encode8b10b
    port map (
      DIN  => din,
      KIN  => kin,
      DOUT => ol,
      CLK  => txclk);

  decoder : decode8b10b
    port map (
      CLK      => CLK,
      DIN      => txdinl,
      DOUT     => ltxdout,
      KOUT     => ltxkout,
      CODE_ERR => cerr,
      DISP_ERR => derr);

nottxlocked <= not TXLOCKED;
rst <= not dcmlocked;
    
    RESET <= rst; 
  txclkdcm : dcm generic map (
    CLKIN_PERIOD   => 7.7,
    CLKFX_DIVIDE   => 1,
    CLKFX_MULTIPLY => 5)
    port map (
      CLKIN        => TXCLKIN,
      CLKFB        => txclk,
      RST          => nottxlocked,
      PSEN         => '0',
      CLK0         => txclkint,
      CLK2x        => CLK2X, 
      CLKFX        => rxhbitclk,
      CLKFX180     => rxhbitclk180,
      LOCKED => dcmlocked);

  txclk_bufg : BUFG port map (
    O => txclk,
    I => txclkint);

  CLK <= txclk;


DIN <= rxdinl when dsel = '0' else X"00";
KIN <= rxkinl when dsel = '0' else '0';

txcodeerr <= cerr or derr;

  FDDRRSE_inst : FDDRRSE
    port map (
      Q  => rxio,                       -- Data output 
      C0 => RXHBITCLK,                      -- 0 degree clock input
      C1 => RXHBITCLK180,                   -- 180 degree clock input
      CE => '1',                        -- Clock enable input
      D0 => sout(1),                -- Posedge data input
      D1 => sout(0),                -- Negedge data input
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

main: process (txclk, rst)
begin  -- process main
  if rst = '1' then                 -- asynchronous reset (active low)
    cs <= none; 
  elsif rising_edge(txclk) then
    cs <= ns;

    rxdinl <= RXDIN;
    rxkinl <= RXKIN; 

    txdinl <= TXDIN;
    TXDOUT <= ltxdout;
    TXKOUT <= ltxkout;

    if forceerr = '0' then
      oll <= ol;
    else
      oll <= "0000000000"; 
    end if;
  
  end if;
end process main;

rxclkproc: process(rxhbitclk)
  variable bitreg: std_logic_vector(4 downto 0) := "00001";
  
begin
  if rising_edge(rxhbitclk) then
    bitreg := bitreg(0) & bitreg(4 downto 1) ;
    if bitreg(0) = '1' then
      sout <= oll;
    else
      sout <= "00" & sout(9 downto 2); 
    end if;
  end if;

end process rxclkproc; 

fsm: process (cs, ltxkout, ltxdout, txcodeerr)
  begin
    case cs is
      when none =>
        dsel <= '1';
        forceerr <= '0';
        ns <= sendsync;
      when sendsync =>
        dsel <= '1';
        forceerr <= '0';
        if ltxkout = '1' and ltxdout = X"FE" and txcodeerr = '0' then
          ns <= lock;
        else
          ns <= sendsync; 
        end if;
          
      when lock =>
        dsel <= '0';
        forceerr <= '0';
        if txcodeerr = '1' then
          ns <= unlocked;
        else
          ns <= lock; 
        end if;
      when unlocked =>
        dsel <= '0';
        forceerr <= '1';
        ns <= unlocked; 
      when others => null;
    end case;

  end process fsm; 
end Behavioral;
