library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;


library FMF;
use FMF.gen_utils.all;
use FMF.conversions.all;


entity retxbuffertest is

end retxbuffertest;

architecture Behavioral of retxbuffertest is

  component retxbuffer
    port (
      CLK   : in std_logic;
      CLKHI : in std_logic;

      -- buffer set A input (write) interface
      WIDA   : in std_logic_vector(13 downto 0);
      WDINA  : in std_logic_vector(15 downto 0);
      WADDRA : in std_logic_vector(8 downto 0);
      WRA    : in std_logic;
      WDONEA : in std_logic;
      WCLKA  : in std_logic;

      -- output buffer A set B (reads) interface
      RIDA    : in  std_logic_vector (13 downto 0);
      RREQA   : in  std_logic;
      RDOUTA  : out std_logic_vector(15 downto 0);
      RADDRA  : out std_logic_vector(8 downto 0);
      RDONEA  : out std_logic;
      RWROUTA : out std_logic;
      RCLKA   : in  std_logic;


      --buffer set B input (write) interfafe
      WIDB   : in std_logic_vector(13 downto 0);
      WDINB  : in std_logic_vector(15 downto 0);
      WADDRB : in std_logic_vector(8 downto 0);
      WRB    : in std_logic;
      WDONEB : in std_logic;
      WCLKB  : in std_logic;

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
      MEMWRDATA : out std_logic_vector(31 downto 0);
      MEMROWTGT : out std_logic_vector(14 downto 0);
      MEMRDDATA : in  std_logic_vector(31 downto 0);
      MEMRDADDR : in  std_logic_vector(7 downto 0);
      MEMRDWE   : in  std_logic
      );
  end component;


  signal CLKNOM : std_logic := '0';
  signal CLKHI  : std_logic := '0';

  -- buffer set A input (write) interface
  signal WIDA   : std_logic_vector(13 downto 0) := (others => '0');
  signal WDINA  : std_logic_vector(15 downto 0) := (others => '0');
  signal WADDRA : std_logic_vector(8 downto 0)  := (others => '0');
  signal WRA    : std_logic                     := '0';
  signal WDONEA : std_logic                     := '0';

  -- output buffer A set B (reads) interface
  signal RIDA    : std_logic_vector (13 downto 0) := (others => '0');
  signal RREQA   : std_logic                      := '0';
  signal RDOUTA  : std_logic_vector(15 downto 0)  := (others => '0');
  signal RADDRA  : std_logic_vector(8 downto 0)   := (others => '0');
  signal RDONEA  : std_logic                      := '0';
  signal RWROUTA : std_logic                      := '0';


--buffer set B input (write) interfafe
  signal WIDB   : std_logic_vector(13 downto 0) := (others => '0');
  signal WDINB  : std_logic_vector(15 downto 0) := (others => '0');
  signal WADDRB : std_logic_vector(8 downto 0)  := (others => '0');
  signal WRB    : std_logic                     := '0';
  signal WDONEB : std_logic                     := '0';

  -- output buffer B set Rad (reads) interface
  signal RIDB   : std_logic_vector (13 downto 0) := (others => '0');
  signal RREQB  : std_logic                      := '0';
  signal RDOUTB : std_logic_vector(15 downto 0)  := (others => '0');
  signal RADDRB : std_logic_vector(8 downto 0)   := (others => '0');

  signal RDONEB  : std_logic := '0';
  signal RWROUTB : std_logic := '0';

  -- memory output interface
  signal MEMSTART  : std_logic                     := '0';
  signal MEMRW     : std_logic                     := '0';
  signal MEMDONE   : std_logic                     := '0';
  signal MEMWRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal MEMWRDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal MEMROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal MEMRDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal MEMRDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal MEMRDWE   : std_logic                     := '0';


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
      ROWTGT : in  std_logic_vector(14 downto 0);
      WRADDR : out std_logic_vector(7 downto 0);
      WRDATA : in  std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out std_logic_vector(7 downto 0);
      RDDATA : out std_logic_vector(31 downto 0);
      RDWE   : out std_logic
      );
  end component;

  signal CLK, CLKN     : std_logic := '0';
  signal CLK90, CLK90N : std_logic := '0';
  signal CLK180        : std_logic := '0';
  signal CLK270, clk270n        : std_logic := '0';
  signal RESET         : std_logic := '1';


  -- RAM!
  signal CKE  : std_logic                     := '0';
  signal CAS  : std_logic                     := '1';
  signal RAS  : std_logic                     := '1';
  signal CS   : std_logic                     := '1';
  signal WE   : std_logic                     := '1';
  signal ADDR : std_logic_vector(12 downto 0) := (others => '0');
  signal BA   : std_logic_vector(1 downto 0)  := (others => '0');
  signal DQSH : std_logic                     := '0';
  signal DQSL : std_logic                     := '0';
  signal DQ   : std_logic_vector(15 downto 0) := (others => '0');

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

  signal mainclk    : std_logic := '0';
  signal clkpos     : integer   := 0;
  signal clkslowpos : integer   := 0;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.6666 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal odelay : time := 0 ps;

  type outbuffer is array (0 to 511) of std_logic_vector(15 downto 0);
  signal outbuffera : outbuffer;
  signal outbufferb : outbuffer;

  signal ldqsneg, udqsneg : std_logic := '0';
  
begin  -- Behavioral


  DQSH <= 'L';
  DQSL <= 'L';
  
  memddr2_uut : memddr2
    port map (
      CLK    => CLK,
      CLK90  => CLK90,
      CLK180 => CLK180,
      CLK270 => CLK270,
      RESET  => RESET,
      CKE    => CKE,
      CAS    => CAS,
      RAS    => RAS,
      CS     => CS,
      WE     => WE,
      ADDR   => ADDR,
      BA     => BA,
      DQSH   => DQSH,
      DQSL   => DQSL,
      DQ     => DQ,
      START  => MEMSTART,
      RW     => MEMRW,
      DONE   => MEMDONE,
      ROWTGT => MEMROWTGT,
      WRADDR => MEMWRADDR,
      WRDATA => MEMWRDATA,
      RDADDR => MEMRDADDR,
      RDDATA => MEMRDDATA,
      RDWE   => MEMRDWE);

  mainclk <= not mainclk after (clk_period / 8);
  RESET   <= '0'         after 20 ns;

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
      CK          => clk270,
      CKNeg       => clk270n,
      CKE         => CKE,
      CSNeg       => CS,
      RASNeg      => RAS,
      CASNEG      => CAS,
      WENeg       => WE,
      LDM         => '0',
      UDM         => '0',
      BA0         => BA(0),
      BA1         => BA(1),
      BA2         => '0',
      A0          => ADDR(0),
      A1          => ADDR(1),
      A2          => ADDR(2),
      A3          => ADDR(3),
      A4          => ADDR(4),
      A5          => ADDR(5),
      A6          => ADDR(6),
      A7          => ADDR(7),
      A8          => ADDR(8),
      A9          => ADDR(9),
      A10         => ADDR(10),
      A11         => ADDR(11),
      A12         => ADDR(12),
      DQ0         => DQ(0),
      DQ1         => DQ(1),
      DQ2         => DQ(2),
      DQ3         => DQ(3),
      DQ4         => DQ(4),
      DQ5         => DQ(5),
      DQ6         => DQ(6),
      DQ7         => DQ(7),
      DQ8         => DQ(8),
      DQ9         => DQ(9),
      DQ10        => DQ(10),
      DQ11        => DQ(11),
      DQ12        => DQ(12),
      DQ13        => DQ(13),
      DQ14        => DQ(14),
      DQ15        => DQ(15),
      UDQS        => DQSH,
      UDQSNeg     => udqsneg,
      LDQS        => DQSL,
      LDQSNeg     => ldqsneg);

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkpos = 3 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;

      if clkpos = 0 then
        CLK <= '1';
      elsif clkpos = 2 then
        CLK <= '0';
      end if;

      if clkpos = 1 then
        CLK90 <= '1';
      elsif clkpos = 3 then
        CLK90 <= '0';
      end if;

      if clkpos = 2 then
        CLK180 <= '1';
      elsif clkpos = 0 then
        CLK180 <= '0';
      end if;

      if clkpos = 3 then
        CLK270 <= '1';
      elsif clkpos = 1 then
        CLK270 <= '0';
      end if;

      if clkslowpos = 11 then
        clkslowpos <= 0;
      else
        clkslowpos <= clkslowpos + 1;
      end if;

      if clkslowpos = 0 then
        CLKnom <= '1';
      elsif clkslowpos = 6 then
        CLKnom <= '0';

      end if;

    end if;
  end process;

  clkhi  <= CLK;
  CLKN   <= not CLK;
  CLK90N <= not CLK90;
  CLK270N <= not CLK270;
  
  retxbuffer_uut : retxbuffer
    port map (
      CLK       => CLKnom,
      CLKHI     => CLKHI,
      WIDA      => WIDA,
      WDINA     => WDINA,
      WADDRA    => WADDRA,
      WRA       => WRA,
      WDONEA    => WDONEA,
      WCLKA     => CLKnom,
      RIDA      => RIDA,
      RREQA     => RREQA,
      RDOUTA    => RDOUTA,
      RADDRA    => RADDRA,
      RDONEA    => RDONEA,
      RWROUTA   => RWROUTA,
      RCLKA     => CLKnom,
      WIDB      => WIDB,
      WDINB     => WDINB,
      WADDRB    => WADDRB,
      WRB       => WRB,
      WDONEB    => WDONEB,
      WCLKB     => CLKnom,
      RIDB      => RIDB,
      RREQB     => RREQB,
      RDOUTB    => RDOUTB,
      RADDRB    => RADDRB,
      RDONEB    => RDONEB,
      RWROUTB   => RWROUTB,
      RCLKB     => CLKnom,
      MEMSTART  => MEMSTART,
      MEMRW     => MEMRW,
      MEMDONE   => MEMDONE,
      MEMWRADDR => MEMWRADDR,
      MEMWRDATA => MEMWRDATA,
      MEMROWTGT => MEMROWTGT,
      MEMRDDATA => MEMRDDATA,
      MEMRDADDR => MEMRDADDR,
      MEMRDWE   => MEMRDWE);

  -- exhausting test infrastructure
  -- input A process
  inputA : process
  begin
    wait for 450 us;
    for i in 0 to 63 loop
      for j in 0 to 511 loop
        wait until rising_edge(CLKnom);
        wdina  <= "1" & std_logic_vector(TO_UNSIGNED(i, 5))
                  & std_logic_vector(TO_UNSIGNED(j, 10));
        waddra <= std_logic_vector(TO_UNSIGNED(j, 9));
        wra    <= '1';
      end loop;  -- j
      wait until rising_edge(CLKnom);
      wra      <= '0';
      wida     <= std_logic_vector(to_UNSIGNED((i+1) * 7, 14));
      wdonea   <= '1';
      wait until rising_edge(CLKnom);
      wdonea   <= '0';
      wait for 10 us;

    end loop;  -- i 
  end process inputA;

  -- output buffer capture
  process(CLKnom)
  begin
    if rising_edge(CLKnom) then
      if RWROUTA = '1' then
        outbuffera(to_INTEGER(unsigned(raddra))) <= rdouta; 
      end if;
    end if;
  end process;
  -- output process A:

  outputA : process
    variable expected : std_logic_vector(15 downto 0) := (others => '0');
    
  begin
    wait for 480 us;
    for i in 0 to 63 loop
      wait until rising_edge(CLKnom);
      rida  <= std_logic_vector(to_UNSIGNED((i+1) * 7, 14));
      rreqa <= '1';
      wait until rising_edge(CLKnom);
      rreqa <= '0';
      wait until rising_edge(CLKnom) and rdonea = '1';

      for j in 0 to 511 loop
        expected := "1" & std_logic_vector(TO_UNSIGNED(i, 5))
          & std_logic_vector(TO_UNSIGNED(j, 10)); 
        assert expected = outbuffera(j)
          report "Error in reading outputA buffer A: addr = "
          & integer'image(j) & " " 
          & integer'image(to_integer(unsigned(expected))) & " != " &
          integer'image(to_integer(unsigned(outbuffera(j))))
          severity error;

      end loop;
      wait for 10 us;

    end loop;  -- i 
    report "Finished reading A buffer sets" severity note;


  end process outputA;

    -- input B process
    inputB : process
    begin
      wait for 450 us;
      for i in 0 to 63 loop
        for j in 0 to 511 loop
          wait until rising_edge(CLKnom);
          wdinb  <= "0" & std_logic_vector(TO_UNSIGNED(i, 5))
                    & std_logic_vector(TO_UNSIGNED(j, 10));
          waddrb <= std_logic_vector(TO_UNSIGNED(j, 9));
          wrb    <= '1';
        end loop;  -- j
        wait until rising_edge(CLKnom);
        wrb      <= '0';
        widb     <= std_logic_vector(to_UNSIGNED((i+1) * 13, 14));
        wdoneb   <= '1';
        wait until rising_edge(CLKnom);
        wdoneb   <= '0';
        wait for 10 us;

      end loop;  -- i 
    end process inputB;

    -- output buffer capture
    process(CLKnom)
    begin
      if rising_edge(CLKnom) then
        if RWROUTB = '1' then
          outbufferb(to_INTEGER(unsigned(raddrb))) <= (rdoutb(7 downto 0) &
                                                       rdoutb(15 downto 8));
        end if;
      end if;
    end process;
    -- output process B:

    outputB : process
          variable expected : std_logic_vector(15 downto 0) := (others => '0');

    begin
      wait for 500 us;
      for i in 0 to 63 loop
        wait until rising_edge(CLKnom);
        ridb  <= std_logic_vector(to_UNSIGNED((i+1) * 13, 14));
        rreqb <= '1';
        wait until rising_edge(CLKnom);
        rreqb <= '0';
        wait until rising_edge(CLKnom) and rdoneb = '1';

        for j in 0 to 511 loop
          expected := "0" & std_logic_vector(TO_UNSIGNED(i, 5))
          & std_logic_vector(TO_UNSIGNED(j, 10)); 
        assert expected = outbufferb(j)
          report "Error in reading outputB buffer B: addr = "
          & integer'image(j) & " " 
          & integer'image(to_integer(unsigned(expected))) & " != " &
          integer'image(to_integer(unsigned(outbufferb(j))))
          severity error;

           
        end loop;
        wait for 10 us;

      end loop;  -- i 
      report "Finished reading B buffer sets" severity note;

      report "End of Simulation" severity failure;

    end process outputB;


end Behavioral;
