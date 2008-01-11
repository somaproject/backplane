library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library eproclib;
use eproclib;

library UNISIM;
use UNISIM.VComponents.all;

entity syscontrol is
  generic (
    DEVICE  :     std_logic_vector(7 downto 0)                   := X"01" );
  port (
    CLK     : in  std_logic;
    CLK2X   : in  std_logic;
    RESET   : in  std_logic;
    DEBUG   : out std_logic_vector(7 downto 0);
    -- event interface
    EDTX    : in  std_logic_vector(7 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    -- Boot control output
    SEROUT  : out std_logic_vector(19 downto 0)
    );
end syscontrol;


architecture Behavioral of syscontrol is

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

  component bootserperipheral
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      ADDRIN : in  std_logic_vector(2 downto 0);
      WEIN   : in  std_logic;
      SEROUT : out std_logic_vector(19 downto 0));
  end component;


  signal iaddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata : std_logic_vector(17 downto 0) := (others => '0');

  signal OPORTADDR   : std_logic_vector(7 downto 0);
  signal OPORTDATA   : std_logic_vector(15 downto 0);
  signal OPORTSTROBE : std_logic := '0';
  signal bsperwe  : std_logic := '0';
  
begin  -- Behavioral


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

  eproc_inst : eproclib.eproc
    port map (
      CLK         => clk,
      RESET       => RESET,
      EDTX        => EDTX,
      EATX        => EATX,
      ECYCLE      => ECYCLE,
      EARX        => EARX,
      EDRX        => EDRX,
      EDSELRX     => EDSELRX,
      CLKHI       => CLK2X,
      IADDR       => iaddr,
      IDATA       => idata,
      OPORTADDR   => oportaddr,
      OPORTDATA   => oportdata,
      OPORTSTROBE => oportstrobe,
      DEVICE      => DEVICE);


  bootserp_inst: bootserperipheral
    port map (
      CLK    => CLK2X,
      DIN    => OPORTDATA,
      ADDRIN => OPORTADDR(2 downto 0),
      WEIN   => bsperwe,
      SEROUT => SEROUT);

  bsperwe <= '1' when oportaddr(7 downto 3) = "00001" and OPORTSTROBE = '1'
             else '0';
  
end Behavioral;
