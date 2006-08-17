library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memtest is
  port (
    CLKIN    : in    std_logic;
    CLKOUT   : out   std_logic;
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
end memtest;

architecture Behavioral of memtest is

  component memddr2
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET : in std_logic; 
      -- RAM!
      CKE    : out   std_logic;
      CAS    : out   std_logic;
      RAS    : out   std_logic;
      CS     : out   std_logic;
      WE     : out   std_logic;
      ADDR   : out   std_logic_vector(12 downto 0);
      BA     : out   std_logic_vector(1 downto 0);
      DQSH   : inout std_logic;
      DQSL   : inout std_logic;
      DQ     : inout std_logic_vector(15 downto 0);
      -- interface
      START  : in    std_logic;
      RW     : in    std_logic;
      DONE   : out   std_logic;
      -- write interface
      ROWTGT : in    std_logic_vector(14 downto 0);
      WRADDR : out   std_logic_vector(7 downto 0);
      WRDATA : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out   std_logic_vector(7 downto 0);
      RDDATA : out   std_logic_vector(31 downto 0);
      RDWE   : out   std_logic
      );
  end component;

  signal clkb, clkbint         : std_logic := '0';
  signal clkbfast, clkbfastint : std_logic := '0';

  signal CLK, clkint       : std_logic := '0';
  signal CLK90, clk90int   : std_logic := '0';
  signal CLK180, clk180int : std_logic := '0';
  signal CLK270, clk270int : std_logic := '0';
  signal RESET : std_logic := '1';

  
  -- interface
  signal START  : std_logic                     := '0';
  signal RW     : std_logic                     := '0';
  signal DONE   : std_logic                     := '0';
  -- write interface
  signal ROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal WRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal WRDATA : std_logic_vector(31 downto 0) := (others => '0');
  -- read interface
  signal RDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal RDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal RDWE   : std_logic                     := '0';

  signal wraddrl : std_logic_vector(7 downto 0) := (others => '0');


  type states is (none, writestart, writedone, readstart, readdone);
  signal ocs, ons : states := none;

  signal locked, locked2 : std_logic := '0';
  
begin

  memddr2_inst : memddr2
    port map (
      CLK    => clk,
      CLK90  => clk90,
      CLK180 => clk180,
      CLK270 => clk270,
      RESET => reset, 
      CKE    => CKE,
      CAS    => CAS,
      RAS    => RAS,
      CS     => CS,
      WE     => WE,
      ADDR   => ADDR,
      BA     => BA,
      DQSH   => DQSH,
      DQSL   => DQSL,
      DQ     => DQ,
      START  => START,
      RW     => RW,
      DONE   => DONE,
      ROWTGT => ROWTGT,
      WRADDR => WRADDR,
      WRDATA => WRDATA,
      RDADDR => RDADDR,
      RDDATA => RDDATA,
      RDWE   => RDWE);

  DCM_BASE_inst : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKFX_DIVIDE          => 1,
      CLKFX_MULTIPLY        => 3,
      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 10.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => false)
    port map (
      CLK0                  => clkbint,  -- 0 degree DCM CLK ouptput
      CLKFX                 => clkbfastint,  -- DCM CLK synthesis out (M/D)
      CLKFB                 => clkb,
      CLKIN                 => CLKIN,
      LOCKED => locked, 
      RST                   => '0'      -- DCM asynchronous reset input
      );

  clkb_bufg : BUFG
    port map (
      O => clkb,
      I => clkbint);

  clkbfast_bufg : BUFG
    port map (
      O => clkbfast,
      I => clkbfastint);


  DCM_BASE_inst2 : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKFX_DIVIDE          => 1,
      CLKFX_MULTIPLY        => 4,
      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 10.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => false)
    port map (
      CLK0                  => clkint,
      CLK180                => clk180int,
      CLK270                => clk270int,
      CLK90                 => clk90int,
      CLKFB                 => clk,
      CLKIN                 => clkbfast,
      LOCKED => locked2, 
      RST                   => '0'

      );

  RESET <= not locked2; 
  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clk90_bufg : BUFG
    port map (
      O => clk90,
      I => clk90int);

  clk180_bufg : BUFG
    port map (
      O => clk180,
      I => clk180int);

  clk270_bufg : BUFG
    port map (
      O => clk270,
      I => clk270int);

  CLKOUT <= clk90 when reset = '0' else 'Z'; 
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      ocs <= ons;

      wraddrl <= wraddr;
      wrdata  <= (rowtgt(7 downto 0) & wraddrl) &
                 (not (rowtgt(7 downto 0) & wraddrl));

      if RDWE = '1' and ocs = readstart then
        if rddata = (rowtgt(7 downto 0) & rdaddr) &
          (not (rowtgt(7 downto 0) & rdaddr)) then

          LEDERROR <= '0';
        else
          LEDERROR <= '1';
        end if;
      end if;

      if ocs = readdone then
        rowtgt <= rowtgt + 1;
      end if;

    end if;
  end process;

  fsm : process(ocs, DONE)
  begin
    case ocs is
      when none =>
        start <= '0';
        rw    <= '0';
        ons    <= writestart;

      when writestart =>
        start <= '1';
        rw    <= '1';
        if DONE = '1' then
          ons <= writedone;
        else
          ons <= writestart;
        end if;

      when writedone =>
        start <= '0';
        rw    <= '0';
        ons    <= readstart;

      when readstart =>
        start <= '1';
        rw    <= '0';
        if DONE = '1' then
          ons <= readdone;
        else
          ons <= readstart;
        end if;

      when readdone =>
        start <= '0';
        rw    <= '0';
        ons    <= none;

      when others =>
        start <= '0';
        rw    <= '0';
        ons    <= none;
    end case;

  end process fsm;

  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clk,
      RST    => reset
      );

end behavioral;
