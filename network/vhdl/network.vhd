library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library SOMA;
use SOMA.somabackplane.all;
use soma.somabackplane;

library memory;
use memory.all;


library UNISIM;
use UNISIM.vcomponents.all;

entity network is
  port (
    CLK          : in    std_logic;
    MEMCLK       : in    std_logic;
    MEMCLK90     : in    std_logic;
    MEMCLK180    : in    std_logic;
    MEMCLK270    : in    std_logic;
    RESET        : in    std_logic;
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
    RAMCKE       : out   std_logic := '0';
    RAMCAS       : out   std_logic;
    RAMRAS       : out   std_logic;
    RAMCS        : out   std_logic;
    RAMWE        : out   std_logic;
    RAMADDR      : out   std_logic_vector(12 downto 0);
    RAMBA        : out   std_logic_vector(1 downto 0);
    RAMDQSH      : inout std_logic;
    RAMDQSL      : inout std_logic;
    RAMDQ        : inout std_logic_vector(15 downto 0);
    -- config
    MYIP         : in    std_logic_vector(31 downto 0);
    MYMAC        : in    std_logic_vector(47 downto 0);
    MYBCAST      : in    std_logic_vector(31 downto 0);
    -- error signals and counters
    RXIOCRCERR   : out   std_logic;
    UNKNOWNETHER : out   std_logic;
    UNKNOWNIP    : out   std_logic;
    UNKNOWNUDP   : out   std_logic;
    UNKNOWNARP   : out   std_logic;
    TXPKTLENEN   : out   std_logic;
    TXPKTLEN     : out   std_logic_vector(15 downto 0);
    TXCHAN       : out   std_logic_vector(2 downto 0);
    EVTRXSUC     : out   std_logic;
    EVTFIFOFULL  : out   std_logic;

    -- DEBUG
    DEBUG : out std_logic_vector(15 downto 0)
    );
end network;

architecture Behavioral of network is


  component inputcontrol
    port (
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      NEXTFRAME    : out std_logic;
      DINEN        : in  std_logic;
      DIN          : in  std_logic_vector(15 downto 0);
      PKTDATA      : out std_logic_vector(15 downto 0);
      -- error counters
      CRCIOERR     : out std_logic;
      UNKNOWNETHER : out std_logic;
      UNKNOWNIP    : out std_logic;
      UNKNOWNUDP   : out std_logic;
      UNKNOWNARP   : out std_logic;

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
      EVENTDONE  : in  std_logic;
      DEBUG : out std_logic_vector(15 downto 0)
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
      NEWFRAME : out std_logic;
      -- staus output
      PKTLEN   : out std_logic_vector(15 downto 0);
      PKTLENEN : out std_logic;
      TXCHAN   : out std_logic_vector(2 downto 0)
      );
  end component;


  component arpresponse
    port (
      CLK        : in  std_logic;
      MYMAC      : in  std_logic_vector(47 downto 0);
      MYIP       : in  std_logic_vector(31 downto 0);
      -- IO interface
      START      : in  std_logic;
      DONE       : out std_logic;
      INPKTDATA  : in  std_logic_vector(15 downto 0);
      INPKTADDR  : out std_logic_vector(9 downto 0);
      PKTSUCCESS : out std_logic;
      -- output
      ARM        : out std_logic;
      GRANT      : in  std_logic;
      DOUT       : out std_logic_vector(15 downto 0);
      DOEN       : out std_logic);
  end component;

  component pingresponse
    port (
      CLK        : in  std_logic;
      MYMAC      : in  std_logic_vector(47 downto 0);
      MYIP       : in  std_logic_vector(31 downto 0);
      -- IO interface
      START      : in  std_logic;
      DONE       : out std_logic;
      INPKTDATA  : in  std_logic_vector(15 downto 0);
      INPKTADDR  : out std_logic_vector(9 downto 0);
      PKTSUCCESS : out std_logic;
      -- output
      ARM        : out std_logic;
      GRANT      : in  std_logic;
      DOUT       : out std_logic_vector(15 downto 0);
      DOEN       : out std_logic);
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
      PKTSUCCESS  : out std_logic;
      -- Retx write interface
      RETXID      : out std_logic_vector(13 downto 0);
      RETXDOUT    : out std_logic_vector(15 downto 0);
      RETXADDR    : out std_logic_vector(8 downto 0);
      RETXDONE    : out std_logic;
      RETXPENDING : in  std_logic;
      RETXWE      : out std_logic
      );
  end component;

  component data
    port (
      CLK         : in  std_logic;
      MEMCLK      : in  std_logic;
      ECYCLE      : in  std_logic;
      MYIP        : in  std_logic_vector(31 downto 0);
      MYMAC       : in  std_logic_vector(47 downto 0);
      MYBCAST     : in  std_logic_vector(31 downto 0);
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
      -- debug
      DEBUG       : out std_logic_vector(3 downto 0)
      );
  end component;

  component dataretxresponse
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
      RETXID    : out std_logic_vector(13 downto 0);

      -- output
      ARM   : out std_logic;
      GRANT : in  std_logic;
      DOUT  : out std_logic_vector(15 downto 0);
      DOEN  : out std_logic);
  end component;

  component eventrx
    port (
      CLK         : in  std_logic;
      INPKTADDR   : out std_logic_vector(9 downto 0);
      INPKTDATA   : in  std_logic_vector(15 downto 0);
      START       : in  std_logic;
      DONE        : out std_logic;
      EVTRXSUC    : out std_logic;
      EVTFIFOFULL : out std_logic;

      -- input parameters
      MYMAC   : in  std_logic_vector(47 downto 0);
      MYIP    : in  std_logic_vector(31 downto 0);
      -- Event interface
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      -- output to TX interface
      DOUT    : out std_logic_vector(15 downto 0);
      DOEN    : out std_logic;
      ARM     : out std_logic;
      GRANT   : in  std_logic);
  end component;

  component eventretxresponse
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
      RETXID    : out std_logic_vector(13 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
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

  component crcappend
    port (
      CLK    : in  std_logic;
      DINEN  : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      DOUT   : out std_logic_vector(15 downto 0);
      DOUTEN : out std_logic
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

  signal txdout              : std_logic_vector(15 downto 0) := (others => '0');
  signal txdouten, txdoutenl : std_logic                     := '0';

  -- retx interface
  signal retxdout : std_logic_vector(15 downto 0) := (others => '0');
  signal retxaddr : std_logic_vector(8 downto 0)  := (others => '0');
  signal retxwe   : std_logic                     := '0';

  signal retxreq, retxdone : std_logic                     := '0';
  signal retxsrc           : std_logic_vector(5 downto 0)  := (others => '0');
  signal retxtyp           : std_logic_vector(1 downto 0)  := (others => '0');
  signal retxseq           : std_logic_vector(31 downto 0) := (others => '0');


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

  signal lnicdout     : std_logic_vector(15 downto 0);
  signal lnicnewframe : std_logic := '0';
  signal txdoutenl2   : std_logic := '0';

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
      EVENTDONE  => eventindone,

      CRCIOERR     => RXIOCRCERR,
      UNKNOWNETHER => UNKNOWNETHER,
      UNKNOWNIP    => UNKNOWNIP,
      UNKNOWNUDP   => UNKNOWNUDP,
      UNKNOWNARP   => UNKNOWNARP,
      DEBUG => DEBUG
      );


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
      DOUT     => txdout,
      NEWFRAME => txdouten,
      PKTLEN   => TXPKTLEN,
      PKTLENEN => TXPKTLENEN,
      TXCHAN   => TXCHAN
      );

  crcappend_inst : crcappend
    port map (
      CLK    => CLK,
      DINEN  => txdouten,
      DIN    => txdout,
      DOUT   => lNICDOUT,
      DOUTEN => lNICNEWFRAME);


  arpresponse_inst : arpresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => arpinstart,
      DONE      => arpindone,
      INPKTDATA => pktdata,
      INPKTADDR => arpinaddr,
      ARM       => arm(5),
      GRANT     => grant(5),
      DOUT      => din5,
      DOEN      => den(5));

  pingresponse_inst : pingresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => pinginstart,
      DONE      => pingindone,
      INPKTDATA => pktdata,
      INPKTADDR => pinginaddr,
      ARM       => arm(6),
      GRANT     => grant(6),
      DOUT      => din6,
      DOEN      => den(6));

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

  data_inst : data
    port map (
      CLK         => CLK,
      MEMCLK      => memclk,
      MYIP        => MYIP,
      MYBCAST     => MYBCAST,
      MYMAC       => MYMAC,
      ECYCLE      => ECYCLE,
      DIENA       => DIENA,
      DINA        => DINA,
      DIENB       => DIENB,
      DINB        => DINB,
      DOUT        => din1,
      DOEN        => den(1),
      ARM         => arm(1),
      GRANT       => grant(1),
      RETXID      => wida,
      RETXDONE    => wdonea,
      RETXPENDING => wpendinga,
      RETXDOUT    => wdina,
      RETXADDR    => waddra,
      RETXWE      => wra

      );

  dataretxresponse_inst : dataretxresponse
    port map (
      CLK       => CLK,
      START     => dretxinstart,
      DONE      => dretxindone,
      INPKTDATA => pktdata,
      INPKTADDR => dretxinaddr,
      RETXDIN   => rdouta,
      RETXADDR  => raddra,
      RETXWE    => rwrouta,
      RETXREQ   => rreqa,
      RETXDONE  => rdonea,
      RETXID    => rida,
      ARM       => arm(2),
      GRANT     => grant(2),
      DOUT      => din2,
      DOEN      => den(2));

  eventrx_inst : eventrx
    port map (
      CLK         => CLK,
      INPKTADDR   => eventinaddr,
      INPKTDATA   => pktdata,
      START       => eventinstart,
      DONE        => eventindone,
      EVTRXSUC    => EVTRXSUC,
      EVTFIFOFULL => EVTFIFOFULL,

      MYMAC   => MYMAC,
      MYIP    => MYIP,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      DOUT    => din4,
      DOEN    => den(4),
      ARM     => arm(4),
      GRANT   => grant(4));

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

  memddr2_inst : entity memory.memddr2
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


  process(CLK)
    variable newframel, newframel2 : std_logic := '0';
  begin
    if rising_edge(CLK) then
      txdoutenl2  <= txdouten;
      txdoutenl   <= lnicnewframe;
      NICDOUT     <= lnicdout;
      NICNEWFRAME <= lnicnewframe;


    end if;
  end process;
  NICIOCLK <= clk;

end Behavioral;
