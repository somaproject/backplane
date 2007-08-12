library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity data is
  port (
    CLK         : in  std_logic;
    MEMCLK      : in  std_logic;
    ECYCLE      : in  std_logic;
    MYIP        : in  std_logic_vector(31 downto 0);
    MYMAC       : in  std_logic_vector(47 downto 0);
    MYBCAST     : in  std_logic_vector(31 downto 0);
    FIFOOFERR : out std_logic; 
    -- input
    DIENA       : in  std_logic;
    DINA        : in  std_logic_vector(7 downto 0);
    DIENB       : in  std_logic;
    DINB        : in  std_logic_vector(7 downto 0);
    -- tx output
    DOUT        : out std_logic_vector(15 downto 0);
    DOEN        : out std_logic;
    ARM         : out std_logic;
    GRANT       : in  std_logic;
    -- retx interface
    RETXID      : out std_logic_vector(13 downto 0); 
    RETXDONE    : out std_logic;
    RETXPENDING : in  std_logic;
    RETXDOUT    : out std_logic_vector(15 downto 0);
    RETXADDR    : out std_logic_vector(8 downto 0);
    RETXWE      : out std_logic;
    -- DEBUG interface
    DEBUG : out std_logic_vector(3 downto 0)
    );
end data;


architecture Behavioral of data is

  signal dpdataa : std_logic_vector(15 downto 0) := (others => '0');
  signal dpaddra : std_logic_vector(8 downto 0)  := (others => '0');
  signal dplena  : std_logic_vector(9 downto 0)  := (others => '0');

  signal dpdatab : std_logic_vector(15 downto 0) := (others => '0');
  signal dpaddrb : std_logic_vector(8 downto 0)  := (others => '0');
  signal dplenb  : std_logic_vector(9 downto 0)  := (others => '0');

  signal fdin   : std_logic_vector(15 downto 0) := (others => '0');
  signal faddr  : std_logic_vector(8 downto 0)  := (others => '0');
  signal fwe : std_logic                     := '0';
  signal fnext  : std_logic                     := '0';

  -- components
  component dataacquire
    port (
      CLK    : in  std_logic;
      ECYCLE : in  std_logic;
      DIN    : in  std_logic_vector(7 downto 0);
      DIEN   : in  std_logic;
      DOUT   : out std_logic_vector(15 downto 0);
      ADDR   : in  std_logic_vector(8 downto 0);
      LEN    : out std_logic_vector(9 downto 0));
  end component;

  component datapacketgen
    port (
      CLK       : in  std_logic;
      ECYCLE    : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      MYBCAST   : in  std_logic_vector(31 downto 0);
      ADDRA     : out std_logic_vector(8 downto 0);
      LENA      : in  std_logic_vector(9 downto 0);
      DIA       : in  std_logic_vector(15 downto 0);
      ADDRB     : out std_logic_vector(8 downto 0);
      LENB      : in  std_logic_vector(9 downto 0);
      DIB       : in  std_logic_vector(15 downto 0);
      -- output interface at 100 MHz
      DOUT      : out std_logic_vector(15 downto 0);
      ADDROUT   : out  std_logic_vector(8 downto 0);
      FWEOUT : out std_logic;
      FIFONEXT  : out  std_logic
      );
  end component;

  component datafifo
    port (
      CLK    : in  std_logic;
      FIFOOFERR : out std_logic; 
          
      -- input interfaces
      DIN    : in  std_logic_vector(15 downto 0);
      ADDRIN : in  std_logic_vector(8 downto 0);
      WEIN   : in  std_logic;
      INDONE : in  std_logic;
      -- output interface
      DOEN   : out std_logic;
      ARM    : out std_logic;
      DOUT   : out std_logic_vector(15 downto 0);
      GRANT  : in  std_logic);
  end component;

  component dataretxbuf
    port (
      CLK    : in std_logic;
      DIN    : in std_logic_vector(15 downto 0);
      ADDRIN : in std_logic_vector(8 downto 0);
      WE     : in std_logic;
      INDONE : in std_logic;

      -- output
      MEMCLK   : in  std_logic;
      WID      : out std_logic_vector(13 downto 0);
      WDOUT    : out std_logic_vector(15 downto 0);
      WADDR    : out std_logic_vector(8 downto 0);
      WROUT    : out std_logic;
      WDONE    : out std_logic;
      WPENDING : in  std_logic
      );
  end component;

begin  -- Behavioral

  dataacquireA_inst : dataacquire
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      DIN    => DINA,
      DIEN   => DIENA,
      DOUT   => dpdataa,
      ADDR   => dpaddra,
      LEN    => dplena);

  dataacquireB_inst : dataacquire
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      DIN    => DINB,
      DIEN   => DIENB,
      DOUT   => dpdatab,
      ADDR   => dpaddrb,
      LEN    => dplenb);

  datapacketgen_inst : datapacketgen
    port map (
      CLK       => CLK,
      ECYCLE    => ECYCLE,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      MYBCAST   => MYBCAST,
      ADDRA     => dpaddra,
      LENA      => dplena,
      DIA       => dpdataa,
      ADDRB     => dpaddrb,
      LENB      => dplenb,
      DIB       => dpdatab,
      DOUT      => fdin,
      ADDROUT   => faddr,
      FWEOUT => fwe,
      FIFONEXT  => fnext);

  datafifo_inst : datafifo
    port map (
      CLK    => CLK,
      FIFOOFERR => FIFOOFERR, 
      DIN    => fdin,
      ADDRIN => faddr,
      WEIN   => fwe,
      INDONE => fnext,
      DOEN   => DOEN,
      ARM    => ARM,
      DOUT   => DOUT,
      GRANT    => GRANT);

  DEBUG(0) <= FWE;
  DEBUG(1) <= FNEXT;
  
  dataretxbuf_inst: dataretxbuf
    port map (
      CLK     => CLK,
      DIN     => fdin,
      ADDRIN  => faddr,
      WE      => fwe,
      INDONE  => fnext,
      MEMCLK  => MEMCLK,
      WID     => RETXID,
      WDONE   => RETXDONE,
      WPENDING => RETXPENDING,
      WDOUT   => RETXDOUT,
      WADDR   => RETXADDR,
      WROUT   => RETXWE); 
    
end Behavioral;
