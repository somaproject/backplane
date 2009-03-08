library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;

library FMF;
use FMF.gen_utils.all;
use FMF.conversions.all;

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

  signal MEMREADY  : std_logic                     := '0';
  signal memreadyn : std_logic                     := '0';
  signal RESET     : std_logic                     := '0';
  -- config
  signal MYIP      : std_logic_vector(31 downto 0) := (others => '0');
  signal MYMAC     : std_logic_vector(47 downto 0) := (others => '0');
  signal MYBCAST   : std_logic_vector(31 downto 0) := (others => '0');

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
  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');

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
      TimingCheckFlag : boolean       := true;
      PUSCheckFlag    : boolean       := false;
      Part_Number     : PART_NUM_TYPE := B400);
    port
      (DQ      : inout std_logic_vector(15 downto 0) := (others => 'Z');
        LDQS   : inout std_logic                     := 'Z';
        LDQSB  : inout std_logic                     := 'Z';
        UDQS   : inout std_logic                     := 'Z';
        UDQSB  : inout std_logic                     := 'Z';
        LDM    : in    std_logic;
        WEB    : in    std_logic;
        CASB   : in    std_logic;
        RASB   : in    std_logic;
        CSB    : in    std_logic;
        BA     : in    std_logic_vector(1 downto 0);
        ADDR   : in    std_logic_vector(12 downto 0);
        CKE    : in    std_logic;
        CLK    : in    std_logic;
        CLKB   : in    std_logic;
        UDM    : in    std_logic;
        odelay : in    time                          := 0 ps);
  end component;



  component inputcontrol
    generic (
      USE_CRCVERIFY : boolean);
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
      RESET       : in  std_logic;
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
      CLK      : in    std_logic;
      CLK90    : in    std_logic;
      CLK180   : in    std_logic;
      CLK270   : in    std_logic;
      RESET    : in    std_logic;
      MEMREADY : out   std_logic;
      -- RAM!
      CKE      : out   std_logic := '0';
      CAS      : out   std_logic;
      RAS      : out   std_logic;
      CS       : out   std_logic;
      WE       : out   std_logic;
      ADDR     : out   std_logic_vector(12 downto 0);
      BA       : out   std_logic_vector(1 downto 0);
      DQSH     : inout std_logic;
      DQSL     : inout std_logic;
      DQ       : inout std_logic_vector(15 downto 0);
      -- interface
      START    : in    std_logic;
      RW       : in    std_logic;
      DONE     : out   std_logic;
      -- write interface
      ROWTGT   : in    std_logic_vector(14 downto 0);
      WRADDR   : out   std_logic_vector(7 downto 0);
      WRDATA   : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR   : out   std_logic_vector(7 downto 0);
      RDDATA   : out   std_logic_vector(31 downto 0);
      RDWE     : out   std_logic
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


    component mt47h64m16
    generic (
      -- tipd delays: interconnect path delays
      tipd_ODT     : VitalDelayType01 := VitalZeroDelay01;
      tipd_CK      : VitalDelayType01 := VitalZeroDelay01;
      tipd_CKNeg   : VitalDelayType01 := VitalZeroDelay01;
      tipd_CKE     : VitalDelayType01 := VitalZeroDelay01;
      tipd_CSNeg   : VitalDelayType01 := VitalZeroDelay01;
      tipd_RASNeg  : VitalDelayType01 := VitalZeroDelay01;
      tipd_CASNeg  : VitalDelayType01 := VitalZeroDelay01;
      tipd_WENeg   : VitalDelayType01 := VitalZeroDelay01;
      tipd_LDM     : VitalDelayType01 := VitalZeroDelay01;
      tipd_UDM     : VitalDelayType01 := VitalZeroDelay01;
      tipd_BA0     : VitalDelayType01 := VitalZeroDelay01;
      tipd_BA1     : VitalDelayType01 := VitalZeroDelay01;
      tipd_BA2     : VitalDelayType01 := VitalZeroDelay01;
      tipd_A0      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A1      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A2      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A3      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A4      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A5      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A6      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A7      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A8      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A9      : VitalDelayType01 := VitalZeroDelay01;
      tipd_A10     : VitalDelayType01 := VitalZeroDelay01;
      tipd_A11     : VitalDelayType01 := VitalZeroDelay01;
      tipd_A12     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ0     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ1     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ2     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ3     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ4     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ5     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ6     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ7     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ8     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ9     : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ10    : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ11    : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ12    : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ13    : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ14    : VitalDelayType01 := VitalZeroDelay01;
      tipd_DQ15    : VitalDelayType01 := VitalZeroDelay01;
      tipd_UDQS    : VitalDelayType01 := VitalZeroDelay01;
      tipd_UDQSNeg : VitalDelayType01 := VitalZeroDelay01;
      tipd_LDQS    : VitalDelayType01 := VitalZeroDelay01;
      tipd_LDQSNeg : VitalDelayType01 := VitalZeroDelay01;

      -- tpd delays
      tpd_CK_DQ0  : VitalDelayType01Z := UnitDelay01Z;  -- tAC(max), tHZ
      tpd_CK_DQ1  : VitalDelayType    := UnitDelay;     -- tAC(min)
      tpd_CK_LDQS : VitalDelayType01Z := UnitDelay01Z;  -- tDQSCK(max)

      -- tsetup values
      tsetup_DQ0_LDQS                    : VitalDelayType := UnitDelay;  -- tDSb
      tsetup_A0_CK                       : VitalDelayType := UnitDelay;  -- tISb
      tsetup_LDQS_CK_CL3_negedge_posedge : VitalDelayType := UnitDelay;  -- tDSS
      tsetup_LDQS_CK_CL4_negedge_posedge : VitalDelayType := UnitDelay;  -- tDSS
      tsetup_LDQS_CK_CL5_negedge_posedge : VitalDelayType := UnitDelay;  -- tDSS
      tsetup_LDQS_CK_CL6_negedge_posedge : VitalDelayType := UnitDelay;  -- tDSS
      -- thold values
      thold_DQ0_LDQS                     : VitalDelayType := UnitDelay;  -- tDHb
      thold_A0_CK                        : VitalDelayType := UnitDelay;  -- tIHb
      thold_LDQS_CK_CL3_posedge_posedge  : VitalDelayType := UnitDelay;  -- tDSH
      thold_LDQS_CK_CL4_posedge_posedge  : VitalDelayType := UnitDelay;  -- tDSH
      thold_LDQS_CK_CL5_posedge_posedge  : VitalDelayType := UnitDelay;  -- tDSH
      thold_LDQS_CK_CL6_posedge_posedge  : VitalDelayType := UnitDelay;  -- tDSH
      -- tpw values
      tpw_CK_CL3_posedge                 : VitalDelayType := UnitDelay;  -- tCHAVG
      tpw_CK_CL3_negedge                 : VitalDelayType := UnitDelay;  -- tCLAVG
      tpw_CK_CL4_posedge                 : VitalDelayType := UnitDelay;  -- tCHAVG
      tpw_CK_CL4_negedge                 : VitalDelayType := UnitDelay;  -- tCLAVG
      tpw_CK_CL5_posedge                 : VitalDelayType := UnitDelay;  -- tCHAVG
      tpw_CK_CL5_negedge                 : VitalDelayType := UnitDelay;  -- tCLAVG
      tpw_CK_CL6_posedge                 : VitalDelayType := UnitDelay;  -- tCHAVG
      tpw_CK_CL6_negedge                 : VitalDelayType := UnitDelay;  -- tCLAVG
      tpw_A0_CL3                         : VitalDelayType := UnitDelay;  -- tIPW
      tpw_A0_CL4                         : VitalDelayType := UnitDelay;  -- tIPW
      tpw_A0_CL5                         : VitalDelayType := UnitDelay;  -- tIPW
      tpw_A0_CL6                         : VitalDelayType := UnitDelay;  -- tIPW
      tpw_DQ0_CL3                        : VitalDelayType := UnitDelay;  -- tDIPW
      tpw_DQ0_CL4                        : VitalDelayType := UnitDelay;  -- tDIPW
      tpw_DQ0_CL5                        : VitalDelayType := UnitDelay;  -- tDIPW
      tpw_DQ0_CL6                        : VitalDelayType := UnitDelay;  -- tDIPW
      tpw_LDQS_normCL3_posedge           : VitalDelayType := UnitDelay;  -- tDQSH
      tpw_LDQS_normCL3_negedge           : VitalDelayType := UnitDelay;  -- tDQSL
      tpw_LDQS_normCL4_posedge           : VitalDelayType := UnitDelay;  -- tDQSH
      tpw_LDQS_normCL4_negedge           : VitalDelayType := UnitDelay;  -- tDQSL
      tpw_LDQS_normCL5_posedge           : VitalDelayType := UnitDelay;  -- tDQSH
      tpw_LDQS_normCL5_negedge           : VitalDelayType := UnitDelay;  -- tDQSL
      tpw_LDQS_normCL6_posedge           : VitalDelayType := UnitDelay;  -- tDQSH
      tpw_LDQS_normCL6_negedge           : VitalDelayType := UnitDelay;  -- tDQSL
      tpw_LDQS_preCL3_negedge            : VitalDelayType := UnitDelay;  -- tWPRE
      tpw_LDQS_preCL4_negedge            : VitalDelayType := UnitDelay;  -- tWPRE
      tpw_LDQS_preCL5_negedge            : VitalDelayType := UnitDelay;  -- tWPRE
      tpw_LDQS_preCL6_negedge            : VitalDelayType := UnitDelay;  -- tWPRE
      tpw_LDQS_postCL3_negedge           : VitalDelayType := UnitDelay;  -- tWPST
      tpw_LDQS_postCL4_negedge           : VitalDelayType := UnitDelay;  -- tWPST
      tpw_LDQS_postCL5_negedge           : VitalDelayType := UnitDelay;  -- tWPST
      tpw_LDQS_postCL6_negedge           : VitalDelayType := UnitDelay;  -- tWPST

      -- tperiod values
      tperiod_CK_CL3                    : VitalDelayType := UnitDelay;  -- tCKAVG(min)
      tperiod_CK_CL4                    : VitalDelayType := UnitDelay;  -- tCKAVG(min)
      tperiod_CK_CL5                    : VitalDelayType := UnitDelay;  -- tCKAVG(min)
      tperiod_CK_CL6                    : VitalDelayType := UnitDelay;  -- tCKAVG(min)
      -- tskew values
      tskew_CK_LDQS_CL3_posedge_posedge : VitalDelayType := UnitDelay;  -- tDQSS
      tskew_CK_LDQS_CL4_posedge_posedge : VitalDelayType := UnitDelay;  -- tDQSS
      tskew_CK_LDQS_CL5_posedge_posedge : VitalDelayType := UnitDelay;  -- tDQSS
      tskew_CK_LDQS_CL6_posedge_posedge : VitalDelayType := UnitDelay;  -- tDQSS

      -- tdevice values: values for internal delays
      tdevice_tRC       : VitalDelayType := 54 ns;     -- tRC
      tdevice_tRRD      : VitalDelayType := 10 ns;     -- tRRD
      tdevice_tRCD      : VitalDelayType := 12 ns;     -- tRCD
      tdevice_tFAW      : VitalDelayType := 50 ns;     -- tFAW
      tdevice_tRASMIN   : VitalDelayType := 40 ns;     -- tRAS(min)
      tdevice_tRASMAX   : VitalDelayType := 70 us;     -- tRAS(max)
      tdevice_tRTP      : VitalDelayType := 7.5 ns;    -- tRTP
      tdevice_tWR       : VitalDelayType := 15 ns;     -- tWR
      tdevice_tWTR      : VitalDelayType := 7.5 ns;    -- tWTR
      tdevice_tRP       : VitalDelayType := 12 ns;     -- tRP
      tdevice_tRFCMIN   : VitalDelayType := 127.5 ns;  -- tRFC(min)
      tdevice_tRFCMAX   : VitalDelayType := 70 us;     -- tRFC(max)
      tdevice_REFPer    : VitalDelayType := 64 ms;     -- refresh period
      tdevice_tCKAVGMAX : VitalDelayType := 8 ns;      -- tCKAVG(max)

      -- generic control parameters
      InstancePath   : string  := DefaultInstancePath;
      TimingChecksOn : boolean := DefaultTimingChecks;
      MsgOn          : boolean := DefaultMsgOn;
      XOn            : boolean := DefaultXon;

      -- memory file to be loaded
      mem_file_name : string  := "none";
      UserPreload   : boolean := false;

      -- For FMF SDF technology file usage
      TimingModel : string := DefaultTimingModel);


    port (
      ODT     : in    std_ulogic := 'U';
      CK      : in    std_ulogic := 'U';
      CKNeg   : in    std_ulogic := 'U';
      CKE     : in    std_ulogic := 'U';
      CSNeg   : in    std_ulogic := 'U';
      RASNeg  : in    std_ulogic := 'U';
      CASNeg  : in    std_ulogic := 'U';
      WENeg   : in    std_ulogic := 'U';
      LDM     : in    std_ulogic := 'U';
      UDM     : in    std_ulogic := 'U';
      BA0     : in    std_ulogic := 'U';
      BA1     : in    std_ulogic := 'U';
      BA2     : in    std_ulogic := 'U';
      A0      : in    std_ulogic := 'U';
      A1      : in    std_ulogic := 'U';
      A2      : in    std_ulogic := 'U';
      A3      : in    std_ulogic := 'U';
      A4      : in    std_ulogic := 'U';
      A5      : in    std_ulogic := 'U';
      A6      : in    std_ulogic := 'U';
      A7      : in    std_ulogic := 'U';
      A8      : in    std_ulogic := 'U';
      A9      : in    std_ulogic := 'U';
      A10     : in    std_ulogic := 'U';
      A11     : in    std_ulogic := 'U';
      A12     : in    std_ulogic := 'U';
      DQ0     : inout std_ulogic := 'U';
      DQ1     : inout std_ulogic := 'U';
      DQ2     : inout std_ulogic := 'U';
      DQ3     : inout std_ulogic := 'U';
      DQ4     : inout std_ulogic := 'U';
      DQ5     : inout std_ulogic := 'U';
      DQ6     : inout std_ulogic := 'U';
      DQ7     : inout std_ulogic := 'U';
      DQ8     : inout std_ulogic := 'U';
      DQ9     : inout std_ulogic := 'U';
      DQ10    : inout std_ulogic := 'U';
      DQ11    : inout std_ulogic := 'U';
      DQ12    : inout std_ulogic := 'U';
      DQ13    : inout std_ulogic := 'U';
      DQ14    : inout std_ulogic := 'U';
      DQ15    : inout std_ulogic := 'U';
      UDQS    : inout std_ulogic := 'U';
      UDQSNeg : inout std_ulogic := 'U';
      LDQS    : inout std_ulogic := 'U';
      LDQSNeg : inout std_ulogic := 'U'
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

  signal eventrxid : std_logic_vector(31 downto 0) := (others => '0');
  signal eventrxts : std_logic_vector(47 downto 0) := (others => '0');


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

  signal udqsneg, ldqsneg : std_logic := '0';


begin  -- Behavioral

  udqsneg <= 'H';
  ldqsneg <= 'H';

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
      MEMCLK270n => MEMCLK270n);

  inputcontrol_inst : inputcontrol
    generic map (
      USE_CRCVERIFY => false)
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
      RESET       => memreadyn,
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
      CLK      => MEMCLK,
      CLK90    => memclk90,
      CLK180   => memclk180,
      CLK270   => memclk270,
      RESET    => RESET,
      MEMREADY => MEMREADY,
      CKE      => RAMCKE,
      CAS      => RAMCAS,
      RAS      => RAMRAS,
      CS       => RAMCS,
      WE       => RAMWE,
      ADDR     => RAMADDR,
      BA       => RAMBA,
      DQSH     => RAMDQSH,
      DQSL     => RAMDQSL,
      DQ       => RAMDQ,
      START    => MEMSTART,
      RW       => MEMRW,
      DONE     => memdone,
      ROWTGT   => memrowtgt,
      WRADDR   => memwraddr,
      WRDATA   => memwrdata,
      RDADDR   => memrdaddr,
      RDDATA   => memrddata,
      RDWE     => memrdwe);

--  memory_inst : HY5PS121621F
--    generic map (
--      TimingCheckFlag => true,
--      PUSCheckFlag    => true,
--      PArt_number     => B400)
--    port map (
--      DQ     => RAMDQ,
--      LDQS   => RAMDQSL,
--      UDQS   => RAMDQSH,
--      WEB    => RAMWE,
--      LDM    => '0',
--      UDM    => '0',
--      CASB   => RAMCAS,
--      RASB   => RAMRAS,
--      CSB    => RAMCS,
--      BA     => RAMBA,
--      ADDR   => RAMADDR,
--      CKE    => RAMCKE,
--      CLK    => MEMCLK90,
--      CLKB   => MEMCLK90N,
--      odelay => odelay);


  memory_inst : mt47h64m16
    generic map (
      -- tipd delays: interconnect path delays
      tipd_ODT     => (2.0 ns, 2.0 ns),
      tipd_BA0     => (2.0 ns, 2.0 ns),
      tipd_BA1     => (2.0 ns, 2.0 ns),
      tipd_BA2     => (2.0 ns, 2.0 ns),
      tipd_UDM     => (2.0 ns, 2.0 ns),
      tipd_LDM     => (2.0 ns, 2.0 ns),
      tipd_DQ0     => (2.0 ns, 2.0 ns),
      tipd_DQ1     => (2.0 ns, 2.0 ns),
      tipd_DQ2     => (2.0 ns, 2.0 ns),
      tipd_DQ3     => (2.0 ns, 2.0 ns),
      tipd_DQ4     => (2.0 ns, 2.0 ns),
      tipd_DQ5     => (2.0 ns, 2.0 ns),
      tipd_DQ6     => (2.0 ns, 2.0 ns),
      tipd_DQ7     => (2.0 ns, 2.0 ns),
      tipd_DQ8     => (2.0 ns, 2.0 ns),
      tipd_DQ9     => (2.0 ns, 2.0 ns),
      tipd_DQ10    => (2.0 ns, 2.0 ns),
      tipd_DQ11    => (2.0 ns, 2.0 ns),
      tipd_DQ12    => (2.0 ns, 2.0 ns),
      tipd_DQ13    => (2.0 ns, 2.0 ns),
      tipd_DQ14    => (2.0 ns, 2.0 ns),
      tipd_DQ15    => (2.0 ns, 2.0 ns),
      tipd_UDQS    => (2.0 ns, 2.0 ns),
      tipd_UDQSNeg => (2.0 ns, 2.0 ns),
      tipd_LDQS    => (2.0 ns, 2.0 ns),
      tipd_LDQSNeg => (2.0 ns, 2.0 ns),
      tipd_A0      => (2.0 ns, 2.0 ns),
      tipd_A1      => (2.0 ns, 2.0 ns),
      tipd_A2      => (2.0 ns, 2.0 ns),
      tipd_A3      => (2.0 ns, 2.0 ns),
      tipd_A4      => (2.0 ns, 2.0 ns),
      tipd_A5      => (2.0 ns, 2.0 ns),
      tipd_A6      => (2.0 ns, 2.0 ns),
      tipd_A7      => (2.0 ns, 2.0 ns),
      tipd_A8      => (2.0 ns, 2.0 ns),
      tipd_A9      => (2.0 ns, 2.0 ns),
      tipd_A10     => (2.0 ns, 2.0 ns),
      tipd_A11     => (2.0 ns, 2.0 ns),
      tipd_A12     => (2.0 ns, 2.0 ns),
      tipd_CK      => (2.0 ns, 2.0 ns),
      tipd_CKNeg   => (2.0 ns, 2.0 ns),
      tipd_CKE     => (2.0 ns, 2.0 ns),
      tipd_WENeg   => (2.0 ns, 2.0 ns),
      tipd_RASNeg  => (2.0 ns, 2.0 ns),
      tipd_CSNeg   => (2.0 ns, 2.0 ns),
      tipd_CASNeg  => (2.0 ns, 2.0 ns),

      tpd_CK_DQ0  => UnitDelay01Z,
      tpd_CK_DQ1  => UnitDelay,
      tpd_CK_LDQS => UnitDelay01Z,

      tsetup_DQ0_LDQS                    => UnitDelay,
      tsetup_A0_CK                       => UnitDelay,
      tsetup_LDQS_CK_CL3_negedge_posedge => UnitDelay,
      tsetup_LDQS_CK_CL4_negedge_posedge => UnitDelay,
      tsetup_LDQS_CK_CL5_negedge_posedge => UnitDelay,
      tsetup_LDQS_CK_CL6_negedge_posedge => UnitDelay,

      thold_DQ0_LDQS                    => UnitDelay,
      thold_A0_CK                       => UnitDelay,
      thold_LDQS_CK_CL3_posedge_posedge => UnitDelay,
      thold_LDQS_CK_CL4_posedge_posedge => UnitDelay,
      thold_LDQS_CK_CL5_posedge_posedge => UnitDelay,
      thold_LDQS_CK_CL6_posedge_posedge => UnitDelay,

      tpw_CK_CL3_posedge       => UnitDelay,
      tpw_CK_CL3_negedge       => UnitDelay,
      tpw_CK_CL4_posedge       => UnitDelay,
      tpw_CK_CL4_negedge       => UnitDelay,
      tpw_CK_CL5_posedge       => UnitDelay,
      tpw_CK_CL5_negedge       => UnitDelay,
      tpw_CK_CL6_posedge       => UnitDelay,
      tpw_CK_CL6_negedge       => UnitDelay,
      tpw_A0_CL3               => UnitDelay,
      tpw_A0_CL4               => UnitDelay,
      tpw_A0_CL5               => UnitDelay,
      tpw_A0_CL6               => UnitDelay,
      tpw_DQ0_CL3              => UnitDelay,
      tpw_DQ0_CL4              => UnitDelay,
      tpw_DQ0_CL5              => UnitDelay,
      tpw_DQ0_CL6              => UnitDelay,
      tpw_LDQS_normCL3_posedge => UnitDelay,
      tpw_LDQS_normCL3_negedge => UnitDelay,
      tpw_LDQS_normCL4_posedge => UnitDelay,
      tpw_LDQS_normCL4_negedge => UnitDelay,
      tpw_LDQS_normCL5_posedge => UnitDelay,
      tpw_LDQS_normCL5_negedge => UnitDelay,
      tpw_LDQS_normCL6_posedge => UnitDelay,
      tpw_LDQS_normCL6_negedge => UnitDelay,
      tpw_LDQS_preCL3_negedge  => UnitDelay,
      tpw_LDQS_preCL4_negedge  => UnitDelay,
      tpw_LDQS_preCL5_negedge  => UnitDelay,
      tpw_LDQS_preCL6_negedge  => UnitDelay,
      tpw_LDQS_postCL3_negedge => UnitDelay,
      tpw_LDQS_postCL4_negedge => UnitDelay,
      tpw_LDQS_postCL5_negedge => UnitDelay,
      tpw_LDQS_postCL6_negedge => UnitDelay,

      tperiod_CK_CL3 => UnitDelay,
      tperiod_CK_CL4 => UnitDelay,
      tperiod_CK_CL5 => UnitDelay,
      tperiod_CK_CL6 => UnitDelay,

      tskew_CK_LDQS_CL3_posedge_posedge => UnitDelay,
      tskew_CK_LDQS_CL4_posedge_posedge => UnitDelay,
      tskew_CK_LDQS_CL5_posedge_posedge => UnitDelay,
      tskew_CK_LDQS_CL6_posedge_posedge => UnitDelay,

      tdevice_tRC       => 51 ns,
      tdevice_tRRD      => 10 ns,
      tdevice_tRCD      => 12 ns,
      tdevice_tFAW      => 50 ns,
      tdevice_tRASMIN   => 40 ns,
      tdevice_tRASMAX   => 70 us,
      tdevice_tRTP      => 7.5 ns,
      tdevice_tWR       => 15 ns,
      tdevice_tWTR      => 7.5 ns,
      tdevice_tRP       => 12 ns,
      tdevice_tRFCMIN   => 127.5 ns,
      tdevice_tRFCMAX   => 70 us,
      tdevice_REFPer    => 64 ms,
      tdevice_tCKAVGMAX => 8 ns,

      InstancePath   => DefaultInstancePath,
      TimingChecksOn => true,
      MsgOn          => DefaultMsgOn,
      XOn            => DefaultXon,

      --mem_file_name => ,


      TimingModel => "MT47H64M16BT-3" )
    port map (
      ODT         => '0',
      CK          => memCLK270,
      CKNeg       => memCLK270N,
      CKE         => RAMCKE,
      CSNeg       => RAMCS,
      RASNeg      => RAMRAS,
      CASNEG      => RAMCAS,
      WENeg       => RAMWE,
      LDM         => '0',
      UDM         => '0',
      BA0         => RAMBA(0),
      BA1         => RAMBA(1),
      BA2         => '0',
      A0          => RAMADDR(0),
      A1          => RAMADDR(1),
      A2          => RAMADDR(2),
      A3          => RAMADDR(3),
      A4          => RAMADDR(4),
      A5          => RAMADDR(5),
      A6          => RAMADDR(6),
      A7          => RAMADDR(7),
      A8          => RAMADDR(8),
      A9          => RAMADDR(9),
      A10         => RAMADDR(10),
      A11         => RAMADDR(11),
      A12         => RAMADDR(12),
      DQ0         => RAMDQ(0),
      DQ1         => RAMDQ(1),
      DQ2         => RAMDQ(2),
      DQ3         => RAMDQ(3),
      DQ4         => RAMDQ(4),
      DQ5         => RAMDQ(5),
      DQ6         => RAMDQ(6),
      DQ7         => RAMDQ(7),
      DQ8         => RAMDQ(8),
      DQ9         => RAMDQ(9),
      DQ10        => RAMDQ(10),
      DQ11        => RAMDQ(11),
      DQ12        => RAMDQ(12),
      DQ13        => RAMDQ(13),
      DQ14        => RAMDQ(14),
      DQ15        => RAMDQ(15),
      UDQS        => RAMDQSH,
      UDQSNeg     => udqsneg,
      LDQS        => RAMDQSL, 
      LDQSNeg     => ldqsneg
      );

  
  NICIOCLK <= CLK;

  RESET     <= '0' after 20 ns;
  STARTWAIT <= '0' after 300 us;
  memreadyn <= not MEMREADY;

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

  EATX <= (others => '1');
  -- time stamp event
  ts_eventgen : process(CLK)
    variable eventtimepos : std_logic_vector(47 downto 0) := (others => '0');
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' and MEMREADY = '1' then
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
    wait for 1000 us;                    -- eat startup
    retxreqid <= X"00000000";
    wait until rising_edge(CLK);

    for i in 0 to 10 loop

      retxreqid  <= retxreqid + 1;
      wait until rising_edge(CLK);
      retxreqreq <= '1';                -- request the retransmission
      wait until rising_edge(CLK);
      retxreqreq <= '0';

      wait until rising_edge(CLK) and eventrxid = retxreqid;
      report "Successful receive of event retxreqid" severity note;
      
    end loop;  -- i

    report "End of Simulation" severity failure;



  end process;


end Behavioral;


