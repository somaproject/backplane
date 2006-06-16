library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;



entity boot is

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
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0)
    := (others => '0');
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    SDOUT   : out std_logic;
    SDIN    : in  std_logic;
    SCLK    : out std_logic;
    SCS     : out std_logic;
    SEROUT  : out std_logic_vector(M-1 downto 0); 
    DEBUG : out std_logic_vector(1 downto 0));

end boot;


architecture Behavioral of boot is

  signal enext : std_logic                     := '0';
  signal eouta : std_logic_vector(2 downto 0)  := (others => '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');

  signal evalid : std_logic := '0';

  signal bootaddr : std_logic_vector(15 downto 0) := (others => '0');
  signal bootlen : std_logic_vector(15 downto 0) := (others => '0');

  signal bootasel : std_logic_vector(M-1 downto 0) := (others => '0');

  signal mmcstart, mmcstop, mmcdone : std_logic := '0';

  
component rxeventfifo 
  port (
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    ECYCLE : in  std_logic;
    EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
    EDTX   : in  std_logic_vector(7 downto 0); 
    -- outputs
    EOUTD  : out std_logic_vector(15 downto 0);
    EOUTA  : in std_logic_vector(2 downto 0);
    EVALID : out std_logic;
    ENEXT  : in  std_logic
    );
end component;

component bootcontrol

  generic (
    M        :     integer                      := 20;
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
    BOOTASEL : out std_logic_vector(M-1 downto 0);
    BOOTADDR : out std_logic_vector(15 downto 0);
    BOOTLEN  : out std_logic_vector(15 downto 0);
    MMCSTART : out std_logic;
    MMCDONE  : in  std_logic
    );

end component;


component mmcfpgaboot 

  generic (
    M : integer := 20);

  port (
    CLK      : in  std_logic;
    RESET    : in  std_logic;
    BOOTASEL : in  std_logic_vector(M-1 downto 0);
    SEROUT   : out std_logic_vector(M-1 downto 0);
    BOOTADDR : in  std_logic_vector(15 downto 0);
    BOOTLEN  : in  std_logic_vector(15 downto 0);
    START    : in  std_logic;
    DONE     : out std_logic;
    SDOUT    : out std_logic;
    SDIN     : in  std_logic;
    SCLK     : out std_logic;
    SCS      : out std_logic);

  
end component;

begin  -- Behavioral

  rxeventfifo_inst: rxeventfifo
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
  
    
bootcontrol_inst: bootcontrol
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
    BOOTASEL => bootasel,
    BOOTADDR => bootaddr,
    BOOTLEN  => bootlen,
    MMCSTART => mmcstart,
    MMCDONE  => mmcdone);


  DEBUG(0) <= mmcstart;
  DEBUG(1) <= mmcdone; 
  
mmcfpgaboot_inst: mmcfpgaboot
  generic map (
    M => M)
  port map (
    CLK      => CLK,
    RESET    => RESET,
    BOOTASEL => bootasel,
    SEROUT   => SEROUT,
    BOOTADDR => bootaddr,
    BOOTLEN  => bootlen,
    START    => mmcstart,
    DONE     => mmcdone,
    SDOUT    => SDOUT,
    SDIN     => SDIN,
    SCLK     => SCLK,
    SCS      => SCS); 

end Behavioral;



