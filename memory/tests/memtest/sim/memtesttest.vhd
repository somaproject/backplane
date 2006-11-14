library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use WORK.HY5PS121621F_PACK.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memtesttest is

end memtesttest;

architecture Behavioral of memtesttest is

  component memtest
    port (
      CLKIN    : in    std_logic;
      CLKOUT_P : out   std_logic;
      CLKOUT_N : out   std_logic;
      -- RAM!
      CKE      : out   std_logic;
      CAS      : out   std_logic;
      RAS      : out   std_logic;
      CS       : out   std_logic;
      WE       : out   std_logic;
      ADDR     : out   std_logic_vector(12 downto 0);
      BA       : out   std_logic_vector(1 downto 0);
      DQSH     : inout std_logic;
      DQSL     : inout std_logic;
      DQ       : inout std_logic_vector(15 downto 0);
      LEDERROR : out   std_logic
      );
  end component;

  signal CLKIN                    : std_logic := '0';
  signal clk, memclk, memclkn, clkn, clk90n : std_logic := '0';


  -- RAM!
  signal CKE  : std_logic                     := '0';
  signal CAS  : std_logic                     := '1';
  signal RAS  : std_logic                     := '1';
  signal CS   : std_logic                     := '1';
  signal WE   : std_logic                     := '1';
  signal ADDR : std_logic_vector(12 downto 0) := (others => '0');
  signal BA   : std_logic_vector(1 downto 0)  := (others => '0');
  signal DQSH : std_logic                     := '0';
  signal DQSL : std_logic                     := '0';
  signal DQ   : std_logic_vector(15 downto 0) := (others => '0');

  signal LEDERROR : std_logic := '0';

  component HY5PS121621F
    generic (
      TimingCheckFlag :       boolean                       := true;
      PUSCheckFlag    :       boolean                       := false;
      Part_Number     :       PART_NUM_TYPE                 := B400);
    port ( DQ         : inout std_logic_vector(15 downto 0) := (others => 'Z');
           LDQS       : inout std_logic                     := 'Z';
           LDQSB      : inout std_logic                     := 'Z';
           UDQS       : inout std_logic                     := 'Z';
           UDQSB      : inout std_logic                     := 'Z';
           LDM        : in    std_logic;
           WEB        : in    std_logic;
           CASB       : in    std_logic;
           RASB       : in    std_logic;
           CSB        : in    std_logic;
           BA         : in    std_logic_vector(1 downto 0);
           ADDR       : in    std_logic_vector(12 downto 0);
           CKE        : in    std_logic;
           CLK        : in    std_logic;
           CLKB       : in    std_logic;
           UDM        : in    std_logic );
  end component;

  signal mainclk : std_logic := '0';

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 20 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal srcclk   : std_logic := '0';
  signal clkpos   : integer   := 0;
  signal clk90sim : std_logic := '0';

begin  -- Behavioral

  DQSH <= 'L';
  DQSL <= 'L';

  memtest_uut : memtest
    port map (
      CLKIN    => CLKIN,
      CLKOUT_P => memCLK,
      CLKOUT_N => memCLKn,
      CKE      => CKE,
      CAS      => CAS,
      RAS      => RAS,
      CS       => CS,
      WE       => WE,
      ADDR     => ADDR,
      BA       => BA,
      DQSH     => DQSH,
      DQSL     => DQSL,
      DQ       => DQ,
      LEDERROR => LEDERROR);

  srcclk <= not srcclk after clk_period/6;

  process (srcclk)
  begin
    if rising_edge(srcclk) or falling_edge(srcclk) then
      if clkpos = 5 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;

      if clkpos = 0 then
        CLKIN <= not CLKIN;
      elsif clkpos = 3 then
        CLKIN <= not CLKIN;
      end if;
    end if;

  end process;


  memory_inst : HY5PS121621F
    generic map (
      TimingCheckFlag => true,
      PUSCheckFlag    => true,
      PArt_number     => B400)
    port map (
      DQ              => DQ,
      LDQS            => DQSL,
      UDQS            => DQSH,
      WEB             => WE,
      LDM             => '0',
      UDM             => '0',
      CASB            => CAS,
      RASB            => RAS,
      CSB             => CS,
      BA              => BA,
      ADDR            => ADDR,
      CKE             => CKE,
      CLK             => memclk,
      CLKB            => memclkn);

end Behavioral;
