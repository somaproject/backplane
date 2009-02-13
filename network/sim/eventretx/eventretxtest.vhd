library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
use WORK.HY5PS121621F_PACK;
use WORK.HY5PS121621F_PACK.all;

use WORK.somabackplane.all;
use Work.somabackplane;

entity eventretxtest is

end eventretxtest;

architecture Behavioral of eventretxtest is

  signal CLK        : std_logic := '0';
  signal MEMCLK     : std_logic := '0';
  signal MEMCLK90   : std_logic := '0';
  signal MEMCLK180  : std_logic := '0';
  signal MEMCLK270  : std_logic := '0';
  signal MEMCLKn    : std_logic := '0';
  signal MEMCLK90n  : std_logic := '0';
  signal MEMCLK180n : std_logic := '0';
  signal MEMCLK270n : std_logic := '0';

  signal RESET   : std_logic                     := '0';
  -- config
  signal MYIP    : std_logic_vector(31 downto 0) := (others => '0');
  signal MYMAC   : std_logic_vector(47 downto 0) := (others => '0');
  signal MYBCAST : std_logic_vector(31 downto 0) := (others => '0');

  -- input
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');

  -- output
  signal NICDOUT     : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEWFRAME : std_logic                     := '0';
  signal NICIOCLK    : std_logic                     := '0';

  -- event bus
  signal ECYCLE : std_logic := '0';

  signal EARX : std_logic_vector(somabackplane.N -1 downto 0)
 := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : std_logic_vector(somabackplane.N -1 downto 0)
                                                := (others => '0');
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');

  -- data bus
  signal DIENA : std_logic                    := '0';
  signal DINA  : std_logic_vector(7 downto 0) := (others => '0');
  signal DIENB : std_logic                    := '0';
  signal DINB  : std_logic_vector(7 downto 0) := (others => '0');

-- memory interface
  signal RAMCKE  : std_logic                     := '0';
  signal RAMCAS  : std_logic                     := '0';
  signal RAMRAS  : std_logic                     := '0';
  signal RAMCS   : std_logic                     := '0';
  signal RAMWE   : std_logic                     := '0';
  signal RAMADDR : std_logic_vector(12 downto 0) := (others => '0');
  signal RAMBA   : std_logic_vector(1 downto 0)  := (others => '0');
  signal RAMDQSH : std_logic                     := '0';
  signal RAMDQSL : std_logic                     := '0';
  signal RAMDQ   : std_logic_vector(15 downto 0);


  component clockgen
    port (
      CLK        : out std_logic;
      MEMCLK     : out std_logic;
      MEMCLKn    : out std_logic;
      MEMCLK90   : out std_logic;
      MEMCLK90n  : out std_logic;
      MEMCLK180  : out std_logic;
      MEMCLK180n : out std_logic;
      MEMCLK270  : out std_logic;
      MEMCLK270n : out std_logic
      );
  end component;

  component HY5PS121621F
    generic (
      TimingCheckFlag :       boolean                       := true;
      PUSCheckFlag    :       boolean                       := false;
      Part_Number     :       PART_NUM_TYPE                 := B400);
    port
      ( DQ            : inout std_logic_vector(15 downto 0) := (others => 'Z');
        LDQS          : inout std_logic                     := 'Z';
        LDQSB         : inout std_logic                     := 'Z';
        UDQS          : inout std_logic                     := 'Z';
        UDQSB         : inout std_logic                     := 'Z';
        LDM           : in    std_logic;
        WEB           : in    std_logic;
        CASB          : in    std_logic;
        RASB          : in    std_logic;
        CSB           : in    std_logic;
        BA            : in    std_logic_vector(1 downto 0);
        ADDR          : in    std_logic_vector(12 downto 0);
        CKE           : in    std_logic;
        CLK           : in    std_logic;
        CLKB          : in    std_logic;
        UDM           : in    std_logic;
        odelay        : in    time                          := 0 ps);
  end component;



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
      DRETXSTART : out std_logic;
      DRETXADDR  : in  std_logic_vector(9 downto 0);
      DRETXDONE  : in  std_logic;

      -- retransmit request 
      ERETXSTART : out std_logic;
      ERETXADDR  : in  std_logic_vector(9 downto 0);
      ERETXDONE  : in  std_logic;

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
      CLK  : in std_logic;
      DEN  : in std_logic_vector(6 downto 0);
      DIN0 : in std_logic_vector(15 downto 0);
      DIN1 : in std_logic_vector(15 downto 0);
      DIN2 : in std_logic_vector(15 downto 0);
      DIN3 : in std_logic_vector(15 downto 0);
      DIN4 : in std_logic_vector(15 downto 0);
      DIN5 : in std_logic_vector(15 downto 0);
      DIN6 : in std_logic_vector(15 downto 0);

      GRANT    : out std_logic_vector(6 downto 0);
      ARM      : in  std_logic_vector(6 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic
      );
  end component;


  component eventtx
    port (
      CLK         : in  std_logic;
      -- header fields
      MYMAC       : in  std_logic_vector(47 downto 0);
      MYIP        : in  std_logic_vector(31 downto 0);
      MYBCAST     : in  std_logic_vector(31 downto 0);
      -- event interface
      ECYCLE      : in  std_logic;
      EDTX        : in  std_logic_vector(7 downto 0);
      EATX        : in  std_logic_vector(somabackplane.N-1 downto 0);
      -- tx IF
      DOUT        : out std_logic_vector(15 downto 0);
      DOEN        : out std_logic;
      GRANT       : in  std_logic;
      ARM         : out std_logic;
      -- Retx write interface
      RETXID      : out std_logic_vector(13 downto 0);
      RETXDOUT    : out std_logic_vector(15 downto 0);
      RETXADDR    : out std_logic_vector(8 downto 0);
      RETXDONE    : out std_logic;
      RETXPENDING : in  std_logic;
      RETXWE      : out std_logic
      );
  end component;

  component eventretxresponse
    port (
      CLK         : in  std_logic;
      -- IO interface
      START       : in  std_logic;
      DONE        : out std_logic;
      INPKTDATA   : in  std_logic_vector(15 downto 0);
      INPKTADDR   : out std_logic_vector(9 downto 0);
      PKTNOTINBUF : out std_logic;
      RETXSUCCESS : out std_logic;
      -- retx interface
      RETXDIN     : in  std_logic_vector(15 downto 0);
      RETXADDR    : in  std_logic_vector(8 downto 0);
      RETXWE      : in  std_logic;
      RETXREQ     : out std_logic;
      RETXDONE    : in  std_logic;
      RETXID      : out std_logic_vector(13 downto 0);
      -- output
      ARM         : out std_logic;
      GRANT       : in  std_logic;
      DOUT        : out std_logic_vector(15 downto 0);
      DOEN        : out std_logic);
  end component;

  component memddr2
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET  : in    std_logic;
      -- RAM!
      CKE    : out   std_logic := '0';
      CAS    : out   std_logic;
      RAS    : out   std_logic;
      CS     : out   std_logic;
      WE     : out   std_logic;
      ADDR   : out   std_logic_vector(12 downto 0);
      BA     : out   std_logic_vector(1 downto 0);
      DQSH   : inout std_logic;
      DQSL   : inout std_logic;
      DQ     : inout std_logic_vector(15 downto 0);
      -- interface
      START  : in    std_logic;
      RW     : in    std_logic;
      DONE   : out   std_logic;
      -- write interface
      ROWTGT : in    std_logic_vector(14 downto 0);
      WRADDR : out   std_logic_vector(7 downto 0);
      WRDATA : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out   std_logic_vector(7 downto 0);
      RDDATA : out   std_logic_vector(31 downto 0);
      RDWE   : out   std_logic
      );
  end component;



  component retxbuffer
    port (
      CLK   : in std_logic;
      CLKHI : in std_logic;

      -- buffer set A input (write) interface
      WIDA      : in  std_logic_vector(13 downto 0);
      WDINA     : in  std_logic_vector(15 downto 0);
      WADDRA    : in  std_logic_vector(8 downto 0);
      WRA       : in  std_logic;
      WDONEA    : in  std_logic;
      WPENDINGA : out std_logic;
      WCLKA     : in  std_logic;

      -- output buffer A  (reads) interface
      RIDA    : in  std_logic_vector (13 downto 0);
      RREQA   : in  std_logic;
      RDOUTA  : out std_logic_vector(15 downto 0);
      RADDRA  : out std_logic_vector(8 downto 0);
      RDONEA  : out std_logic;
      RWROUTA : out std_logic;
      RCLKA   : in  std_logic;

      --buffer set B input (write) interfafe
      WIDB      : in  std_logic_vector(13 downto 0);
      WDINB     : in  std_logic_vector(15 downto 0);
      WADDRB    : in  std_logic_vector(8 downto 0);
      WRB       : in  std_logic;
      WDONEB    : in  std_logic;
      WPENDINGB : out std_logic;

      WCLKB : in std_logic;

      -- output buffer B set Rad (reads) interface
      RIDB    : in  std_logic_vector (13 downto 0);
      RREQB   : in  std_logic;
      RDOUTB  : out std_logic_vector(15 downto 0);
      RADDRB  : out std_logic_vector(8 downto 0);
      RDONEB  : out std_logic;
      RWROUTB : out std_logic;
      RCLKB   : in  std_logic;

      -- memory output interface
      MEMSTART  : out std_logic;
      MEMRW     : out std_logic;
      MEMDONE   : in  std_logic;
      MEMWRADDR : in  std_logic_vector(7 downto 0);
      MEMWRDATA : out std_logic_vector(31 downto 0) := (others => '0');
      MEMROWTGT : out std_logic_vector(14 downto 0);
      MEMRDDATA : in  std_logic_vector(31 downto 0);
      MEMRDADDR : in  std_logic_vector(7 downto 0);
      MEMRDWE   : in  std_logic
      );
  end component;

-- memory
  signal memstart : std_logic := '0';
  signal memrw    : std_logic := '0';
  signal memdone  : std_logic := '0';

  signal memrowtgt : std_logic_vector(14 downto 0) := (others => '0');
  signal memwraddr : std_logic_vector(7 downto 0)  := (others => '0');
  signal memwrdata : std_logic_vector(31 downto 0) := (others => '0');
  -- read interface
  signal memrdaddr : std_logic_vector(7 downto 0)  := (others => '0');
  signal memrddata : std_logic_vector(31 downto 0) := (others => '0');
  signal memrdwe   : std_logic                     := '0';


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

  signal eretxinstart : std_logic                    := '0';
  signal eretxinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal eretxindone  : std_logic                    := '0';

  signal dretxinstart : std_logic                    := '0';
  signal dretxinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal dretxindone  : std_logic                    := '0';

  -- output

  signal den  : std_logic_vector(6 downto 0)  := (others => '0');
  signal din0 : std_logic_vector(15 downto 0) := (others => '0');
  signal din1 : std_logic_vector(15 downto 0) := (others => '0');
  signal din2 : std_logic_vector(15 downto 0) := (others => '0');
  signal din3 : std_logic_vector(15 downto 0) := (others => '0');
  signal din4 : std_logic_vector(15 downto 0) := (others => '0');
  signal din5 : std_logic_vector(15 downto 0) := (others => '0');
  signal din6 : std_logic_vector(15 downto 0) := (others => '0');


  signal grant : std_logic_vector(6 downto 0) := (others => '0');
  signal arm   : std_logic_vector(6 downto 0) := (others => '0');

  -- retx interface
  signal retxdout : std_logic_vector(15 downto 0) := (others => '0');
  signal retxaddr : std_logic_vector(8 downto 0)  := (others => '0');
  signal retxwe   : std_logic                     := '0';



  -- clock signals
  signal clkf, clkfint, clk2f : std_logic := '0';
  signal dcmlocked            : std_logic := '0';

  -- buffer set A input (write) interface
  signal wida      : std_logic_vector(13 downto 0) := (others => '0');
  signal wdina     : std_logic_vector(15 downto 0) := (others => '0');
  signal waddra    : std_logic_vector(8 downto 0)  := (others => '0');
  signal wra       : std_logic                     := '0';
  signal wdonea    : std_logic                     := '0';
  signal wpendinga : std_logic                     := '0';
  signal wclka     : std_logic                     := '0';

  -- output buffer A  (reads) interface
  signal rida    : std_logic_vector (13 downto 0) := (others => '0');
  signal rreqa   : std_logic                      := '0';
  signal rdouta  : std_logic_vector(15 downto 0)  := (others => '0');
  signal raddra  : std_logic_vector(8 downto 0)   := (others => '0');
  signal rdonea  : std_logic                      := '0';
  signal rwrouta : std_logic                      := '0';
  signal rclka   : std_logic                      := '0';

  --buffer set B input (write) interfafe
  signal widb      : std_logic_vector(13 downto 0) := (others => '0');
  signal wdinb     : std_logic_vector(15 downto 0) := (others => '0');
  signal waddrb    : std_logic_vector(8 downto 0)  := (others => '0');
  signal wrb       : std_logic                     := '0';
  signal wdoneb    : std_logic                     := '0';
  signal wpendingb : std_logic                     := '0';
  signal wclkb     : std_logic                     := '0';

  -- output buffer B set Rad (reads) interface
  signal ridb    : std_logic_vector (13 downto 0) := (others => '0');
  signal rreqb   : std_logic                      := '0';
  signal rdoutb  : std_logic_vector(15 downto 0)  := (others => '0');
  signal raddrb  : std_logic_vector(8 downto 0)   := (others => '0');
  signal rdoneb  : std_logic                      := '0';
  signal rwroutb : std_logic                      := '0';
  signal rclkb   : std_logic                      := '0';

  signal epos : integer := 900;

  signal event_rxgood    : std_logic := '0';
  signal event_rxmissing : std_logic := '0';
  signal event_rxcnt     : integer   := 0;

-- event signals
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0)
 := (others => '0');

  signal odelay : time := 0 ps;

  signal startwait : std_logic := '1';

  component eventrxdecode
    port (
      CLK         : in  std_logic;
      NICNEWFRAME : in  std_logic;
      NICDINEN    : in  std_logic;
      NICDIN      : in  std_logic_vector(15 downto 0);
      RXIDEN      : out std_logic;
      RXID        : out std_logic_vector(31 downto 0);
      RXTSEN      : out std_logic;
      RXTS        : out std_logic_vector(47 downto 0)
      );
  end component;

  signal eventrxid : std_logic_vector(31 downto 0);
  signal eventrxts : std_logic_vector(47 downto 0);

  component retxreq
    port (
      CLK       : in  std_logic;
      NEXTFRAME : in  std_logic;
      DOEN      : out std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      REQ       : in  std_logic;
      ID        : in  std_logic_vector(31 downto 0);
      DONE      : out std_logic);
  end component;

  signal retxreqid   : std_logic_vector(31 downto 0);
  signal retxreqreq  : std_logic := '0';
  signal retxreqdone : std_logic := '0';

begin  -- Behavioral

  clockgen_inst : clockgen
    port map (
      CLK        => CLK,
      MEMCLK     => MEMCLK,
      MEMCLK90   => MEMCLK90,
      MEMCLK180  => MEMCLK180,
      MEMCLK270  => MEMCLK270,
      MEMCLKn    => MEMCLKn,
      MEMCLK90n  => MEMCLK90n,
      MEMCLK180n => MEMCLK180n,
      MEMCLK270n => MEMCLK270n );

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
      DRETXSTART => dretxinstart,
      DRETXADDR  => dretxinaddr,
      DRETXDONE  => dretxindone,
      ERETXSTART => eretxinstart,
      ERETXADDR  => eretxinaddr,
      ERETXDONE  => eretxindone,

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
      DIN6     => din6,
      GRANT    => grant,
      ARM      => arm,
      DOUT     => NICDOUT,
      NEWFRAME => NICNEWFRAME);


  eventtx_inst : eventtx
    port map (
      CLK         => CLK,
      MYMAC       => MYMAC,
      MYIP        => MYIP,
      MYBCAST     => MYBCAST,
      ECYCLE      => ECYCLE,
      EDTX        => EDTX,
      EATX        => EATX,
      DOUT        => din0,
      DOEN        => den(0),
      ARM         => arm(0),
      GRANT       => grant(0),
      RETXID      => widb,
      RETXDOUT    => wdinb,
      RETXADDR    => waddrb,
      RETXWE      => wrb,
      RETXDONE    => wdoneb,
      RETXPENDING => wpendingb
      );

  eventretxresponse_inst : eventretxresponse
    port map (
      CLK       => CLK,
      START     => eretxinstart,
      DONE      => eretxindone,
      INPKTDATA => pktdata,
      INPKTADDR => eretxinaddr,
      RETXDIN   => rdoutb,
      RETXADDR  => raddrb,
      RETXWE    => rwroutb,
      RETXREQ   => rreqb,
      RETXDONE  => rdoneb,
      RETXID    => ridb,
      ARM       => arm(3),
      GRANT     => grant(3),
      DOUT      => din3,
      DOEN      => den(3));

  retxbuffer_inst : retxbuffer
    port map (
      CLK       => CLK,
      CLKHI     => MEMCLK,
      WIDA      => WIDA,
      WDINA     => wdina,
      WADDRA    => waddra,
      WRA       => wra,
      WDONEA    => wdonea,
      WPENDINGA => wpendinga,
      WCLKA     => MEMCLK,
      RIDA      => rida,
      RREQA     => rreqa,
      RDOUTA    => rdouta,
      RADDRA    => raddra,
      RDONEA    => rdonea,
      RWROUTA   => rwrouta,
      RCLKA     => CLK,
      WIDB      => widb,
      WDINB     => wdinb,
      WADDRB    => waddrb,
      WRB       => wrb,
      WDONEB    => wdoneb,
      WPENDINGB => wpendingb,
      WCLKB     => CLK,
      RIDB      => ridb,
      RREQB     => rreqb,
      RDOUTB    => rdoutb,
      RADDRB    => raddrb,
      RDONEB    => rdoneb,
      RWROUTB   => rwroutb,
      RCLKB     => clk,
      MEMSTART  => memstart,
      MEMRW     => memrw,
      MEMDONE   => memdone,
      MEMWRADDR => memwraddr,
      MEMWRDATA => memwrdata,
      MEMROWTGT => memrowtgt,
      MEMRDDATA => memrddata,
      MEMRDADDR => memrdaddr,
      MEMRDWE   => memrdwe);

  memddr2_inst : memddr2
    port map (
      CLK    => MEMCLK,
      CLK90  => memclk90,
      CLK180 => memclk180,
      CLK270 => memclk270,
      RESET  => RESET,
      CKE    => RAMCKE,
      CAS    => RAMCAS,
      RAS    => RAMRAS,
      CS     => RAMCS,
      WE     => RAMWE,
      ADDR   => RAMADDR,
      BA     => RAMBA,
      DQSH   => RAMDQSH,
      DQSL   => RAMDQSL,
      DQ     => RAMDQ,
      START  => MEMSTART,
      RW     => MEMRW,
      DONE   => memdone,
      ROWTGT => memrowtgt,
      WRADDR => memwraddr,
      WRDATA => memwrdata,
      RDADDR => memrdaddr,
      RDDATA => memrddata,
      RDWE   => memrdwe);

  memory_inst : HY5PS121621F
    generic map (
      TimingCheckFlag => true,
      PUSCheckFlag    => true,
      PArt_number     => B400)
    port map (
      DQ              => RAMDQ,
      LDQS            => RAMDQSL,
      UDQS            => RAMDQSH,
      WEB             => RAMWE,
      LDM             => '0',
      UDM             => '0',
      CASB            => RAMCAS,
      RASB            => RAMRAS,
      CSB             => RAMCS,
      BA              => RAMBA,
      ADDR            => RAMADDR,
      CKE             => RAMCKE,
      CLK             => MEMCLK90,
      CLKB            => MEMCLK90N,
      odelay          => odelay);


  NICIOCLK <= CLK;

  RESET     <= '0' after 20 ns;
  STARTWAIT <= '0' after 300 us;


  ecycle_gen : process(CLK)
  begin
    if rising_edge(CLK) then
      if startwait = '0' then
        if epos = 999 then
          epos <= 0;
        else
          epos <= epos + 1;
        end if;

      end if;
      if epos = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process;
  -- configuration fields for device identity
  -- 
  myip    <= X"C0a80002";               -- 192.168.0.2
  mybcast <= X"C0a000FF";
  mymac   <= X"DEADBEEF1234";

  event_packet_generation : process
  begin
    while true loop
      wait until rising_edge(CLK) and epos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;
  end process;

  EATX                    <= (others                                 => '1');
  -- time stamp event
  ts_eventgen             : process(CLK)
    variable eventtimepos : std_logic_vector(47 downto 0) := (others => '0');
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        eventinputs(0)(0) <= X"1000";
        eventinputs(0)(1) <= eventtimepos(47 downto 32);
        eventinputs(0)(2) <= eventtimepos(31 downto 16);
        eventinputs(0)(3) <= eventtimepos(15 downto 0);

        eventtimepos := eventtimepos + 1;
      end if;
    end if;
  end process;

  eventrxdecode_inst : eventrxdecode
    port map (
      CLK         => NICIOCLK,
      NICNEWFRAME => NICNEWFRAME,
      NICDINEN    => NICDINEN,
      NICDIN      => NICDOUT,
      RXIDEN      => open,
      RXID        => eventrxid,
      RXTSEN      => open,
      RXTS        => eventrxts);

  retxreq_inst : retxreq
    port map (
      CLK       => NICIOCLK,
      NEXTFRAME => NICNEXTFRAME,
      DOEN      => NICDINEN,
      DOUT      => NICDIN,
      REQ       => retxreqreq,
      ID        => retxreqid,
      DONE      => retxreqdone);


  -- request retransmissions and verify

  process
  begin
    wait for 500 us;
    retxreqid <= X"00000000";
    wait until rising_edge(CLK);

    for i in 0 to 10 loop

      retxreqid <= retxreqid + 1;
      wait until rising_edge(CLK);


      retxreqreq <= '1';
      wait until rising_edge(CLK);
      retxreqreq <= '0';

      wait until rising_edge(CLK) and eventrxid = retxreqid;

    end loop;  -- i

    report "End of Simulation" severity failure;



  end process;


end Behavioral;


