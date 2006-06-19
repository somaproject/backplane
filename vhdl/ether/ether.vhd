library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity ether is
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
end ether;


architecture Behavioral of ether is

  signal enext : std_logic                     := '0';
  signal eouta : std_logic_vector(2 downto 0)  := (others => '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');

  signal evalid : std_logic := '0';

  signal rw   : std_logic                     := '0';
  signal addr : std_logic_vector(5 downto 0)  := (others => '0');
  signal din  : std_logic_vector(31 downto 0) := (others => '0');
  signal dout : std_logic_vector(31 downto 0) := (others => '0');

  signal start, done : std_logic := '0';



  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;

  component ethercontrol

    generic (
      DEVICE   :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      ECYCLE   : in  std_logic;
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX     : out std_logic_vector(7 downto 0);
      EDSELRX  : in  std_logic_vector(3 downto 0);
      EOUTD    : in  std_logic_vector(15 downto 0);
      EOUTA    : out std_logic_vector(2 downto 0);
      EVALID   : in  std_logic;
      ENEXT    : out std_logic;
      RW       : out std_logic;
      ADDR     : out std_logic_vector(5 downto 0);
      DIN      : out std_logic_vector(31 downto 0);
      DOUT     : in  std_logic_vector(31 downto 0);
      NICSTART : out std_logic;
      NICDONE  : in  std_logic
      );

  end component;

  component nicserialio
    port (
      CLK   : in  std_logic;
      START : in  std_logic;
      RW    : in  std_logic;
      ADDR  : in  std_logic_vector(5 downto 0); 
      DIN   : in  std_logic_vector(31 downto 0);
      DOUT  : out std_logic_vector(31 downto 0);
      DONE  : out std_logic;
      SCLK  : out std_logic;
      SOUT  : out std_logic;
      SCS   : out std_logic;
      SIN   : in  std_logic);
  end component;

begin  -- Behavioral

  rxeventfifo_inst : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      eoutd  => eoutd,
      eouta  => eouta,
      EVALID => evalid,
      ENEXT  => enext);


  ethercontrol_inst : ethercontrol
    generic map (
      DEVICE => DEVICE)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      ECYCLE   => ECYCLE,
      EARX     => EARX,
      EDRX     => EDRX,
      EDSELRX  => EDSELRX,
      EOUTD    => eoutd,
      EOUTA    => eouta,
      EVALID   => evalid,
      ENEXT    => enext,
      RW       => rw,
      ADDR     => addr,
      DIN      => din,
      DOUT     => dout,
      NICSTART => start,
      NICDONE  => done);

  nicserialio_inst : nicserialio
    port map (
      CLK   => CLK,
      START => start,
      RW    => rw,
      ADDR  => addr,
      DIN   => din,
      DOUT  => dout,
      DONE  => done,
      SCLK  => SCLK,
      SOUT  => SOUT,
      SCS   => SCS,
      SIN   => SIN);


end Behavioral;



