library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity fakedspboard is
  port (
    CLK    : in  std_logic;
    RXDIN  : in  std_logic_vector(7 downto 0);
    RXKIN  : in  std_logic;
    TXDOUT : out std_logic_vector(7 downto 0);
    TXKOUT : out std_logic
    );                                  -- '0'
end fakedspboard;


architecture Behavioral of fakedspboard is
  -------------------------------------------------------------------------------
  -- DSP Components
  -----------------------------------------------------------------------------
  component decodemux
    port (
      CLK    : in std_logic;
      DIN    : in std_logic_vector(7 downto 0);
      KIN    : in std_logic;
      LOCKED : in std_logic;

      ECYCLE       : out std_logic;
      EDATA        : out std_logic_vector(7 downto 0);
      HEADERDONE   : out std_logic;
      BSTARTCYCLE  : out std_logic;
      -- data interface
      DGRANTA      : out std_logic;
      EARXBYTEA    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELA : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTB      : out std_logic;
      EARXBYTEB    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELB : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTC      : out std_logic;
      EARXBYTEC    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELC : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTD      : out std_logic;
      EARXBYTED    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELD : in  std_logic_vector(3 downto 0) := (others => '0')

      );
  end component;

  component encodemux
    port (
      CLK         : in  std_logic;
      ECYCLE      : in  std_logic;
      DOUT        : out std_logic_vector(7 downto 0);
      KOUT        : out std_logic;
      -- data interface
      DREQ        : in  std_logic;
      DGRANT      : out std_logic;
      DDONE       : in  std_logic;
      DDATA       : in  std_logic_vector(7 downto 0);
      DKIN        : in  std_logic;
      DATAEN      : out std_logic;
      -- event interface for DSPs
      EDSPREQ     : in  std_logic_vector(3 downto 0);
      EDSPGRANT   : out std_logic_vector(3 downto 0);
      EDSPDONE    : in  std_logic_vector(3 downto 0);
      EDSPDATAEN  : out std_logic;
      EDSPDATAA   : in  std_logic_vector(7 downto 0);
      EDSPDATAB   : in  std_logic_vector(7 downto 0);
      EDSPDATAC   : in  std_logic_vector(7 downto 0);
      EDSPDATAD   : in  std_logic_vector(7 downto 0);
      -- event interface for EPROCs
      EPROCREQ    : in  std_logic_vector(3 downto 0);
      EPROCGRANT  : out std_logic_vector(3 downto 0);
      EPROCDONE   : in  std_logic_vector(3 downto 0);
      EPROCDATAEN : out std_logic;
      EPROCDATAA  : in  std_logic_vector(7 downto 0);
      EPROCDATAB  : in  std_logic_vector(7 downto 0);
      EPROCDATAC  : in  std_logic_vector(7 downto 0);
      EPROCDATAD  : in  std_logic_vector(7 downto 0);
      DEBUG       : out std_logic_vector(63 downto 0));
  end component;

  signal dsp_decode_LOCKED : std_logic := '0';

  signal ECYCLE           : std_logic                    := '0';
  signal dsp_decode_EDATA : std_logic_vector(7 downto 0);
  signal HEADERDONE       : std_logic                    := '0';
  signal BSTARTCYCLE      : std_logic                    := '0';
  -- data interface
  signal dgrantin         : std_logic_vector(3 downto 0) := (others => '0');

  signal dsp_decode_EARXBYTEA    : std_logic_vector(7 downto 0) := (others => '0');
  signal dsp_decode_EARXBYTESELA : std_logic_vector(3 downto 0) := (others => '0');

  signal dsp_decode_EARXBYTEB    : std_logic_vector(7 downto 0) := (others => '0');
  signal dsp_decode_EARXBYTESELB : std_logic_vector(3 downto 0) := (others => '0');

  signal dsp_decode_EARXBYTEC    : std_logic_vector(7 downto 0) := (others => '0');
  signal dsp_decode_EARXBYTESELC : std_logic_vector(3 downto 0) := (others => '0');

  signal dsp_decode_EARXBYTED    : std_logic_vector(7 downto 0) := (others => '0');
  signal dsp_decode_EARXBYTESELD : std_logic_vector(3 downto 0) := (others => '0');

  signal dataen : std_logic := '0';

  type   darray_t is array (0 to 3) of std_logic_vector(7 downto 0);
  signal ddataarray : darray_t := (others => (others => '0'));

  component datamux
    port (
      CLK          : in  std_logic;
      ECYCLE       : in  std_logic;
      -- collection of grants
      DGRANTIN     : in  std_logic_vector(3 downto 0);
      -- datamux interface
      ENCDOUT      : out std_logic_vector(7 downto 0);
      ENCDNEXTBYTE : in  std_logic;
      ENCDREQ      : out std_logic;
      ENCDLASTBYTE : out std_logic;
      -- individual datasport interfaces
      DDATAA       : in  std_logic_vector(7 downto 0);
      DDATAB       : in  std_logic_vector(7 downto 0);
      DDATAC       : in  std_logic_vector(7 downto 0);
      DDATAD       : in  std_logic_vector(7 downto 0);
      DNEXTBYTE    : out std_logic_vector(3 downto 0);
      DREQ         : in  std_logic_vector(3 downto 0);
      DLASTBYTE    : in  std_logic_vector(3 downto 0)
      );
  end component;
  component encodedata
    port (
      CLK          : in  std_logic;     -- '0'
      ECYCLE       : in  std_logic;
      ENCODEEN     : in  std_logic;
      HEADERDONE   : in  std_logic;
      -- encodemux interface
      DREQ         : out std_logic;
      DGRANT       : in  std_logic;
      DDONE        : out std_logic;
      DDATA        : out std_logic_vector(7 downto 0);
      DKIN         : out std_logic;
      -- datamux interface
      BSTARTCYCLE  : in  std_logic;
      ENCDOUT      : in  std_logic_vector(7 downto 0);
      ENCDNEXTBYTE : out std_logic;
      ENCDREQ      : in  std_logic;
      ENCDLASTBYTE : in  std_logic
      );
  end component;


  component datasport
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      -- serial IO
      SERCLK   : in  std_logic;
      SERDT    : in  std_logic;
      SERTFS   : in  std_logic;
      FULL     : out std_logic;
      -- FiFO interface
      REQ      : out std_logic;
      NEXTBYTE : in  std_logic;
      LASTBYTE : out std_logic;
      DOUT     : out std_logic_vector(7 downto 0)); 
  end component;

  signal dreq      : std_logic_vector(3 downto 0) := (others => '0');
  signal dnextbyte : std_logic_vector(3 downto 0) := (others => '0');
  signal dlastbyte : std_logic_vector(3 downto 0) := (others => '0');

  signal encddata     : std_logic_vector(7 downto 0) := (others => '0');
  signal encdnextbyte : std_logic                    := '0';
  signal encdreq      : std_logic                    := '0';
  signal encdlastbyte : std_logic                    := '0';


  signal datadataen : std_logic                    := '0';
  signal datadreq   : std_logic                    := '0';
  signal datadgrant : std_logic                    := '0';
  signal dataddone  : std_logic                    := '0';
  signal dataddata  : std_logic_vector(7 downto 0) := (others => '0');
  signal datadkin   : std_logic                    := '0';

  signal ddataa : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatab : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatac : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatad : std_logic_vector(7 downto 0) := (others => '0');


  signal sport_serclk : std_logic_vector(3 downto 0) := (others => '0');
  signal sport_serdt : std_logic_vector(3 downto 0) := (others => '0');
  signal sport_sertfs : std_logic_vector(3 downto 0) := (others => '0');
  signal sport_full : std_logic_vector(3 downto 0) := (others => '0');

begin  -- Behavioral

  dsp_decodemux : decodemux
    port map (
      CLK          => CLK,
      DIN          => RXDIN,
      KIN          => RXKIN,
      LOCKED       => dsp_decode_locked,
      ECYCLE       => ecycle,
      EDATA        => dsp_decode_edata,
      HEADERDONe   => headerdone,
      BSTARTCYCLE  => bstartcycle,
      DGRANTA      => dgrantin(0),
      EARXBYTEA    => dsp_decode_EARXBYTEA,
      EARXBYTESELA => dsp_decode_EARXBYTESELA,
      DGRANTB      => dgrantin(1),
      EARXBYTEB    => dsp_decode_EARXBYTEB,
      EARXBYTESELB => dsp_decode_EARXBYTESELB,
      DGRANTC      => dgrantin(2),
      EARXBYTEC    => dsp_decode_EARXBYTEC,
      EARXBYTESELC => dsp_decode_EARXBYTESELC,
      DGRANTD      => dgrantin(3),
      EARXBYTED    => dsp_decode_EARXBYTED,
      EARXBYTESELD => dsp_decode_EARXBYTESELD);



  datamux_inst : datamux
    port map (
      CLK          => CLK,
      ECYCLe       => ECYCLE,
      DGRANTIN     => dgrantin,
      ENCDOUT      => encddata,
      ENCDNEXTBYTE => encdnextbyte,
      ENCDREQ      => encdreq,
      ENCDLASTBYTE => encdlastbyte,
      DDATAA       => ddataarray(0),
      DDATAB       => ddataarray(1),
      DDATAC       => ddataarray(2),
      DDATAD       => ddataarray(3),
      DNEXTBYTE    => dnextbyte,
      DREQ         => dreq,
      DLASTBYTE    => dlastbyte);

  encodedata_inst : encodedata
    port map (
      CLK          => CLK,
      ECYCLE       => ecycle,
      ENCODEEN     => datadataen,
      HEADERDONE   => headerdone,
      DREQ         => datadreq,
      DGRANT       => datadgrant,
      DDONE        => dataddone,
      DDATA        => dataddata,
      DKIN         => datadkin,
      -- to data mux
      BSTARTCYCLE  => bstartcycle,
      ENCDOUT      => encddata,
      ENCDNEXTBYTE => encdnextbyte,
      ENCDREQ      => encdreq,
      ENCDLASTBYTE => encdlastbyte
      );

  
  dsp_encodemux : encodemux
    port map (
      CLK        => CLK,
      ECYCLE     => ecycle,
      DOUT       => TXDOUT,
      KOUT       => TXKOUT,
      DREQ       => datadreq,
      DGRANT     => datadgrant,
      DDONE      => dataddone,
      DDATA      => dataddata,
      DKIN       => datadkin,
      DATAEN     => dataen,
      EDSPREQ    => "0000",
      EDSPDONE   => "0000",
      EDSPDATAA  => X"00",
      EDSPDATAB  => X"00",
      EDSPDATAC  => X"00",
      EDSPDATAD  => X"00",
      EPROCREQ   => "0000",
      EPROCDONE  => "0000",
      EPROCDATAA => X"00",
      EPROCDATAB => X"00",
      EPROCDATAC => X"00",
      EPROCDATAD => X"00");

  dsp_decode_locked <= '1' after 10 us;


  datasports : for i in 0 to 3 generate
    datasport_inst : datasport
      port map (
        CLK      => CLK,
        RESET    => '0',
        SERCLK   => sport_serclk(i),
        SERDT    => sport_serdt(i),
        SERTFS   => sport_sertfs(i),
        FULL     => sport_full(i),
        REQ      => dreq(i),
        NEXTBYTE => dnextbyte(i),
        LASTBYTE => dlastbyte(i),
        DOUT     => ddataarray(i));
  end generate datasports;
  
    process
    -- we need the BEswap variables because we must seend each byte
    -- LSB first, but we need to send the high-byte first
    variable tmpword, tmpwordBEswap : std_logic_vector(15 downto 0) := X"0000";
    variable pktlen, pktlenBEswap   : std_logic_vector(15 downto 0) := X"0000";
  begin
    wait for 10 us;

    for bufnum in 0 to 19 loop
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK) and FULL = '0';
      wait until falling_edge(SERCLK);
      SERTFS <= '1';
      wait until falling_edge(SERCLK);
      SERTFS <= '0';

      -- send the length
      pktlen       := std_logic_vector(TO_UNSIGNED(bufnum*20 + 172, 16));
      pktlenBEswap := pktlen(7 downto 0) & pktlen(15 downto 8);
      for bpos in 0 to 15 loop
        SERDT <= pktlenBEswap(bpos);
        wait until falling_edge(SERCLK);
      end loop;  -- bpos

      -- then the body
      for bufpos in 0 to 510 loop
        tmpword       := std_logic_vector(TO_UNSIGNED(bufnum * 256 + bufpos + 4, 16));
        tmpwordBEswap := tmpword(7 downto 0) & tmpword(15 downto 8);
        for bpos in 0 to 15 loop
          SERDT <= tmpwordBEswap(bpos);
          wait until falling_edge(SERCLK);
        end loop;
      end loop;

    end loop;  -- bufnum
  end process;




end Behavioral;
