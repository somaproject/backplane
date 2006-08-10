library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


use WORK.networkstack.all;
use WORK.networkstack;


library UNISIM;
use UNISIM.vcomponents.all;

entity network is
  port (
    CLK          : in    std_logic;
    MEMCLK       : in    std_logic;
    RESET        : in    std_logic;
    -- config
    MYIP         : in    std_logic_vector(31 downto 0);
    MYMAC        : in    std_logic_vector(47 downto 0);
    MYBCAST      : in    std_logic_vector(31 downto 0);
    -- input
    NICNEXTFRAME : out   std_logic;
    NICDINEN     : in    std_logic;
    NICDIN       : in    std_logic_vector(15 downto 0);
    -- output
    NICDOUT      : out   std_logic_vector(15 downto 0);
    NICNEWFRAME  : out   std_logic;
    NICIOCLK     : out   std_logic;
    -- event bus
    ECYCLE       : in    std_logic;
    EARX         : out   std_logic_vector(somabackplane.N -1 downto 0);
    EDRX         : out   std_logic_vector(7 downto 0);
    EDSELRX      : in    std_logic_vector(3 downto 0);
    EATX         : in    std_logic_vector(somabackplane.N -1 downto 0);
    EDTX         : in    std_logic_vector(7 downto 0);
    -- data bus
    DIENA        : in    std_logic;
    DINA         : in    std_logic_vector(7 downto 0);
    DIENB        : in    std_logic;
    DINB         : in    std_logic_vector(7 downto 0);
    -- memory interface
    RAMDQ        : inout std_logic_vector(15 downto 0);
    RAMWE        : out   std_logic;
    RAMADDR      : out   std_logic_vector(16 downto 0);
    RAMCLK       : out   std_logic
    );
end network;

architecture Behavioral of network is


  component inputcontrol
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      NEXTFRAME  : out std_logic;
      DINEN      : in  std_logic;
      DIN        : in  std_logic_vector(15 downto 0);
      PKTDATA    : out std_logic_vector(15 downto 0);
      -- ICMP echo request IO
      PINGSTART  : out std_logic;
      PINGADDR   : in  std_logic_vector(9 downto 0);
      PINGDONE   : in  std_logic;
      -- retransmit request 
      RETXSTART  : out std_logic;
      RETXADDR   : in  std_logic_vector(9 downto 0);
      RETXDONE   : in  std_logic;
      -- ARP Request
      ARPSTART   : out std_logic;
      ARPADDR    : in  std_logic_vector(9 downto 0);
      ARPDONE    : in  std_logic;
                                        -- input event
      EVENTSTART : out std_logic;
      EVENTADDR  : in  std_logic_vector(9 downto 0);
      EVENTDONE  : in  std_logic
      );
  end component;

  component txmux
    port (
      CLK      : in  std_logic;
      DEN      : in  std_logic_vector(5 downto 0);
      DIN0     : in  std_logic_vector(15 downto 0);
      DIN1     : in  std_logic_vector(15 downto 0);
      DIN2     : in  std_logic_vector(15 downto 0);
      DIN3     : in  std_logic_vector(15 downto 0);
      DIN4     : in  std_logic_vector(15 downto 0);
      DIN5     : in  std_logic_vector(15 downto 0);
      GRANT    : out std_logic_vector(5 downto 0);
     ARM      : in  std_logic_vector(5 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic
      );
  end component;


  component arpresponse
    port (
      CLK       : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;

  component pingresponse
    port (
      CLK       : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;

  component eventtx
    port (
      CLK     : in  std_logic;
      -- header fields
      MYMAC   : in  std_logic_vector(47 downto 0);
      MYIP    : in  std_logic_vector(31 downto 0);
      MYBCAST : in  std_logic_vector(31 downto 0);
      -- event interface
      ECYCLE  : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N-1 downto 0);
      -- tx IF
      DOUT    : out std_logic_vector(15 downto 0);
      DOEN    : out std_logic;
      GRANT   : in  std_logic;
      ARM     : out std_logic
      );
  end component;

  component data
    port (
      CLK      : in    std_logic;
      MEMCLK   : in    std_logic;
      ECYCLE   : in    std_logic;
      MYMAC    : in    std_logic_vector(47 downto 0);
      MYIP     : in    std_logic_vector(31 downto 0);
      MYBCAST  : in    std_logic_vector(31 downto 0);
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
      RETXTYP  : in    std_logic_vector(1 downto 0);
      RETXSEQ   : in    std_logic_vector(31 downto 0)
      );
  end component;

  component retxresponse
    port (
      CLK       : in  std_logic;
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- retx interface
      RETXDIN   : in  std_logic_vector(15 downto 0);
      RETXADDR  : in  std_logic_vector(8 downto 0);
      RETXWE    : in  std_logic;
      RETXREQ   : out std_logic;
      RETXDONE  : in  std_logic;
      RETXSRC   : out std_logic_vector(5 downto 0);
      RETXTYP   : out std_logic_vector(1 downto 0);
      RETXSEQ    : out std_logic_vector(31 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;

  component eventrx
    port (
      CLK       : in  std_logic;
      INPKTADDR : out std_logic_vector(9 downto 0);
      INPKTDATA : in  std_logic_vector(15 downto 0);
      START     : in  std_logic;
      DONE      : out std_logic;
      -- input parameters
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- Event interface
      ECYCLE    : in  std_logic;
      EARX      : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX      : out std_logic_vector(7 downto 0);
      EDSELRX   : in  std_logic_vector(3 downto 0);
      -- output to TX interface
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic;
      ARM       : out std_logic;
      GRANT     : in  std_logic);
  end component;

  -- input if

  signal pktdata : std_logic_vector(15 downto 0) := (others => '0');

  signal eventinstart : std_logic                    := '0';
  signal eventinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal eventindone  : std_logic                    := '0';

  signal arpinstart : std_logic                    := '0';
  signal arpinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal arpindone  : std_logic                    := '0';

  signal pinginstart : std_logic                    := '0';
  signal pinginaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal pingindone  : std_logic                    := '0';

  signal retxinstart             : std_logic                    := '0';
  signal retxinaddr              : std_logic_vector(9 downto 0) := (others => '0');
  signal retxindone, retxindone2 : std_logic                    := '0';

  -- output

  signal den  : std_logic_vector(5 downto 0)  := (others => '0');
  signal din0 : std_logic_vector(15 downto 0) := (others => '0');
  signal din1 : std_logic_vector(15 downto 0) := (others => '0');
  signal din2 : std_logic_vector(15 downto 0) := (others => '0');
  signal din3 : std_logic_vector(15 downto 0) := (others => '0');
  signal din4 : std_logic_vector(15 downto 0) := (others => '0');
  signal din5 : std_logic_vector(15 downto 0) := (others => '0');

  signal grant : std_logic_vector(5 downto 0) := (others => '0');
  signal arm   : std_logic_vector(5 downto 0) := (others => '0');

  -- retx interface
  signal retxdout : std_logic_vector(15 downto 0) := (others => '0');
  signal retxaddr : std_logic_vector(8 downto 0)  := (others => '0');
  signal retxwe   : std_logic                     := '0';

  signal retxreq, retxdone : std_logic                     := '0';
  signal retxsrc           : std_logic_vector(5 downto 0)  := (others => '0');
  signal retxtyp           : std_logic_vector(1 downto 0)  := (others => '0');
  signal retxseq            : std_logic_vector(31 downto 0) := (others => '0');


begin  -- Behavioral

  inputcontrol_inst : inputcontrol
    port map (
      CLK        => CLK,
      RESET      => RESET,
      NEXTFRAME  => NICNEXTFRAME,
      DINEN      => NICDINEN,
      DIN        => NICDIN,
      PKTDATA    => pktdata,
      PINGSTART  => pinginstart,
      PINGADDR   => pinginaddr,
      PINGDONE   => pingindone,
      RETXSTART  => retxinstart,
      RETXADDR   => retxinaddr,
      RETXDONE   => retxindone,
      ARPSTART   => arpinstart,
      ARPADDR    => arpinaddr,
      ARPDONE    => arpindone,
      EVENTSTART => eventinstart,
      EVENTADDR  => eventinaddr,
      EVENTDONE  => eventindone);


  txmux_inst : txmux
    port map (
      CLK      => CLK,
      DEN      => den,
      DIN0     => din0,
      DIN1     => din1,
      DIN2     => din2,
      DIN3     => din3,
      DIN4     => din4,
      DIN5     => din5,
      GRANT    => grant,
      ARM      => arm,
      DOUT     => NICDOUT,
      NEWFRAME => NICNEWFRAME);

  NICIOCLK <= CLK;

  arpresponse_inst : arpresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => arpinstart,
      DONE      => arpindone,
      INPKTDATA => pktdata,
      INPKTADDR => arpinaddr,
      ARM       => arm(4),
      GRANT     => grant(4),
      DOUT      => din4,
      DOEN      => den(4));

  pingresponse_inst : pingresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => pinginstart,
      DONE      => pingindone,
      INPKTDATA => pktdata,
      INPKTADDR => pinginaddr,
      ARM       => arm(5),
      GRANT     => grant(5),
      DOUT      => din5,
      DOEN      => den(5));

  eventtx_inst : eventtx
    port map (
      CLK     => CLK,
      MYMAC   => MYMAC,
      MYIP    => MYIP,
      MYBCAST => MYBCAST,
      ECYCLE  => ECYCLE,
      EDTX    => EDTX,
      EATX    => EATX,
      DOUT    => din0,
      DOEN    => den(0),
      ARM     => arm(0),
      GRANT   => grant(0));

  data_inst : data
    port map (
      CLK      => CLK,
      MEMCLK   => MEMCLK,
      MYIP     => MYIP,
      MYBCAST  => MYBCAST,
      MYMAC    => MYMAC,
      ECYCLE   => ECYCLE,
      DIENA    => DIENA,
      DINA     => DINA,
      DIENB    => DIENB,
      DINB     => DINB,
      RAMDQ    => RAMDQ,
      RAMWE    => RAMWE,
      RAMADDR  => RAMADDR,
      DOUT     => din1,
      DOEN     => den(1),
      ARM      => arm(1),
      GRANT    => grant(1),
      RETXDOUT => retxdout,
      RETXADDR => retxaddr,
      RETXWE   => retxwe,
      RETXREQ  => retxreq,
      RETXDONE => retxdone,
      RETXSRC  => retxsrc,
      RETXTYP  => retxtyp,
      RETXSEQ   => retxseq);

  retxresponse_inst : retxresponse
    port map (
      CLK       => CLK,
      START     => retxinstart,
      DONE      => retxindone,
      INPKTDATA => pktdata,
      INPKTADDR => retxinaddr,
      RETXDIN   => retxdout,
      RETXADDR  => retxaddr,
      RETXWE    => retxwe,
      RETXREQ   => retxreq,
      RETXDONE  => retxdone,
      RETXsrc   => retxsrc,
      RETXTYP   => retxtyp,
      RETXSEQ    => retxseq,
      ARM       => arm(2),
      GRANT     => grant(2),
      DOUT      => din2,
      DOEN      => den(2));

  eventrx_inst : eventrx
    port map (
      CLK       => CLK,
      INPKTADDR => eventinaddr,
      INPKTDATA => pktdata,
      START     => eventinstart,
      DONE      => eventindone,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      ECYCLE    => ECYCLE,
      EARX      => EARX,
      EDRX      => EDRX,
      EDSELRX   => EDSELRX,
      DOUT      => din3,
      DOEN      => den(3),
      ARM       => arm(3),
      GRANT     => grant(3));

end Behavioral;
