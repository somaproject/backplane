library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity boot is
  port (
    CLK    : in  std_logic;
    SCS    : out std_logic;
    SDIN   : in  std_logic;
    SDOUT  : out std_logic;
    SCLK   : out std_logic;
    FSDIN  : out std_logic;
    FSDOUT : in  std_logic;
    FSCS   : in  std_logic; 
    FSCLK  : in  std_logic;
    FPROG : out std_logic;
    FCLK : out std_logic;
    FDIN : out std_logic
    );

end boot;


architecture Behavioral of boot is

  component mmcio
    port ( CLK    : in  std_logic;
           RESET  : in  std_logic;
           SCS    : out std_logic;
           SDIN   : in  std_logic;
           SDOUT  : out std_logic;
           SCLK   : out std_logic;
           DOUT   : out std_logic_vector(7 downto 0);
           DSTART : in  std_logic;
           ADDR   : in  std_logic_vector(15 downto 0);
           DVALID : out std_logic;
           DDONE  : out std_logic
           );
  end component;

  component xilinxcfg
    port (
      CLK    : in  std_logic;
      DSTART : out std_logic;
      DIN    : in  std_logic_vector(7 downto 0);
      DDONE  : in  std_logic;
      DVALID : in  std_logic;
      ADDR   : out std_logic_vector(15 downto 0);
      FCLK   : out std_logic;
      FPROG  : out std_logic;
      FDIN   : out std_logic;
      FSEL   : out std_logic
      );

  end component;

  signal bscs, bsdin, bsdout, bsclk : std_logic := '0';

  signal data : std_logic_vector(7 downto 0) := (others => '0');
 signal dstart : std_logic := '0';
 signal addr : std_logic_vector(15 downto 0) := (others => '0');
 signal dvalid, ddone : std_logic := '0';

  signal fsel : std_logic := '0';

begin  -- Behavioral 


  bsdin <= SDIN;
 --  fsdin <= SDIN;


  SCS   <= bscs;-- when FSEL = '0' else fscs;
  
  SCLK  <= bsclk ;--  when FSEL = '0' else fsclk;
  SDOUT <= bsdout; -- when FSEL = '0' else fsdout;

  mmcio_inst : mmcio
    port map (
      CLK    => CLK,
      RESET  => '0',
      SCS    => bscs,
      SDIN   => bsdin,
      SDOUT  => bsdout,
      SCLK   => bsclk,
      DOUT   => data,
      DSTART => dstart,
      ADDR   => addr,
      DVALID => dvalid,
      DDONE  => ddone);

  xilinxcfg_inst : xilinxcfg
    port map (
      CLK    => CLK,
      DSTART => dstart,
      DIN    => data,
      DDONE   => ddone,
      DVALID => dvalid,
      ADDR   => addr,
      FCLK   => FCLK,
      FPROG  => FPROG,
      FDIN   => FDIN,
      FSEL   => fsel);

end Behavioral ;

