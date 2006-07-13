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
    CLKIN       : in  std_logic;
    SERIALBOOT  : out std_logic_vector(19 downto 0);
    SDOUT       : out std_logic;
    SDIN        : in  std_logic;
    SCLK        : out std_logic;
    SCS         : out std_logic;
    LEDPOWER    : out std_logic;
    LEDEVENT    : out std_logic;
    NICFCLK     : out std_logic;
    NICFDIN     : out std_logic;
    NICFPROG    : out std_logic;
    NICSCLK     : out std_logic;
    NICSIN      : in  std_logic;
    NICSOUT     : out std_logic;
    NICSCS      : out std_logic;
    NICDOUT     : out std_logic_vector(15 downto 0);
    NICNEWFRAME : out std_logic;
    NICDIN    : in std_logic_vector(15 downto 0);
    NICNEXTFRAME : out std_logic;
    NICDINEN : in std_logic; 
    NICCLK      : out std_logic;
    DEBUG : out std_logic_vector(3 downto 0)
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
      SEROUT  : out std_logic_vector(M-1 downto 0);
      DEBUG   : out std_logic_vector(1 downto 0));
  end component;


  component bootdeserialize
    port (
      CLK   : in  std_logic;
      SERIN : in  std_logic;
      FPROG : out std_logic;
      FCLK  : out std_logic;
      FDIN  : out std_logic);
  end component;


  component jtagesend
    generic (
      JTAG_CHAIN :     integer := 1);
    port (
      CLK        : in  std_logic;
      ECYCLE     : in  std_logic;
      EARX       : out std_logic_vector(somabackplane.N - 1 downto 0)
                               := (others => '0');
      EDRX       : out std_logic_vector(7 downto 0);
      EDSELRX    : in  std_logic_vector(3 downto 0)
      );
  end component;

  component jtagereceive
    generic (
      JTAG_CHAIN_MASK :     integer := 1;
      JTAG_CHAIN_OUT  :     integer := 1
      );
    port (
      CLK             : in  std_logic;
      ECYCLE          : in  std_logic;
      EDTX            : in  std_logic_vector(7 downto 0);
      EATX            : in  std_logic_vector(somabackplane.N - 1 downto 0);
      DEBUG           : out std_logic_vector(3 downto 0)
      );
  end component;

  component ether
    generic (
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                 := (others => '0');
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SOUT    : out std_logic;
      SIN     : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic);
  end component;

  component network
    port (
      CLK       : in  std_logic;
      RESET : in std_logic; 
      -- config
      MYIP      : in  std_logic_vector(31 downto 0);
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYBCAST   : in  std_logic_vector(31 downto 0);
      -- input
      NICNEXTFRAME : out std_logic;
      NICDINEN     : in  std_logic;
      NICDIN       : in  std_logic_vector(15 downto 0);
      -- output
      DOUT      : out std_logic_vector(15 downto 0);
      NEWFRAME  : out std_logic;
      IOCLOCK   : out std_logic;

      -- event bus
      ECYCLE  : in std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0)

      -- data bus
      --                                  -- none at the moment;
      );
  end component;

  component pingdump
    port (
      CLK      : in  std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic);        -- (others => '0')
  end component;

  signal ECYCLE : std_logic := '0';

  signal EARX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDRX    : somabackplane.dataarray      := (others => (others => '0'));
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');
  signal RESET   : std_logic                    := '0';

  signal lserialboot : std_logic_vector(19 downto 0) := (others => '1');

  signal clk, clkint   : std_logic := '0';
  signal clkf, clkfint : std_logic := '0';

  -- jtag signal test
  signal jtagcapture : std_logic := '0';
  signal jtagdrck    : std_logic := '0';
  signal jtagreset   : std_logic := '0';
  signal jtagsel     : std_logic := '0';
  signal jtagshift   : std_logic := '0';
  signal jtagtdi     : std_logic := '0';
  signal jtagupdate  : std_logic := '0';
  signal jtagtdo     : std_logic := '0';

  signal testout : std_logic_vector(31 downto 0) := X"00000001";

-- nic config signals
  signal myip, mybcast : std_logic_vector(31 downto 0) := (others => '0');
  signal mymac : std_logic_vector(47 downto 0) := (others => '0');
  

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
      SEROUT  => lserialboot,
      DEBUG   => open);

  bootdeserialize_inst : bootdeserialize
    port map (
      CLK   => CLK,
      SERIN => lserialboot(0),
      FPROG => NICFPROG,
      FCLK  => NICFCLK,
      FDIN  => NICFDIN);

  SERIALBOOT <= lserialboot;


  BSCAN_VIRTEX4_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 2)
    port map (
      CAPTURE    => jtagcapture,
      DRCK       => jtagdrck,
      reset      => jtagreset,
      SEL        => jtagsel,
      SHIFT      => jtagshift,
      TDI        => jtagtdi,
      UPDATE     => jtagupdate,
      TDO        => jtagtdo);

  LEDEVENT <= jtagshift;

  jtagtdo         <= testout(0);
  process(jtagsel, jtagdrck, jtagupdate)
  begin
    if jtagupdate = '1' then
      testout     <= X"87654321";
    else
      if rising_edge(jtagdrck) then
        if jtagsel = '1' and jtagshift = '1' then
          testout <= testout(0) & testout(31 downto 1);
        end if;
      end if;
    end if;
  end process;

  jtagsend_inst : jtagesend
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CLK        => clk,
      ECYCLE     => ecycle,
      EARX       => earx(7),
      EDRX       => edrx(7),
      EDSELRX    => edselrx);

  jtagreceive_inst : jtagereceive
    generic map (
      JTAG_CHAIN_MASK => 3,
      JTAG_CHAIN_OUT  => 4 )
    port map (
      CLK             => clk,
      ECYCLE          => ecycle,
      EDTX            => edtx,
      EATX            => eatx(7),
      DEBUG           => DEBUG);

  ether_inst : ether
    generic map (
      DEVICE  => X"05")
    port map (
      CLK     => clk,
      RESET   => reset,
      EDTX    => edtx,
      EATX    => eatx(5),
      ECYCLE  => ecycle,
      EARX    => earx(5),
      EDRX    => edrx(5),
      EDSELRX => edselrx,
      SOUT    => NICSOUT,
      SIN     => NICSIN,
      SCLK    => NICSCLK,
      SCS     => NICSCS);

  -- dummy
  process(CLK)
    variable blinkcnt : std_logic_vector(21 downto 0)
               := (others => '0');
  begin
    if rising_edge(CLK) then
      blinkcnt := blinkcnt + 1;
      LEDPOWER <= blinkcnt(21);
    end if;
  end process;

--  NETCLK <= clk;



--  pingdump_inst : pingdump
--    port map (
--      CLK      => clk,
--      DOUT     => NETDOUT,
--      NEWFRAME => NETNEWFRAME);

  myip <= X"C0a80002";                  -- 192.168.0.2
  mybcast <= X"C0a000FF";
  
  mymac <= X"DEADBEEF1234"; 
           
  network_inst : network
    port map (
      CLK       => CLK,
      RESET => RESET,
      MYIP      => myip,
      MYMAC     => mymac,
      MYBCAST   => mybcast,
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => NICDINEN,
      NICDIN       => NICDIN,
      DOUT      => NICDOUT,
      NEWFRAME  => NICNEWFRAME,
      IOCLOCK   => NICCLK,
      ECYCLE    => ecycle,
      EARX      => earx(3),
      EDRX      => edrx(3),
      EDSELRX   => edselrx,
      EATX      => eatx(3),
      EDTX      => edtx);

  

end Behavioral;
