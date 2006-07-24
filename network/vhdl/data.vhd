library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity data is
  port (
    CLK      : in    std_logic;
    MEMCLK   : in    std_logic;
    ECYCLE   : in    std_logic;
    -- input
    DIENA    : in    std_logic;
    DINA     : in    std_logic_vector(7 downto 0);
    DIENB    : in    std_logic;
    DINB     : in    std_logic_vector(7 downto 0);
    -- memory
    RAMDQ    : inout std_logic_vector(15 downto 0);
    RAMWE    : out   std_logic;
    RAMADDR  : out   std_logic_vector(16 downto 0);
    -- tx output
    DOUT     : out   std_logic_vector(15 downto 0);
    DOEN     : out   std_logic;
    ARM      : out   std_logic;
    GRANT    : in    std_logic;
    -- retx interface
    RETXDOUT : out   std_logic_vector(15 downto 0);
    RETXADDR : out   std_logic_vector(8 downto 0);
    RETXWE   : out   std_logic;
    RETXREQ  : in    std_logic;
    RETXDONE : out   std_logic;
    RETXSRC  : in    std_logic_vector(5 downto 0);
    RETXTYPE : in    std_logic_vector(1 downto 0);
    RETXID   : in    std_logic_vector(31 downto 0)
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
  signal fvalid : std_logic                     := '0';
  signal fnext  : std_logic                     := '0';

  signal txfdin  : std_logic_vector(15 downto 0) := (others => '0');
  signal txfaddr : std_logic_vector(8 downto 0)  := (others => '0');
  signal txfull  : std_logic                     := '0';
  signal txfwe   : std_logic                     := '0';
  signal txfdone : std_logic                     := '0';

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
      MEMCLK    : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      ADDROUT   : in  std_logic_vector(8 downto 0);
      FIFOVALID : out std_logic;
      FIFONEXT  : in  std_logic
      );
  end component;

  component datamemarbit
    port (
      CLK        : in    std_logic;
      -- RAM
      RAMWE      : out   std_logic;
      RAMADDR    : out   std_logic_vector(16 downto 0);
      RAMDQ      : inout std_logic_vector(15 downto 0);
      -- memory packet input
      FIFODIN    : in    std_logic_vector(15 downto 0);
      FIFOADDR   : out   std_logic_vector(8 downto 0);
      FIFOVALID  : in    std_logic;
      FIFONEXT   : out   std_logic;
      --retx request
      RETXDOUT   : out   std_logic_vector(15 downto 0);
      RETXADDR   : out   std_logic_vector(8 downto 0);
      RETXWE     : out   std_logic;
      RETXREQ    : in    std_logic;
      RETXDONE   : out   std_logic;
      RETXSRC    : in    std_logic_vector(5 downto 0);
      RETXTYP    : in    std_logic_vector(1 downto 0);
      RETXID     : in    std_logic_vector(31 downto 0);
      -- packet transmission
      TXDOUT     : out   std_logic_vector(15 downto 0);
      TXFIFOFULL : in    std_logic;
      TXFIFOADDR : out   std_logic_vector(8 downto 0);
      TXWE       : out   std_logic;
      TXDONE     : out   std_logic
      );
  end component;

  component datafifo
    port (
      MEMCLK   : in  std_logic;
      DIN      : in  std_logic_vector(15 downto 0);
      FIFOFULL : out std_logic;
      ADDRIN   : in  std_logic_vector(8 downto 0);
      WE       : in  std_logic;
      INDONE   : in  std_logic;
      -- output interface
      CLK      : in  std_logic;
      DOEN     : out std_logic;
      ARM      : out std_logic;
      GRANT    : in  std_logic);
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
      ADDR   => dpaddrbb,
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
      MEMCLK    => MEMCLK,
      DOUT      => fdin,
      ADDROUT   => faddr,
      FIFOVALID => fvalid,
      FIFONEXT  => fnext);

  datamemarbit_inst : datamemarbit
    port map (
      CLK        => MEMCLK,
      RAMWE      => RAMWE,
      RAMADDR    => RAMADDR,
      RAMDQ      => RAMDQ,
      FIFODIN    => fdin,
      FIFOADDR   => faddr,
      FIFOVALID  => fvalid,
      FIFONEXT   => fnext,
      RETXDOUT   => RETXDOUT,
      RETXADDR   => RETXADDR,
      RETXWE     => RETXWE,
      RETXREQ    => RETXREQ,
      RETXDONE   => RETXDONE,
      RETXSRC    => RETXSRC,
      RETXTYP    => RETXTYP,
      RETXID     => RETXID,
      TXDOUT     => txfdin,
      TXFIFOFULL => txfull,
      TXFIFOADDR => txfaddr,
      TXWE       => txfwe,
      TXDONE     => txfdone);

  datafifo_inst : datafifo
    port map (
      MEMCLK   => MEMCLK,
      DIN      => txfdin,
      FIFOFULL => txfull,
      ADDRIN   => txfaddr,
      WE       => txfwe,
      INDONE   => txfdone,
      CLK      => CLK,
      DOEN     => DOEN,
      ARM      => ARM,
      GRANT    => GRANT);

end Behavioral;
