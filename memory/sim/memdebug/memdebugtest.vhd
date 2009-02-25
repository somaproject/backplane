library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;

library FMF;
use FMF.gen_utils.all;
use FMF.conversions.all;
library work;
use WORK.HY5PS121621F_PACK.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memdebugtest is

end memdebugtest;

architecture Behavioral of memdebugtest is
  
  component memdebug
    port (
      -- MEMDDR2 Interface
      MEMCLK   : in  std_logic;
      MEMRESET : out std_logic;
      MEMREADY : in  std_logic;
      START    : out std_logic;
      RW       : out std_logic;
      DONE     : in  std_logic;
      ROWTGT   : out std_logic_vector(14 downto 0);
      WRADDR   : in  std_logic_vector(7 downto 0);
      WRDATA   : out std_logic_vector(31 downto 0);
      RDADDR   : in  std_logic_vector(7 downto 0);
      RDDATA   : in  std_logic_vector(31 downto 0);
      RDWE     : in  std_logic;
      --  CONTROL interface
      CCLK     : in  std_logic;
      CRDADDR  : in  std_logic_vector(3 downto 0);
      CWRADDR  : in  std_logic_vector(3 downto 0);
      CWE      : in  std_logic;
      CRD      : in  std_logic;
      CDOUT    : out std_logic_vector(15 downto 0);
      CDIN     : in  std_logic_vector(15 downto 0)

      );

  end component;


  component memddr2
    generic (
      INITWAIT_ENABLE : in boolean);
    port (
      CLK      : in    std_logic;
      CLK90    : in    std_logic;
      CLK180   : in    std_logic;
      CLK270   : in    std_logic;
      RESET    : in    std_logic;
      MEMREADY : out   std_logic;
      -- RAM!
      CKE      : out   std_logic;
      CAS      : out   std_logic;
      RAS      : out   std_logic;
      CS       : out   std_logic;
      WE       : out   std_logic;
      ADDR     : out   std_logic_vector(12 downto 0);
      BA       : out   std_logic_vector(1 downto 0);
      DQSH     : inout std_logic := '0';
      DQSL     : inout std_logic := '0';
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


  signal CLK, CLKN       : std_logic := '0';
  signal CLK90, CLK90N   : std_logic := '0';
  signal CLK180, clk180n : std_logic := '0';
  signal CLK270, clk270n : std_logic := '0';
  signal RESET           : std_logic := '1';

  component ddr2clkdriver
    port (
      CLKIN    : in  std_logic;
      RESET    : in  std_logic;
      CLKOUT_P : out std_logic;
      CLKOUT_N : out std_logic
      );

  end component;

  -- RAM!
  signal CKE    : std_logic                     := '0';
  signal CAS    : std_logic                     := '1';
  signal RAS    : std_logic                     := '1';
  signal CS     : std_logic                     := '1';
  signal WE     : std_logic                     := '1';
  signal ADDR   : std_logic_vector(12 downto 0) := (others => '0');
  signal BA     : std_logic_vector(1 downto 0)  := (others => '0');
  signal DQSH   : std_logic                     := '0';
  signal DQSL   : std_logic                     := '0';
  signal DQ     : std_logic_vector(15 downto 0) := (others => '0');
  -- interface
  signal START  : std_logic                     := '0';
  signal RW     : std_logic                     := '0';
  signal DONE   : std_logic                     := '0';
  -- write interface
  signal ROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal WRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal WRDATA : std_logic_vector(31 downto 0) := (others => '0');
  -- read interface
  signal RDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal RDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal RDWE   : std_logic                     := '0';

  -- debug IF
  signal CCLK    : std_logic                     := '0';
  signal CWRADDR : std_logic_vector(3 downto 0)  := (others => '0');
  signal CRDADDR : std_logic_vector(3 downto 0)  := (others => '0');
  signal CWE     : std_logic                     := '0';
  signal CRD     : std_logic                     := '0';
  signal CDOUT   : std_logic_vector(15 downto 0) := (others => '0');
  signal CDIN    : std_logic_vector(15 downto 0) := (others => '0');


  signal memrst : std_logic := '0';


  component HY5PS121621F
    generic (
      TimingCheckFlag : boolean       := true;
      PUSCheckFlag    : boolean       := false;
      Part_Number     : PART_NUM_TYPE := B400);
    port
      (DQ     : inout std_logic_vector(15 downto 0) := (others => 'Z');
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


  signal mainclk  : std_logic := '0';
  signal clockpos : integer   := 1;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.66 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal odelay : time := 0 ps;


  type   outbuffer is array (0 to 1023) of std_logic_vector(15 downto 0);
  signal outbufferA : outbuffer := (others => (others => '0'));

  signal memclk, memclkn : std_logic := '0';

  signal udqsneg, ldqsneg : std_logic := '0';
  signal MEMREADY         : std_logic := '0';


  procedure readword (constant A     : in  integer;
                      signal CRDADDR : out std_logic_vector(3 downto 0);
                      signal CRD     : out std_logic) is
  begin
    wait until rising_edge(CCLK);
    CRDADDR <= std_logic_vector(TO_UNSIGNED(a, 4));
    CRD     <= '1';
    wait until rising_edge(CCLK);
    CRD     <= '0';
    wait until rising_edge(CCLK);
  end procedure readword;


  procedure writeword (constant ADDR     : in  integer;
                       constant worddata : in  std_logic_vector(15 downto 0);
                       signal   CWRADDR  : out std_logic_vector(3 downto 0);
                       signal   CWE      : out std_logic;
                       signal   CDIN     : out std_logic_vector(15 downto 0)) is
  begin
    wait until rising_edge(CCLK);
    CWRADDR <= std_logic_vector(TO_UNSIGNED(addr, 4));
    CDIN    <= worddata;
    CWE     <= '1';
    wait until rising_edge(CCLK);
    CWE     <= '0';
    wait until rising_edge(CCLK);
  end procedure writeword;


  
begin  -- Behavioral

  DQSH    <= 'L';
  DQSL    <= 'L';
  udqsneg <= 'H';
  ldqsneg <= 'H';

  memddr2_uut : memddr2
    generic map (
      INITWAIT_ENABLE => false)
    port map (
      CLK      => CLK,
      CLK90    => CLK90,
      CLK180   => CLK180,
      CLK270   => CLK270,
      RESET    => memrst,
      MEMREADY => MEMREADY,
      CKE      => CKE,
      CAS      => CAS,
      RAS      => RAS,
      CS       => CS,
      WE       => WE,
      ADDR     => ADDR,
      BA       => BA,
      DQSH     => DQSH,
      DQSL     => DQSL,
      DQ       => DQ,
      START    => START,
      RW       => RW,
      DONE     => DONE,
      ROWTGT   => ROWTGT,
      WRADDR   => WRADDR,
      WRDATA   => WRDATA,
      RDADDR   => RDADDR,
      RDDATA   => RDDATA,
      RDWE     => RDWE);

  mainclk <= not mainclk after (clk_period / 2);

  RESET <= '0' after 50 ns;

  clockproc : process(mainclk)
  begin
    if rising_edge(mainclk) or falling_edge(mainclk) then
      if clockpos = 5 then
        clockpos <= 0;
      else
        clockpos <= clockpos + 1;
      end if;
--      if clockpos = 5 then
--        CCLK <= '1';
--      elsif clockpos = 2 then
--        CCLK <= '0';
--      end if;
    end if;
  end process clockproc;

  CCLK <= not CCLK after 5 ns;

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


      TimingModel => "MT47H64M16BT-3")
    port map (
      ODT     => '0',
      CK      => memCLK,
      CKNeg   => memCLKN,
      CKE     => CKE,
      CSNeg   => CS,
      RASNeg  => RAS,
      CASNEG  => CAS,
      WENeg   => WE,
      LDM     => '0',
      UDM     => '0',
      BA0     => BA(0),
      BA1     => BA(1),
      BA2     => '0',
      A0      => ADDR(0),
      A1      => ADDR(1),
      A2      => ADDR(2),
      A3      => ADDR(3),
      A4      => ADDR(4),
      A5      => ADDR(5),
      A6      => ADDR(6),
      A7      => ADDR(7),
      A8      => ADDR(8),
      A9      => ADDR(9),
      A10     => ADDR(10),
      A11     => ADDR(11),
      A12     => ADDR(12),
      DQ0     => DQ(0),
      DQ1     => DQ(1),
      DQ2     => DQ(2),
      DQ3     => DQ(3),
      DQ4     => DQ(4),
      DQ5     => DQ(5),
      DQ6     => DQ(6),
      DQ7     => DQ(7),
      DQ8     => DQ(8),
      DQ9     => DQ(9),
      DQ10    => DQ(10),
      DQ11    => DQ(11),
      DQ12    => DQ(12),
      DQ13    => DQ(13),
      DQ14    => DQ(14),
      DQ15    => DQ(15),
      UDQS    => DQSH,
      UDQSNeg => udqsneg,
      LDQS    => DQSL,
      LDQSNeg => ldqsneg);


  CLK     <= transport mainclk after clk_period * 1 / 4;
  CLK90   <= transport mainclk after clk_period * 2 / 4;
  CLK180  <= transport mainclk after clk_period * 3 / 4;
  CLK270  <= transport mainclk;
  CLKN    <= not CLK;
  CLK90N  <= not CLK90;
  CLK270N <= not clk270;
  CLK180N <= not clk180;

  ddr2clkdriver_inst : ddr2clkdriver
    port map (
      CLKIN    => clk270,
      RESET    => RESET,
      CLKOUT_P => memclk,
      CLKOUT_N => memclkn); 

  memdebug_uut : memdebug
    port map (
      MEMCLK   => clk,
      MEMRESET => memrst,
      MEMREADY => memready,
      START    => start,
      rw       => rw,
      DONE     => done,
      ROWTGT   => rowtgt,
      WRADDR   => wraddr,
      WRDATA   => wrdata,
      RDADDR   => rdaddr,
      RDDATA   => RDDATA,
      RDWE     => rdwe,
      CCLK     => CCLK,
      CRDADDR  => CRDADDR,
      CWRADDR  => CWRADDR,
      CWE      => CWE,
      CRD      => CRD,
      CDOUT    => CDOUT,
      CDIN     => CDIN); 


  process
  begin

    -- check if we can read and write to the debug register
    wait until rising_edge(CLK);
    readword(0, crdaddr, crd);
    wait until rising_edge(CLK);
    writeword(0, X"1234", cwraddr, cwe, cdin);
    wait until rising_edge(CLK);
    readword(0, crdaddr, crd);
    assert CDOUT = X"1234" report "Error reading debug word" severity error;

    -- now wait unti memready
    while true loop
      wait until rising_edge(CLK);
      readword(2, crdaddr, crd);
      exit when CDOUT = X"0001";
    end loop;
    wait for 20 us;
    
    -- write four rows, and read them back
    for rowtgti in 0 to 3 loop
      
      for i in 0 to 511 loop
        -- write the address
        writeword(4, std_logic_vector(TO_UNSIGNED(i, 16)), cwraddr, cwe, cdin);
        writeword(5, std_logic_vector(TO_UNSIGNED(i + 1 + rowtgti * 256, 16)),
                  cwraddr, cwe, cdin);
      end loop;  -- i
      -- write row tgt 
      writeword(3, std_logic_vector(TO_UNSIGNED(rowtgti, 16)), cwraddr, cwe, cdin);
      -- check that the row tgt was written
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      assert ROWTGT = std_logic_vector(TO_UNSIGNED(rowtgti, 15))
        report "Error setting row tgt" severity error;
      readword(3, crdaddr, crd);
      assert CDOUT = std_logic_vector(TO_UNSIGNED(rowtgti, 16))
        report "error reading row tgt" severity error;

      -- now start the transaction, nonce is rowtgti + 1234
      writeword(13, std_logic_vector(TO_UNSIGNED(rowtgti + 1234, 16)),
                cwraddr, cwe, cdin);
      -- now loop and wait
      while true loop
        wait until rising_edge(CLK);
        readword(14, crdaddr, crd);
        exit when CDOUT = std_logic_vector(TO_UNSIGNED(rowtgti + 1234, 16));
      end loop;
      
    end loop;  -- rowi

    -- Read four rows, and verify their contents
    for rowtgti in 0 to 3 loop
      
      -- write row tgt 
      writeword(3, std_logic_vector(TO_UNSIGNED(rowtgti, 16)), cwraddr, cwe, cdin);
      -- check that the row tgt was written
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      assert ROWTGT = std_logic_vector(TO_UNSIGNED(rowtgti, 15))
        report "Error setting row tgt" severity error;
      readword(3, crdaddr, crd);
      assert CDOUT = std_logic_vector(TO_UNSIGNED(rowtgti, 16))
        report "error reading row tgt" severity error;

      -- now start the transaction, nonce is rowtgti + 1234
      writeword(12, std_logic_vector(TO_UNSIGNED(rowtgti + 1234, 16)),
                cwraddr, cwe, cdin);
      -- now loop and wait
      while true loop
        wait until rising_edge(CLK);
        readword(14, crdaddr, crd);
        exit when CDOUT = std_logic_vector(TO_UNSIGNED(rowtgti + 1234, 16));
      end loop;

      for i in 0 to 511 loop
        -- write the address
        writeword(4, std_logic_vector(TO_UNSIGNED(i, 16)), cwraddr, cwe, cdin);
        readword(9, crdaddr, crd); 
        assert CDOUT = std_logic_vector(TO_UNSIGNED(i + 1 +  rowtgti * 256, 16))
          report "Error reading out word" severity error;
      end loop;  -- i
      
    end loop;  -- rowi


     --  Try and reset the interface
    writeword(1,X"0001", 
              cwraddr, cwe, cdin);
    wait until rising_edge(CLK) and MEMREADY = '0';
    
    writeword(1,X"0000", 
              cwraddr, cwe, cdin);
    
    -- now wait unti memready
    while true loop
      wait until rising_edge(CLK);
      readword(2, crdaddr, crd);
      exit when CDOUT = X"0001";
    end loop;
    wait for 20 us;
    


    report "End of Simulation" severity failure;
    
  end process;
end Behavioral;
