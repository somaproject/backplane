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

entity eproctest is
  port (
    CLKIN       : in  std_logic;
    SERIALBOOT  : out std_logic_vector(19 downto 0);
    -- SPI interface
    SPIMOSI     : in  std_logic;
    SPIMISO     : out std_logic;
    SPICS       : in  std_logic;
    SPICLK      : in  std_logic;
    LEDPOWER    : out std_logic;
    LEDEVENT    : out std_logic;
    NICFPROG    : out std_logic;
    RAMCLKOUT_P : out std_logic;
    RAMCLKOUT_N : out std_logic;
    RAMCKE      : out std_logic := '0'
    );
end eproctest;


architecture Behavioral of eproctest is

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

  component eproc
    port (
      CLK         : in  std_logic;
      RESET       : in  std_logic;
      -- Event Interface, CLK rate
      EDTX        : in  std_logic_vector(7 downto 0);
      EATX        : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE      : in  std_logic;
      EARX        : out std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
      EDRX        : out std_logic_vector(7 downto 0);
      EDSELRX     : in  std_logic_vector(3 downto 0);
      -- High-speed interface
      CLKHI       : in  std_logic;
      -- instruction interface
      IADDR       : out std_logic_vector(9 downto 0);
      IDATA       : in  std_logic_vector(17 downto 0);
      --outport signals
      OPORTADDR   : out std_logic_vector(7 downto 0);
      OPORTDATA   : out std_logic_vector(15 downto 0);
      OPORTSTROBE : out std_logic;
      DEVICE      : in  std_logic_vector(7 downto 0)
      );

  end component;

  component bootstore
    generic (
      DEVICE  :     std_logic_vector(7 downto 0)                   := X"01"
      );
    port (
      CLK     : in  std_logic;
      CLKHI   : in  std_logic;
      RESET   : in  std_logic;
      DEBUG : out std_logic_vector(7 downto 0); 
      -- event interface
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);

      -- SPI INTERFACE
      SPIMOSI : in  std_logic;
      SPIMISO : out std_logic;
      SPICS   : in  std_logic;
      SPICLK  : in  std_logic
      );
  end component;


  signal EARX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDRX    : somabackplane.dataarray      := (others => (others => '0'));
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');
  signal RESET   : std_logic                    := '0';
  signal ECYCLE  : std_logic                    := '0';

  signal douta   : std_logic_vector(7 downto 0) := (others => '0');
  signal doutena : std_logic                    := '0';

  signal doutb   : std_logic_vector(7 downto 0) := (others => '0');
  signal doutenb : std_logic                    := '0';


  signal clk, clkint             : std_logic := '0';
  signal clk2x, clk2xint         : std_logic := '0';
  signal clk180, clk180int       : std_logic := '0';
  signal memclkb, memclkbint     : std_logic := '0';
  signal memclk, memclkint       : std_logic := '0';
  signal memclk90, memclk90int   : std_logic := '0';
  signal memclk180, memclk180int : std_logic := '0';
  signal memclk270, memclk270int : std_logic := '0';


  signal nicclkint : std_logic := '0';

  signal nicnextframeint : std_logic := '0';

  signal locked, locked2 : std_logic                    := '0';
  signal resetint        : std_logic_vector(7 downto 0) := (others => '1');

  signal iaddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata : std_logic_vector(17 downto 0) := (others => '0');

  signal OPORTADDR   : std_logic_vector(7 downto 0);
  signal OPORTDATA   : std_logic_vector(15 downto 0);
  signal OPORTSTROBE : std_logic := '0';

  signal bootstoredebug : std_logic_vector(7 downto 0) := (others => '0');
  
begin  -- Behavioral


  RAMCKE   <= '0';
  NICFPROG <= '1';

  ---------------------------------------------------------------------------
  -- CLOCKING
  ---------------------------------------------------------------------------

  DCM_BASE_inst : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKFX_DIVIDE          => 1,
      CLKFX_MULTIPLY        => 3,
      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 20.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X",
      DCM_AUTOCALIBRATION   => true,
      DFS_FREQUENCY_MODE    => "LOW",
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true,
      STARTUP_WAIT          => true)
    port map (
      CLK0                  => clkint,      -- 0 degree DCM CLK ouptput
      CLKFX                 => memclkbint,  -- DCM CLK synthesis out (M/D)
      CLKFB                 => clk,
      CLK180                => clk180int,
      --CLK90                 => niciointclk,
      clk2x                 => clk2xint,
      CLKIN                 => CLKIN,
      LOCKED                => locked,
      RST                   => '0'          -- DCM asynchronous reset input
      );


  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  clk180_bufg : BUFG
    port map (
      I => clk180int,
      O => clk180);

  clk2x_bufg : BUFG
    port map (
      O => clk2x,
      I => clk2xint);

  memclkb_bufg : BUFG
    port map (
      O => memclkb,
      I => memclkbint);

  process(CLK)
  begin
    if rising_edge(CLK) then
      resetint <= resetint(6 downto 0) & (not locked);
    end if;
  end process;


  DCM_BASE_inst2 : DCM_BASE
    generic map (
      CLKDV_DIVIDE => 2.0,

      CLKIN_DIVIDE_BY_2     => false,
      CLKIN_PERIOD          => 6.0,
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
      CLK0                  => memclkint,
      CLK180                => memclk180int,
      CLK270                => memclk270int,
      CLK90                 => memclk90int,
      CLKFB                 => memclk,
      CLKIN                 => memclkb,
      LOCKED                => locked2,
      RST                   => resetint(7)

      );

  RESET <= not locked2;

  memclk_bufg : BUFG
    port map (
      O => memclk,
      I => memclkint);

  memclk90_bufg : BUFG
    port map (
      O => memclk90,
      I => memclk90int);

  memclk180_bufg : BUFG
    port map (
      O => memclk180,
      I => memclk180int);

  memclk270_bufg : BUFG
    port map (
      O => memclk270,
      I => memclk270int);

  TXIO_obufds : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O          => RAMCLKOUT_P,
      OB         => RAMCLKOUT_N,
      I          => memclk270
      );

  eventrouter_inst : eventrouter
    port map (
      CLK     => clk,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EATX    => EATX,
      EDTX    => EDTX);

  timer_inst : timer
    port map (
      CLK     => clk,
      ECYCLe  => ECYCLE,
      EARX    => EARX(0),
      EDRX    => EDRX(0),
      EDSELRX => EDSELRX,
      EATX    => EATX(0),
      EDTX    => EDTX);




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
      JTAG_CHAIN_MASK => 2,
      JTAG_CHAIN_OUT  => 3 )
    port map (
      CLK             => clk,
      ECYCLE          => ecycle,
      EDTX            => edtx,
      EATX            => eatx(7),
      DEBUG           => open);

  -- dummy
  process(clk)
    variable blinkcnt : std_logic_vector(21 downto 0)
               := (others => '0');
  begin
    if rising_edge(clk) then
      blinkcnt := blinkcnt + 1;

    end if;
  end process;


  dlyctrl : IDELAYCTRL
    port map(
      RDY    => open,
      REFCLK => clk,
      RST    => reset
      );

  instruction_ram : RAMB16_S18_S18
    port map (
      DOA   => idata(15 downto 0),
      DOPA  => idata(17 downto 16),
      ADDRA => iaddr,
      CLKA  => clk2x,
      DIA   => X"0000",
      DIPA  => "00",
      ENA   => '1',
      WEA   => '0',
      SSRA  => RESET,
      DOB   => open,
      DOPB  => open,
      ADDRB => "0000000000",
      CLKB  => clk2x,
      DIB   => X"0000",
      DIPB  => "00",
      ENB   => '0',
      WEB   => '0',
      SSRB  => RESET);

  eproc_inst : eproc
    port map (
      CLK         => clk,
      RESET       => RESET,
      EDTX        => EDTX,
      EATX        => EATX(1),
      ECYCLE      => ECYCLE,
      EARX        => EARX(1),
      EDRX        => EDRX(1),
      EDSELRX     => EDSELRX,
      CLKHI       => clk2x,
      IADDR       => iaddr,
      IDATA       => idata,
      OPORTADDR   => oportaddr,
      OPORTDATA   => oportdata,
      OPORTSTROBE => oportstrobe,
      DEVICE      => X"01");

  bootstore_inst : bootstore
    generic map (
      DEVICE  => X"03")
    port map (
      CLK     => CLK,
      CLKHI   => memclkint,
      RESET   => RESET,
      DEBUG => bootstoredebug,
      EDTX    => EDTX,
      EATX    => EATX(3),
      ECYCLE  => ECYCLE,
      EARX    => EARX(3),
      EDRX    => EDRX(3),
      EDSELRX => edselrx,
      SPIMOSI => SPIMOSI,
      SPIMISO => SPIMISO,
      SPICS   => SPICS,
      SPICLK  => SPICLK);

  LEDPOWER <= bootstoredebug(1);
  LEDEVENT <= bootstoredebug(2);

--  LEDPOWER <= locked2;  
--   process(clk2x)
--   begin
--     if rising_edge(clk2x) then
--       if oportstrobe = '1' then
--         if oportaddr = X"20" then
--           LEDEVENT <= oportdata(0);
--         end if;
--       end if;
--     end if;
--   end process;


end Behavioral;
