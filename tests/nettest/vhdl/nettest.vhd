library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


library UNISIM;
use UNISIM.VComponents.all;

entity nettest is
  port (
    CLKIN        : in  std_logic;
    SERIALBOOT : out std_logic_vector(19 downto 0);
    SDOUT      : out std_logic;
    SDIN       : in  std_logic;
    SCLK       : out std_logic;
    SCS        : out std_logic;
    LEDPOWER   : out std_logic;
    LEDEVENT   : out std_logic;
    NICFCLK    : out std_logic;
    NICFDIN    : out std_logic;
    NICFPROG   : out std_logic
    );
end nettest;


architecture Behavioral of nettest is

  component eventrouter
    port (
      CLK     : in  std_logic;
      ECYCLE  : in  std_logic;
      EARX    : in  somabackplane.addrarray;
      EDRX    : in  somabackplane.dataarray;
      EDSELRX : out std_logic_vector(3 downto 0);
      EATX    : out somabackplane.addrarray;
      EDTX    : out std_logic_vector(7 downto 0)
      );
  end component;

  component timer
    port (
      CLK     : in  std_logic;
      ECYCLE  : out std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0)
      );
  end component;

  component syscontrol
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0)
      );
  end component;

  component boot
    generic (
      M       :     integer                      := 20;
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SDOUT   : out std_logic;
      SDIN    : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic;
      SEROUT  : out std_logic_vector(M-1 downto 0));
  end component;


  component bootdeserialize
    port (
      CLK   : in  std_logic;
      SERIN : in  std_logic;
      FPROG : out std_logic;
      FCLK  : out std_logic;
      FDIN  : out std_logic);
  end component;

  signal ECYCLE : std_logic := '0';

  signal EARX        : somabackplane.addrarray := (others => (others => '0'));
  signal EDRX        : somabackplane.dataarray := (others => (others => '0'));
  signal EDSELRX     : std_logic_vector(3 downto 0) := (others => '0'); 
  signal EATX        : somabackplane.addrarray := (others => (others => '0'));
  signal EDTX        : std_logic_vector(7 downto 0)  := (others => '0'); 
  signal RESET       : std_logic                      := '0';
  
  signal lserialboot : std_logic_vector(19 downto 0) := (others => '1');

  signal clk, clkint : std_logic := '0';
  signal clkf, clkfint : std_logic := '0';
  
  
begin  -- Behavioral

  clkgen : DCM_BASE
    generic map (
      CLKFX_DIVIDE          => 6, 
      CLKFX_MULTIPLY        => 5, 
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
      RST                   => RESET,
      LOCKED                => open
      );

  clk_bufg : BUFG
    port map (
      O => clkf,
      I => clkfint);

  clksrc_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  eventrouter_inst : eventrouter
    port map (
      CLK     => CLK,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EATX    => EATX,
      EDTX    => EDTX);

  timer_inst : timer
    port map (
      CLK     => CLK,
      ECYCLe  => ECYCLE,
      EARX    => EARX(0),
      EDRX    => EDRX(0),
      EDSELRX => EDSELRX,
      EATX    => EATX(0),
      EDTX    => EDTX);

  syscontrol_inst : syscontrol
    port map (
      CLK     => CLK,
      RESET   => RESET,
      ECYCLe  => ECYCLE,
      EARX    => EARX(1),
      EDRX    => EDRX(1),
      EDSELRX => EDSELRX,
      EATX    => EATX(1),
      EDTX    => EDTX);

  boot_inst : boot
    generic map (
      M      => 20,
      DEVICE => X"02")

    port map (
      CLk     => CLK,
      RESET   => RESET,
      ECYCLE  => ECYCLE,
      EARX    => EARX(2),
      EDRX    => EDRX(2),
      EDSELRX => EDSELRX,
      EATX    => EATX(2),
      EDTX    => EDTX,
      SDOUT   => SDOUT,
      SDIN    => SDIN,
      SCLK    => SCLK,
      SCS     => SCS,
      SEROUT  => lserialboot);

  bootdeserialize_inst : bootdeserialize
    port map (
      CLK   => CLK,
      SERIN => lserialboot(0),
      FPROG => NICFPROG,
      FCLK  => NICFCLK,
      FDIN  => NICFDIN);

  SERIALBOOT <= lserialboot;

  -- dummy
  process(CLK)
    variable blinkcnt: std_logic_vector(21 downto 0) := (others => '0'); 
    
    begin
      if rising_edge(CLK) then
        blinkcnt := blinkcnt + 1;
        LEDPOWER <= blinkcnt(21);
        LEDEVENT <= ECYCLE; 
      end if;
    end process; 
end Behavioral;
