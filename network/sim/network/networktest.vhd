library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;

library FMF;
use FMF.gen_utils.all;
use FMF.conversions.all;



use WORK.somabackplane.all;
use Work.somabackplane;


entity networktest is

end networktest;

architecture Behavioral of networktest is

  component network
    port (
      CLK       : in std_logic;
      MEMCLK    : in std_logic;
      MEMCLK90  : in std_logic;
      MEMCLK180 : in std_logic;
      MEMCLK270 : in std_logic;

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
      RAMCKE       : out   std_logic := '0';
      RAMCAS       : out   std_logic;
      RAMRAS       : out   std_logic;
      RAMCS        : out   std_logic;
      RAMWE        : out   std_logic;
      RAMADDR      : out   std_logic_vector(12 downto 0);
      RAMBA        : out   std_logic_vector(1 downto 0);
      RAMDQSH      : inout std_logic;
      RAMDQSL      : inout std_logic;
      RAMDQ        : inout std_logic_vector(15 downto 0)

      );
  end component;

  component datareceiver
    port (
      typ       :     integer := 0;
      src       :     integer := 0;
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      NEWFRAME  : in  std_logic;
      RXGOOD    : out std_logic;
      RXCNT     : out integer;
      RXMISSING : out std_logic);
  end component;

  component eventreceiver
    port (
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      NEWFRAME  : in  std_logic;
      RXGOOD    : out std_logic := '0';
      RXCNT     : out integer   := 0;
      RXMISSING : out std_logic := '0');
  end component;

  component retxreq
    port (
      CLK       : in  std_logic;
      NEXTFRAME : in  std_logic;
      DOEN      : out std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      REQ       : in  std_logic;
      SRC       : in  integer;
      TYP       : in  integer;
      ID        : in  std_logic_vector(31 downto 0);
      DONE      : out std_logic);
  end component;

  signal retx_req           : std_logic                     := '0';
  signal retx_src, retx_typ : integer                       := 0;
  signal retx_id            : std_logic_vector(31 downto 0) := (others => '0');
  signal retx_done          : std_logic                     := '0';

  signal mainclk    : std_logic := '0';
  signal clkpos     : integer   := 0;
  signal clkslowpos : integer   := 0;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.6666 ns;


  signal CLK                   : std_logic := '0';
  signal memclk, memclkn       : std_logic := '0';
  signal memclk90, memclk90n   : std_logic := '0';
  signal memclk180, memclk180n : std_logic := '0';
  signal memclk270, memclk270n : std_logic := '0';


  signal RESET        : std_logic                     := '1';
  -- config
  signal MYIP         : std_logic_vector(31 downto 0) := (others => '0');
  signal MYMAC        : std_logic_vector(47 downto 0) := (others => '0');
  signal MYBCAST      : std_logic_vector(31 downto 0) := (others => '0');
  -- input
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');
  -- output
  signal NICDOUT      : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEWFRAME  : std_logic                     := '0';
  signal NICIOCLK     : std_logic                     := '0';

  -- event bus
  signal ECYCLE : std_logic := '0';

  signal EARX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');

  -- ram
  signal RAMCKE  : std_logic                     := '0';
  signal RAMCAS  : std_logic                     := '0';
  signal RAMRAS  : std_logic                     := '0';
  signal RAMCS   : std_logic                     := '0';
  signal RAMWE   : std_logic                     := '0';
  signal RAMADDR : std_logic_vector(12 downto 0) := (others => '0');
  signal RAMBA   : std_logic_vector(1 downto 0)  := (others => '0');
  signal RAMDQSH : std_logic                     := '0';
  signal RAMDQSL : std_logic                     := '0';
  signal RAMDQ   : std_logic_vector(15 downto 0) := (others => '0');


  -- data bus
  signal dina, dinb   : std_logic_vector(7 downto 0) := (others => '0');
  signal diena, dienb : std_logic                    := '0';

-- simulated eventbus
  signal epos : integer := 900;

-- memory signals
  signal ramwel, ramwell     : std_logic := '1';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                         := (others => '0');

  signal data_rxgood    : std_logic_vector(63 downto 0) := (others => '0');
  signal data_rxmissing : std_logic_vector(63 downto 0) := (others => '0');
  type rxcntarray is array (0 to 63) of integer;
  signal data_rxcnt     : rxcntarray                    := (others => 0);

  signal event_rxgood    : std_logic := '0';
  signal event_rxmissing : std_logic := '0';
  signal event_rxcnt     : integer   := 0;

-- event signals
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal odelay  : time                                          := 0 ps;

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


  constant startup_delay : time      := 250 us;
  signal   startwait     : std_logic := '1';

  component clockgen
    port (
      CLK       : out std_logic;
      MEMCLK    : out std_logic;
      MEMCLKn   : out std_logic;
      MEMCLK90  : out std_logic;
      MEMCLK90n : out std_logic;

      MEMCLK180  : out std_logic;
      MEMCLK180n : out std_logic;

      MEMCLK270           : out std_logic;
      MEMCLK270n          : out std_logic
      );
  end component;
  
  signal ldqsneg, udqsneg :     std_logic := '0';

begin  -- Behavioral
  RESET <= '0' after 20 ns;

  -- startup wait for ram to stabilize

  clockgen_inst : clockgen
    port map (
      CLK       => CLK,
      MEMCLK    => MEMCLK,
      MEMCLKn   => MEMCLKn,
      MEMCLK90  => MEMCLK90,
      MEMCLK90N => MEMCLK90n,
      MEMCLK180 => MEMCLK180,
      MEMCLK270 => MEMCLK270);

  network_uut : network
    port map (
      CLK       => CLK,
      MEMCLK    => MEMCLK,
      MEMCLK90  => MEMCLK90,
      MEMCLK180 => MEMCLK180,
      MEMCLK270 => MEMCLK270,

      RESET        => RESET,
      MYIP         => MYIP,
      MYMAC        => MYMAC,
      MYBCAST      => MYBCAST,
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => NICDINEN,
      NICDIN       => NICDIN,

      NICDOUT     => NICDOUT,
      NICNEWFRAME => NICNEWFRAME,
      NICIOCLK    => NICIOCLK,

      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EATX    => EATX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EDTX    => EDTX,

      DIENA => DIENA,
      DINA  => DINA,
      DIENB => DIENB,
      DINB  => DINB,

      RAMCKE => RAMCKE,
      RAMCAS => RAMCAS,
      RAMRAS => RAMRAS,

      RAMCS        => RAMCS,
      RAMWE        => RAMWE,
      RAMADDR      => RAMADDR,
      RAMBA        => RAMBA,
      RAMDQSH      => RAMDQSH,
      RAMDQSL      => RAMDQSL,
      RAMDQ        => RAMDQ);
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
      CK          => memclk270,
      CKNeg       => memclk270n,
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
      LDQSNeg     => ldqsneg);

  RESET        <= '0' after 100 ns;
  -- ecycle generation
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

  main : process
  begin
    wait for startup_delay;
    startwait <= '0';


    wait for 2 us;
-- networkstack.writepkt("arpquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
    wait for 2 us;

-- networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
-- networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);

    wait;

  end process main;

  datainput                   : process
    file datafilea, datafileb : text;
    variable L                : line;
    variable doen             : std_logic                    := '0';
    variable data             : std_logic_vector(7 downto 0) := (others => '0');

  begin
    file_open(datafilea, "dataa.txt");
    file_open(datafileb, "datab.txt");
    wait for 500 us;

    wait until rising_edge(CLK) and ECYCLE = '1';
    while not endfile(datafilea) loop

      readline(datafilea, L);
      read(L, doen);
      hread(L, data);
      DINA  <= data;
      DIENA <= doen;

      readline(datafileb, L);
      read(L, doen);
      hread(L, data);
      DINB  <= data;
      DIENB <= doen;
      wait until rising_edge(CLK);

    end loop;
    assert false report "End of Simulation" severity failure;


  end process datainput;

  -- retx request and verify

  datareceivers       : for i in 0 to 63 generate
    datareceiver_inst : datareceiver
      port map (
        typ       => 0,
        src       => i,
        CLK       => NICIOCLK,
        DIN       => NICDOUT,
        NEWFRAME  => NICNEWFRAME,
        RXGOOD    => data_rxgood(i),
        RXCNT     => data_rxcnt(i),
        RXMISSING => data_rxmissing(i));
  end generate datareceivers;

  eventreceiver_inst : eventreceiver
    port map (
      CLK       => NICIOCLK,
      DIN       => NICDOUT,
      NEWFRAMe  => NICNEWFRAME,
      RXGOOD    => event_rxgood,
      RXCNt     => event_rxcnt,
      RXMISSING => event_rxmissing);

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

-----------------------------------------------------------------------------
-- RETRANSMISSION REQESTS
-----------------------------------------------------------------------------

  retxreq_inst : retxreq
    port map (
      CLK       => NICIOCLK,
      NEXTFRAME => NICNEXTFRAME,
      DOEN      => NICDINEN,
      DOUT      => NICDIN,
      REQ       => retx_req,
      SRC       => retx_src,
      TYP       => retx_typ,
      ID        => retx_id,
      DONE      => retx_done);

  process
  begin
    for j in 1 to 4 loop
      for i in 0 to 9 loop
        wait until rising_edge(CLK) and data_rxcnt(i*6) >= j;
        wait until rising_edge(CLK);
        retx_src <= i * 6;
        retx_typ <= 0;
        retx_id  <= std_logic_vector(TO_UNSIGNED(data_rxcnt(i*6) - 1, 32));
        wait until rising_edge(CLK);
        retx_req <= '1';
        wait until rising_edge(CLK);
        retx_req <= '0';
        wait until rising_edge(CLK) and retx_done = '1';
      end loop;  -- i
    end loop;  -- j
  end process;
end Behavioral;
