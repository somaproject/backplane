library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;


entity memtest is
  port (
    CLKIN   : in    std_logic;
    RAMDQ   : inout std_logic_vector(15 downto 0);
    RAMWE   : out   std_logic;
    RAMADDR : out   std_logic_vector(16 downto 0);
    MEMCLK  : out   std_logic;
    LEDPOWER :out std_logic;
    LEDEVENT : out std_logic
    );
end memtest;

architecture Behavioral of memtest is

  signal dsel : std_logic := '0';

  signal lramwe   : std_logic                     := '0';
  signal lramaddr : std_logic_vector(16 downto 0) := (others => '0');
  signal lts      : std_logic                     := '0';
  signal ts : std_logic := '0';
  signal ramq : std_logic_vector(15 downto 0) := (others => '0');
  
  signal ramdin : std_logic_vector(15 downto 0) := (others => '0');

  signal acnt : std_logic_vector(16 downto 0) := (others => '0');

  signal dcnt : std_logic_vector(15 downto 0) := (others => '0');

  type acnt_t is array (15 downto 0) of std_logic_vector(16 downto 0);
  signal acntreg : acnt_t := (others => (others => '0'));

  type dcnt_t is array (15 downto 0) of std_logic_vector(15 downto 0);
  signal dcntreg : dcnt_t := (others => (others => '0'));

  signal errorbits  : std_logic_vector(15 downto 0) := (others => '0');

  -- clock signals; we assume a 60 MHz input clock. 
  signal clkf, clkfint, clkint, clk : std_logic := '0';

  -- error signals
  type errorbitsarray_t is array (15 downto 0) of std_logic_vector(7 downto 0);
  signal errorbitsarray : errorbitsarray_t := (others => (others => '0'));

  signal errorbitssreg : std_logic_vector(16*8-1 downto 0) := (others => '0');

  signal jtagcapture, jtagdrck, jtagreset, jtagsel,
    jtagshift, jtagtdi, jtagupdate, jtagtdo : std_logic := '0';

  signal startup_wait : std_logic := '1';
  

begin  -- Behavioral

  clkgen : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 6,
      CLKFX_MULTIPLY        => 3,
      CLKIN_PERIOD          => 15.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      FACTORY_JF            => X"F0F0",
      PHASE_SHIFT           => 0,
      STARTUP_WAIT          => false)
    port map(
      CLKIN                 => CLKIN,
      CLK0                  => clkfint,
      CLKFB                 => clkf,
      CLKFX                 => clkint,
      RST                   => '0',
      LOCKED                => open
      );

  clkf_bufg : BUFG
    port map (
      O => clkf,
      I => clkfint);

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);
  MEMCLK <= clk; 
  
  lramwe   <= '0'  when dsel = '0' else '1';
  
  lts      <= '0'  when dsel = '0' else '1';
  lramaddr <= acnt when dsel = '0' else acntreg(5);

  RAMDQ <= ramq when ts = '0' else "ZZZZZZZZZZZZZZZZ";
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      dsel <= not dsel;

      -- registers
      RAMWE   <= lramwe;
      RAMADDR <= lramaddr;
      ramq <= dcnt;
      ts <= lts;
      ramdin <= RAMDQ;

      -- counters
      if dsel = '1' then
        acnt <= acnt + 1;
        dcnt <= dcnt + 1;
      end if;

      if acnt = "00000000000010000" then
        startup_wait <= '0'; 
      end if;
      acntreg <= acntreg(14 downto 0) & acnt;
      dcntreg <= (dcntreg(14 downto 0) & dcnt);

      if dsel = '1' then
        if dcntreg(10) = ramdin then
          -- success!
          errorbits <= (others => '0'); 
        else
          if startup_wait = '0' then
            errorbits <= dcntreg(10) xor ramdin; 
          end if;
        end if;
        
      end if;
    end if;
  end process;


  
  errorbitschecks : for i in 0 to 15 generate
    process(CLK, jtagupdate)
    begin
      if rising_edge(CLK) then
        if errorbits(i) = '1' then
          if dsel = '1' then
            errorbitsarray(i) <= errorbitsarray(i) + 1;
          end if;
        end if;

      end if;

      if rising_edge(jtagupdate) then
        errorbitssreg(i*8+7 downto i*8) <= errorbitsarray(i);
      end if;
    end process;
  end generate errorbitschecks;

  -----------------------------------------------------------------------------
  -- JTAG OUTPUT
  -- --------------------------------------------------------------------------

  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE    => jtagcapture,
      DRCK       => jtagdrck,
      reset      => jtagreset,
      SEL        => jtagsel,
      SHIFT      => jtagshift,
      TDI        => jtagtdi,
      UPDATE     => jtagupdate,
      TDO        => jtagtdo);

  -- output read
  process(jtagupdate, jtagsel, jtagdrck, jtagshift)
    variable tdopos : integer range 0 to (16*8 -1) := 0;
  begin

    if jtagupdate = '1' then
      tdopos     := 16*8 -1;
    elsif falling_edge(jtagdrck) then
      if jtagsel = '1' then
        if tdopos = 16*8 - 1 then
          tdopos := 0;
        else
          tdopos := tdopos + 1;
        end if;

      end if;
    end if;
    jtagtdo <= errorbitssreg(tdopos);
  end process;

  LEDPOWER <= '1';
  LEDEVENT <='0';
  
end Behavioral;
