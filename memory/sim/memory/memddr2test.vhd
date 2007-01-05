library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.VITAL_timing.ALL;
USE IEEE.VITAL_primitives.ALL;

LIBRARY FMF;       USE FMF.gen_utils.ALL;
                   USE FMF.conversions.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity memddr2test is

end memddr2test;

architecture Behavioral of memddr2test is

  component memddr2
    port (
      CLK        : in    std_logic;
      CLK90      : in    std_logic;
      CLK180     : in    std_logic;
      CLK270     : in    std_logic;
      RESET      : in    std_logic;
      -- RAM!
      CKE        : out   std_logic;
      CAS        : out   std_logic;
      RAS        : out   std_logic;
      CS         : out   std_logic;
      WE         : out   std_logic;
      ADDR       : out   std_logic_vector(12 downto 0);
      BA         : out   std_logic_vector(1 downto 0);
      DQSH       : inout std_logic := '0';
      DQSL       : inout std_logic := '0';
      DQ         : inout std_logic_vector(15 downto 0);
      -- interface
      START      : in    std_logic;
      RW         : in    std_logic;
      DONE       : out   std_logic;
      -- write interface
      ROWTGT     : in    std_logic_vector(14 downto 0);
      WRADDR     : out   std_logic_vector(7 downto 0);
      WRDATA     : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR     : out   std_logic_vector(7 downto 0);
      RDDATA     : out   std_logic_vector(31 downto 0);
      RDWE       : out   std_logic
      );
  end component;

  signal CLK, CLKN       : std_logic := '0';
  signal CLK90, CLK90N   : std_logic := '0';
  signal CLK180, clk180n : std_logic := '0';
  signal CLK270, clk270n : std_logic := '0';
  signal RESET           : std_logic := '1';


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

--   component HY5PS121621F
--     generic (
--       TimingCheckFlag :       boolean                       := true;
--       PUSCheckFlag    :       boolean                       := false;
--       Part_Number     :       PART_NUM_TYPE                 := B400);
--     port
--       ( DQ            : inout std_logic_vector(15 downto 0) := (others => 'Z');
--         LDQS          : inout std_logic                     := 'Z';
--         LDQSB         : inout std_logic                     := 'Z';
--         UDQS          : inout std_logic                     := 'Z';
--         UDQSB         : inout std_logic                     := 'Z';
--         LDM           : in    std_logic;
--         WEB           : in    std_logic;
--         CASB          : in    std_logic;
--         RASB          : in    std_logic;
--         CSB           : in    std_logic;
--         BA            : in    std_logic_vector(1 downto 0);
--         ADDR          : in    std_logic_vector(12 downto 0);
--         CKE           : in    std_logic;
--         CLK           : in    std_logic;
--         CLKB          : in    std_logic;
--         UDM           : in    std_logic;
--         odelay        : in    time                          := 0 ps);
--   end component;

  component mt47h64m16
        GENERIC (
        -- tipd delays: interconnect path delays
        tipd_ODT          : VitalDelayType01 := VitalZeroDelay01;
        tipd_CK           : VitalDelayType01 := VitalZeroDelay01;
        tipd_CKNeg        : VitalDelayType01 := VitalZeroDelay01;
        tipd_CKE          : VitalDelayType01 := VitalZeroDelay01;
        tipd_CSNeg        : VitalDelayType01 := VitalZeroDelay01;
        tipd_RASNeg       : VitalDelayType01 := VitalZeroDelay01;
        tipd_CASNeg       : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg        : VitalDelayType01 := VitalZeroDelay01;
        tipd_LDM          : VitalDelayType01 := VitalZeroDelay01;
        tipd_UDM          : VitalDelayType01 := VitalZeroDelay01;
        tipd_BA0          : VitalDelayType01 := VitalZeroDelay01;
        tipd_BA1          : VitalDelayType01 := VitalZeroDelay01;
        tipd_BA2          : VitalDelayType01 := VitalZeroDelay01;
        tipd_A0           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A1           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A2           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A3           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A4           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A5           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A6           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A7           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A8           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A9           : VitalDelayType01 := VitalZeroDelay01;
        tipd_A10          : VitalDelayType01 := VitalZeroDelay01;
        tipd_A11          : VitalDelayType01 := VitalZeroDelay01;
        tipd_A12          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ0          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ1          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ2          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ3          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ4          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ5          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ6          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ7          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ8          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ9          : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ10         : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ11         : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ12         : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ13         : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ14         : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ15         : VitalDelayType01 := VitalZeroDelay01;
        tipd_UDQS         : VitalDelayType01 := VitalZeroDelay01;
        tipd_UDQSNeg      : VitalDelayType01 := VitalZeroDelay01;
        tipd_LDQS         : VitalDelayType01 := VitalZeroDelay01;
        tipd_LDQSNeg      : VitalDelayType01 := VitalZeroDelay01;

        -- tpd delays
        tpd_CK_DQ0        : VitalDelayType01Z := UnitDelay01Z; -- tAC(max), tHZ
        tpd_CK_DQ1        : VitalDelayType := UnitDelay; -- tAC(min)
        tpd_CK_LDQS       : VitalDelayType01Z := UnitDelay01Z; -- tDQSCK(max)

        -- tsetup values
        tsetup_DQ0_LDQS   : VitalDelayType := UnitDelay; -- tDSb
        tsetup_A0_CK      : VitalDelayType := UnitDelay; -- tISb
        tsetup_LDQS_CK_CL3_negedge_posedge: VitalDelayType := UnitDelay; -- tDSS
        tsetup_LDQS_CK_CL4_negedge_posedge: VitalDelayType := UnitDelay; -- tDSS
        tsetup_LDQS_CK_CL5_negedge_posedge: VitalDelayType := UnitDelay; -- tDSS
        tsetup_LDQS_CK_CL6_negedge_posedge: VitalDelayType := UnitDelay; -- tDSS
        -- thold values
        thold_DQ0_LDQS    : VitalDelayType := UnitDelay; -- tDHb
        thold_A0_CK       : VitalDelayType := UnitDelay; -- tIHb
        thold_LDQS_CK_CL3_posedge_posedge : VitalDelayType := UnitDelay; -- tDSH
        thold_LDQS_CK_CL4_posedge_posedge : VitalDelayType := UnitDelay; -- tDSH
        thold_LDQS_CK_CL5_posedge_posedge : VitalDelayType := UnitDelay; -- tDSH
        thold_LDQS_CK_CL6_posedge_posedge : VitalDelayType := UnitDelay; -- tDSH
        -- tpw values
        tpw_CK_CL3_posedge: VitalDelayType := UnitDelay; -- tCHAVG
        tpw_CK_CL3_negedge: VitalDelayType := UnitDelay; -- tCLAVG
        tpw_CK_CL4_posedge: VitalDelayType := UnitDelay; -- tCHAVG
        tpw_CK_CL4_negedge: VitalDelayType := UnitDelay; -- tCLAVG
        tpw_CK_CL5_posedge: VitalDelayType := UnitDelay; -- tCHAVG
        tpw_CK_CL5_negedge: VitalDelayType := UnitDelay; -- tCLAVG
        tpw_CK_CL6_posedge: VitalDelayType := UnitDelay; -- tCHAVG
        tpw_CK_CL6_negedge: VitalDelayType := UnitDelay; -- tCLAVG
        tpw_A0_CL3        : VitalDelayType := UnitDelay; -- tIPW
        tpw_A0_CL4        : VitalDelayType := UnitDelay; -- tIPW
        tpw_A0_CL5        : VitalDelayType := UnitDelay; -- tIPW
        tpw_A0_CL6        : VitalDelayType := UnitDelay; -- tIPW
        tpw_DQ0_CL3       : VitalDelayType := UnitDelay; -- tDIPW
        tpw_DQ0_CL4       : VitalDelayType := UnitDelay; -- tDIPW
        tpw_DQ0_CL5       : VitalDelayType := UnitDelay; -- tDIPW
        tpw_DQ0_CL6       : VitalDelayType := UnitDelay; -- tDIPW
        tpw_LDQS_normCL3_posedge : VitalDelayType := UnitDelay; -- tDQSH
        tpw_LDQS_normCL3_negedge : VitalDelayType := UnitDelay; -- tDQSL
        tpw_LDQS_normCL4_posedge : VitalDelayType := UnitDelay; -- tDQSH
        tpw_LDQS_normCL4_negedge : VitalDelayType := UnitDelay; -- tDQSL
        tpw_LDQS_normCL5_posedge : VitalDelayType := UnitDelay; -- tDQSH
        tpw_LDQS_normCL5_negedge : VitalDelayType := UnitDelay; -- tDQSL
        tpw_LDQS_normCL6_posedge : VitalDelayType := UnitDelay; -- tDQSH
        tpw_LDQS_normCL6_negedge : VitalDelayType := UnitDelay; -- tDQSL
        tpw_LDQS_preCL3_negedge  : VitalDelayType := UnitDelay; -- tWPRE
        tpw_LDQS_preCL4_negedge  : VitalDelayType := UnitDelay; -- tWPRE
        tpw_LDQS_preCL5_negedge  : VitalDelayType := UnitDelay; -- tWPRE
        tpw_LDQS_preCL6_negedge  : VitalDelayType := UnitDelay; -- tWPRE
        tpw_LDQS_postCL3_negedge : VitalDelayType := UnitDelay; -- tWPST
        tpw_LDQS_postCL4_negedge : VitalDelayType := UnitDelay; -- tWPST
        tpw_LDQS_postCL5_negedge : VitalDelayType := UnitDelay; -- tWPST
        tpw_LDQS_postCL6_negedge : VitalDelayType := UnitDelay; -- tWPST

        -- tperiod values
        tperiod_CK_CL3    : VitalDelayType := UnitDelay; -- tCKAVG(min)
        tperiod_CK_CL4    : VitalDelayType := UnitDelay; -- tCKAVG(min)
        tperiod_CK_CL5    : VitalDelayType := UnitDelay; -- tCKAVG(min)
        tperiod_CK_CL6    : VitalDelayType := UnitDelay; -- tCKAVG(min)
        -- tskew values
        tskew_CK_LDQS_CL3_posedge_posedge: VitalDelayType := UnitDelay; -- tDQSS
        tskew_CK_LDQS_CL4_posedge_posedge: VitalDelayType := UnitDelay; -- tDQSS
        tskew_CK_LDQS_CL5_posedge_posedge: VitalDelayType := UnitDelay; -- tDQSS
        tskew_CK_LDQS_CL6_posedge_posedge: VitalDelayType := UnitDelay; -- tDQSS

        -- tdevice values: values for internal delays
        tdevice_tRC       : VitalDelayType    := 54 ns; -- tRC
        tdevice_tRRD      : VitalDelayType    := 10 ns; -- tRRD
        tdevice_tRCD      : VitalDelayType    := 12 ns; -- tRCD
        tdevice_tFAW      : VitalDelayType    := 50 ns; -- tFAW
        tdevice_tRASMIN   : VitalDelayType    := 40 ns; -- tRAS(min)
        tdevice_tRASMAX   : VitalDelayType    := 70 us; -- tRAS(max)
        tdevice_tRTP      : VitalDelayType    := 7.5 ns; -- tRTP
        tdevice_tWR       : VitalDelayType    := 15 ns; -- tWR
        tdevice_tWTR      : VitalDelayType    := 7.5 ns; -- tWTR
        tdevice_tRP       : VitalDelayType    := 12 ns; -- tRP
        tdevice_tRFCMIN   : VitalDelayType    := 127.5 ns; -- tRFC(min)
        tdevice_tRFCMAX   : VitalDelayType    := 70 us; -- tRFC(max)
        tdevice_REFPer    : VitalDelayType    := 64 ms; -- refresh period
        tdevice_tCKAVGMAX : VitalDelayType    := 8 ns; -- tCKAVG(max)

        -- generic control parameters
        InstancePath      : string    := DefaultInstancePath;
        TimingChecksOn    : boolean   := DefaultTimingChecks;
        MsgOn             : boolean   := DefaultMsgOn;
        XOn               : boolean   := DefaultXon;

        -- memory file to be loaded
        mem_file_name     : string    := "none";
        UserPreload       : boolean   := FALSE;

        -- For FMF SDF technology file usage
        TimingModel       : string    := DefaultTimingModel); 


    PORT (
        ODT             : IN    std_ulogic := 'U';
        CK              : IN    std_ulogic := 'U';
        CKNeg           : IN    std_ulogic := 'U';
        CKE             : IN    std_ulogic := 'U';
        CSNeg           : IN    std_ulogic := 'U';
        RASNeg          : IN    std_ulogic := 'U';
        CASNeg          : IN    std_ulogic := 'U';
        WENeg           : IN    std_ulogic := 'U';
        LDM             : IN    std_ulogic := 'U';
        UDM             : IN    std_ulogic := 'U';
        BA0             : IN    std_ulogic := 'U';
        BA1             : IN    std_ulogic := 'U';
        BA2             : IN    std_ulogic := 'U';
        A0              : IN    std_ulogic := 'U';
        A1              : IN    std_ulogic := 'U';
        A2              : IN    std_ulogic := 'U';
        A3              : IN    std_ulogic := 'U';
        A4              : IN    std_ulogic := 'U';
        A5              : IN    std_ulogic := 'U';
        A6              : IN    std_ulogic := 'U';
        A7              : IN    std_ulogic := 'U';
        A8              : IN    std_ulogic := 'U';
        A9              : IN    std_ulogic := 'U';
        A10             : IN    std_ulogic := 'U';
        A11             : IN    std_ulogic := 'U';
        A12             : IN    std_ulogic := 'U';
        DQ0             : INOUT std_ulogic := 'U';
        DQ1             : INOUT std_ulogic := 'U';
        DQ2             : INOUT std_ulogic := 'U';
        DQ3             : INOUT std_ulogic := 'U';
        DQ4             : INOUT std_ulogic := 'U';
        DQ5             : INOUT std_ulogic := 'U';
        DQ6             : INOUT std_ulogic := 'U';
        DQ7             : INOUT std_ulogic := 'U';
        DQ8             : INOUT std_ulogic := 'U';
        DQ9             : INOUT std_ulogic := 'U';
        DQ10            : INOUT std_ulogic := 'U';
        DQ11            : INOUT std_ulogic := 'U';
        DQ12            : INOUT std_ulogic := 'U';
        DQ13            : INOUT std_ulogic := 'U';
        DQ14            : INOUT std_ulogic := 'U';
        DQ15            : INOUT std_ulogic := 'U';
        UDQS            : INOUT std_ulogic := 'U';
        UDQSNeg         : INOUT std_ulogic := 'U';
        LDQS            : INOUT std_ulogic := 'U';
        LDQSNeg         : INOUT std_ulogic := 'U'
    );

END component;


  signal mainclk : std_logic := '0';
  signal clkpos  : integer   := 1;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.66 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal odelay : time := 0 ps;


  type outbuffer is array (0 to 1023) of std_logic_vector(15 downto 0);
  signal outbufferA : outbuffer := (others => (others => '0'));

  signal memclk, memclkn : std_logic := '0';

   signal udqsneg, ldqsneg : std_logic := '0';




begin  -- Behavioral

  DQSH <= 'L';
  DQSL <= 'L';
  udqsneg <= 'H';
  ldqsneg <= 'H';
  
  memddr2_uut : memddr2
    port map (
      CLK        => CLK,
      CLK90      => CLK90,
      CLK180     => CLK180,
      CLK270     => CLK270,
      RESET      => RESET,
      CKE        => CKE,
      CAS        => CAS,
      RAS        => RAS,
      CS         => CS,
      WE         => WE,
      ADDR       => ADDR,
      BA         => BA,
      DQSH       => DQSH,
      DQSL       => DQSL,
      DQ         => DQ,
      START      => START,
      RW         => RW,
      DONE       => DONE,
      ROWTGT     => ROWTGT,
      WRADDR     => WRADDR,
      WRDATA     => WRDATA,
      RDADDR     => RDADDR,
      RDDATA     => RDDATA,
      RDWE       => RDWE);

  mainclk <= not mainclk after (clk_period / 2);

--   memory_inst : HY5PS121621F
--     generic map (
--       TimingCheckFlag => true,
--       PUSCheckFlag    => true,
--       PArt_number     => B400)
--     port map (
--       DQ              => DQ,
--       LDQS            => DQSL,
--       UDQS            => DQSH,
--       WEB             => WE,
--       LDM             => '0',
--       UDM             => '0',
--       CASB            => CAS,
--       RASB            => RAS,
--       CSB             => CS,
--       BA              => BA,
--       ADDR            => ADDR,
--       CKE             => CKE,
--       CLK             => memCLK,
--       CLKB            => memCLKN,
--       odelay          => odelay);

  memory_inst: mt47h64m16
    generic map (
--         -- tpd delays
--         tpd_CK_DQ0        : VitalDelayType01Z := UnitDelay01Z; -- tAC(max), tHZ
--         tpd_CK_DQ1        : VitalDelayType := UnitDelay; -- tAC(min)
--         tpd_CK_LDQS       : VitalDelayType01Z := UnitDelay01Z; -- tDQSCK(max)

        -- tsetup values
--         tsetup_DQ0_LDQS  => 0.1 ns, 
--         tsetup_A0_CK     => 0.2 ns, 
--         tsetup_LDQS_CK_CL3_negedge_posedge => 0.6 ns,
--         tsetup_LDQS_CK_CL4_negedge_posedge => 0.75 ns, 
--         tsetup_LDQS_CK_CL5_negedge_posedge => 1 ns, 
--         tsetup_LDQS_CK_CL6_negedge_posedge => 0 ns, 

--         -- thold values
--         thold_DQ0_LDQS    => 0.175 ns, 
--         thold_A0_CK       => 0.275 ns, 
--         thold_LDQS_CK_CL3_posedge_posedge => 1 ns,  -- tDSH
--         thold_LDQS_CK_CL4_posedge_posedge => 0.75 ns, -- tDSH
--         thold_LDQS_CK_CL5_posedge_posedge => 0.6 ns,  -- tDSH
--         thold_LDQS_CK_CL6_posedge_posedge => 0 ns, -- tDSH

--         -- tpw values
--         tpw_CK_CL3_posedge => 2.4 ns,  -- tCHAVG
--         tpw_CK_CL3_negedge => 2.4 ns,  -- tCLAVG
--         tpw_CK_CL4_posedge=> 1.8 ns, -- tCHAVG
--         tpw_CK_CL4_negedge=> 1.8 ns, -- tCLAVG
--         tpw_CK_CL5_posedge=> 1.44 ns, -- tCHAVG
--         tpw_CK_CL5_negedge=> 1.44 ns, -- tCLAVG
--         tpw_CK_CL6_posedge=> 0 ns,  -- tCHAVG
--         tpw_CK_CL6_negedge=> 0 ns,  -- tCLAVG
--         tpw_A0_CL3        => 3 ns, 
--         tpw_A0_CL4        => 2.25 ns, 
--         tpw_A0_CL5        => 1.8 ns,
--         tpw_A0_CL6        => 0 ns, 
--         tpw_DQ0_CL3       => 1.75 ns, 
--         tpw_DQ0_CL4       => 1.312 ns, 
--         tpw_DQ0_CL5       => 1.05 ns, 
--         tpw_DQ0_CL6       => 0 ns, 
--         tpw_LDQS_normCL3_posedge => 1.75 ns,  -- tDQSH
--         tpw_LDQS_normCL3_negedge => 1.75 ns,  -- tDQSL
--         tpw_LDQS_normCL4_posedge => 1.312 ns,  -- tDQSH
--         tpw_LDQS_normCL4_negedge => 1.312 ns,  -- tDQSL
--         tpw_LDQS_normCL5_posedge => 1.05 ns,  -- tDQSH
--         tpw_LDQS_normCL5_negedge => 1.05 ns,  -- tDQSL
--         tpw_LDQS_normCL6_posedge => 0 ns,  -- tDQSH
--         tpw_LDQS_normCL6_negedge => 0 ns,  -- tDQSL
--         tpw_LDQS_preCL3_negedge  => 1.75 ns,  -- tWPRE
--         tpw_LDQS_preCL4_negedge  => 1.312 ns,  -- tWPRE
--         tpw_LDQS_preCL5_negedge  => 1.05 ns, -- tWPRE
--         tpw_LDQS_preCL6_negedge  => 0 ns, -- tWPRE
--         tpw_LDQS_postCL3_negedge => 2 ns,  -- tWPST
--         tpw_LDQS_postCL4_negedge => 1.5 ns,  -- tWPST
--         tpw_LDQS_postCL5_negedge => 1.2 ns, -- tWPST
--         tpw_LDQS_postCL6_negedge => 0 ns, -- tWPST

--         -- tperiod values
--         tperiod_CK_CL3    => 5 ns, 
--         tperiod_CK_CL4    => 3.75 ns, 
--         tperiod_CK_CL5    => 3 ns, 
--         tperiod_CK_CL6    => 0 ns, 

--         -- tskew values
--         tskew_CK_LDQS_CL3_posedge_posedge => 1.25 ns, 
--         tskew_CK_LDQS_CL4_posedge_posedge => 0.937 ns,
--         tskew_CK_LDQS_CL5_posedge_posedge => 0.75 ns,
--         tskew_CK_LDQS_CL6_posedge_posedge => 0 ns, 

        -- tdevice values: values for internal delays ( use defaults)
--          tdevice_tRC       : VitalDelayType    := 54 ns; -- tRC
--          tdevice_tRRD      : VitalDelayType    := 10 ns; -- tRRD
--          tdevice_tRCD      : VitalDelayType    := 12 ns; -- tRCD
--          tdevice_tFAW      : VitalDelayType    := 50 ns; -- tFAW
--          tdevice_tRASMIN   : VitalDelayType    := 40 ns; -- tRAS(min)
--          tdevice_tRASMAX   : VitalDelayType    := 70 us; -- tRAS(max)
--          tdevice_tRTP      : VitalDelayType    := 7.5 ns; -- tRTP
--          tdevice_tWR       : VitalDelayType    := 15 ns; -- tWR
--          tdevice_tWTR      : VitalDelayType    := 7.5 ns; -- tWTR
--          tdevice_tRP       : VitalDelayType    := 12 ns; -- tRP
--          tdevice_tRFCMIN   : VitalDelayType    := 127.5 ns; -- tRFC(min)
--          tdevice_tRFCMAX   : VitalDelayType    := 70 us; -- tRFC(max)
--          tdevice_REFPer    : VitalDelayType    := 64 ms; -- refresh period
--          tdevice_tCKAVGMAX : VitalDelayType    := 8 ns; -- tCKAVG(max)
            tipd_ODT            => VitalZeroDelay01,
            tipd_BA0            => VitalZeroDelay01,
            tipd_BA1            => VitalZeroDelay01,
            tipd_BA2            => VitalZeroDelay01,
            tipd_UDM            => VitalZeroDelay01,
            tipd_LDM            => VitalZeroDelay01,
            tipd_DQ0            => VitalZeroDelay01,
            tipd_DQ1            => VitalZeroDelay01,
            tipd_DQ2            => VitalZeroDelay01,
            tipd_DQ3            => VitalZeroDelay01,
            tipd_DQ4            => VitalZeroDelay01,
            tipd_DQ5            => VitalZeroDelay01,
            tipd_DQ6            => VitalZeroDelay01,
            tipd_DQ7            => VitalZeroDelay01,
            tipd_DQ8            => VitalZeroDelay01,
            tipd_DQ9            => VitalZeroDelay01,
            tipd_DQ10           => VitalZeroDelay01,
            tipd_DQ11           => VitalZeroDelay01,
            tipd_DQ12           => VitalZeroDelay01,
            tipd_DQ13           => VitalZeroDelay01,
            tipd_DQ14           => VitalZeroDelay01,
            tipd_DQ15           => VitalZeroDelay01,
            tipd_UDQS           => VitalZeroDelay01,
            tipd_UDQSNeg        => VitalZeroDelay01,
            tipd_LDQS           => VitalZeroDelay01,
            tipd_LDQSNeg        => VitalZeroDelay01,
            tipd_A0             => VitalZeroDelay01,
            tipd_A1             => VitalZeroDelay01,
            tipd_A2             => VitalZeroDelay01,
            tipd_A3             => VitalZeroDelay01,
            tipd_A4             => VitalZeroDelay01,
            tipd_A5             => VitalZeroDelay01,
            tipd_A6             => VitalZeroDelay01,
            tipd_A7             => VitalZeroDelay01,
            tipd_A8             => VitalZeroDelay01,
            tipd_A9             => VitalZeroDelay01,
            tipd_A10            => VitalZeroDelay01,
            tipd_A11            => VitalZeroDelay01,
            tipd_A12            => VitalZeroDelay01,
            tipd_CK             => VitalZeroDelay01,
            tipd_CKNeg          => VitalZeroDelay01,
            tipd_CKE            => VitalZeroDelay01,
            tipd_WENeg          => VitalZeroDelay01,
            tipd_RASNeg         => VitalZeroDelay01,
            tipd_CSNeg          => VitalZeroDelay01,
            tipd_CASNeg         => VitalZeroDelay01,

            tpd_CK_DQ0          => UnitDelay01Z,
            tpd_CK_DQ1          => UnitDelay,
            tpd_CK_LDQS         => UnitDelay01Z,

            tsetup_DQ0_LDQS     => UnitDelay,
            tsetup_A0_CK        => UnitDelay,
            tsetup_LDQS_CK_CL3_negedge_posedge => UnitDelay,
            tsetup_LDQS_CK_CL4_negedge_posedge => UnitDelay,
            tsetup_LDQS_CK_CL5_negedge_posedge => UnitDelay,
            tsetup_LDQS_CK_CL6_negedge_posedge => UnitDelay,

            thold_DQ0_LDQS      => UnitDelay,
            thold_A0_CK         => UnitDelay,
            thold_LDQS_CK_CL3_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL4_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL5_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL6_posedge_posedge => UnitDelay,

            tpw_CK_CL3_posedge  => UnitDelay,
            tpw_CK_CL3_negedge  => UnitDelay,
            tpw_CK_CL4_posedge  => UnitDelay,
            tpw_CK_CL4_negedge  => UnitDelay,
            tpw_CK_CL5_posedge  => UnitDelay,
            tpw_CK_CL5_negedge  => UnitDelay,
            tpw_CK_CL6_posedge  => UnitDelay,
            tpw_CK_CL6_negedge  => UnitDelay,
            tpw_A0_CL3          => UnitDelay,
            tpw_A0_CL4          => UnitDelay,
            tpw_A0_CL5          => UnitDelay,
            tpw_A0_CL6          => UnitDelay,
            tpw_DQ0_CL3         => UnitDelay,
            tpw_DQ0_CL4         => UnitDelay,
            tpw_DQ0_CL5         => UnitDelay,
            tpw_DQ0_CL6         => UnitDelay,
            tpw_LDQS_normCL3_posedge  => UnitDelay,
            tpw_LDQS_normCL3_negedge  => UnitDelay,
            tpw_LDQS_normCL4_posedge  => UnitDelay,
            tpw_LDQS_normCL4_negedge  => UnitDelay,
            tpw_LDQS_normCL5_posedge  => UnitDelay,
            tpw_LDQS_normCL5_negedge  => UnitDelay,
            tpw_LDQS_normCL6_posedge  => UnitDelay,
            tpw_LDQS_normCL6_negedge  => UnitDelay,
            tpw_LDQS_preCL3_negedge   => UnitDelay,
            tpw_LDQS_preCL4_negedge   => UnitDelay,
            tpw_LDQS_preCL5_negedge   => UnitDelay,
            tpw_LDQS_preCL6_negedge   => UnitDelay,
            tpw_LDQS_postCL3_negedge  => UnitDelay,
            tpw_LDQS_postCL4_negedge  => UnitDelay,
            tpw_LDQS_postCL5_negedge  => UnitDelay,
            tpw_LDQS_postCL6_negedge  => UnitDelay,

            tperiod_CK_CL3      => UnitDelay,
            tperiod_CK_CL4      => UnitDelay,
            tperiod_CK_CL5      => UnitDelay,
            tperiod_CK_CL6      => UnitDelay,

            tskew_CK_LDQS_CL3_posedge_posedge   => UnitDelay,
            tskew_CK_LDQS_CL4_posedge_posedge   => UnitDelay,
            tskew_CK_LDQS_CL5_posedge_posedge   => UnitDelay,
            tskew_CK_LDQS_CL6_posedge_posedge   => UnitDelay,

            tdevice_tRC         => 54 ns,
            tdevice_tRRD        => 10 ns,
            tdevice_tRCD        => 12 ns,
            tdevice_tFAW        => 50 ns,
            tdevice_tRASMIN     => 40 ns,
            tdevice_tRASMAX     => 70 us,
            tdevice_tRTP        => 7.5 ns,
            tdevice_tWR         => 15 ns,
            tdevice_tWTR        => 7.5 ns,
            tdevice_tRP         => 12 ns,
            tdevice_tRFCMIN     => 127.5 ns,
            tdevice_tRFCMAX     => 70 us,
            tdevice_REFPer      => 64 ms,
            tdevice_tCKAVGMAX   => 8 ns,
        -- generic control parameters
        TimingChecksOn    => True, 
        MsgOn             => True, 

      TimingModel => "MT47H64M16BT-3" )
    port map (
      ODT    => '0',
      CK    => memCLK,
      CKNeg  => memCLKN,
      CKE    => CKE,
      CSNeg  => CS,
      RASNeg => RAS,
      CASNEG => CAS,
      WENeg  => WE,
      LDM    => '0',
      UDM    => '0',
      BA0    => BA(0),
      BA1    => BA(1),
      BA2 => '0',
      A0 => ADDR(0),
      A1 => ADDR(1),
      A2 => ADDR(2),
      A3 => ADDR(3),
      A4 => ADDR(4),
      A5 => ADDR(5),
      A6 => ADDR(6),
      A7 => ADDR(7),
      A8 => ADDR(8),
      A9 => ADDR(9),
      A10 => ADDR(10),
      A11 => ADDR(11),
      A12 => ADDR(12),
      DQ0 => DQ(0),
      DQ1 => DQ(1),
      DQ2 => DQ(2),
      DQ3 => DQ(3),
      DQ4 => DQ(4),
      DQ5 => DQ(5),
      DQ6 => DQ(6),
      DQ7 => DQ(7),
      DQ8 => DQ(8),
      DQ9 => DQ(9),
      DQ10 => DQ(10),
      DQ11 => DQ(11),
      DQ12 => DQ(12),
      DQ13 => DQ(13),
      DQ14 => DQ(14),
      DQ15 => DQ(15),
      UDQS => DQSH,
      UDQSNeg =>  udqsneg,
      LDQS => DQSL,
      LDQSNeg => ldqsneg); 
     

  CLK <= transport mainclk after clk_period * 1 / 4; 
  CLK90 <= transport mainclk after clk_period * 2 / 4; 
  CLK180  <= transport mainclk after clk_period * 3 / 4; 
  CLK270 <= transport mainclk after clk_period * 4 / 4; 
  CLKN    <= not CLK;
  CLK90N  <= not CLK90;
  CLK270N <= not clk270;
  CLK180N <= not clk180;

  memclk  <= clk270;
  memclkn <= clk270n;


  -- fake write memory
  wrmem              : process(CLK)
    variable wraddrl : std_logic_vector(7 downto 0) := (others => '0');

  begin
    if rising_edge(CLK) then
      WRDATA <= ( (burstcnt & wraddrl) & (not (burstcnt & wraddrl) ));
      wraddrl := WRADDR;

    end if;
  end process wrmem;

  main : process
  begin


    for tpos in 0 to 20 loop
      RESET <= '1';
      wait for 50 ns;

      RESET <= '0';
      wait for 550 us;

      --odelay <= 107 ps * tpos;


      wait until rising_edge(CLK);

      for i in 0 to 10 loop
        START <= '1';
        RW    <= '1';
        wait until rising_edge(CLK) and DONE = '1';

        START <= '0';
        RW    <= '1';
        wait for 5 us;

        wait until rising_edge(CLK);

        START <= '1';
        RW    <= '0';
        wait until rising_edge(CLK) and DONE = '1';

        START <= '0';
        RW    <= '0';
        wait for 5 us;
        --report "Finished with Row" severity Note;

        burstcnt <= burstcnt + 1;
        ROWTGT   <= ROWTGT + 1;
      end loop;  -- i

    end loop;  -- tpos

    wait;

  end process main;


  -- reader
  read_verify : process

  begin
    -- wait for read to start


    wait until falling_edge(RESET);

    ---------------------------------------------------------------------------
    -- READ AND VERIFY 10 BURSTS
    ---------------------------------------------------------------------------

    -- we wait for  the first write to get into the read-verification
    -- code so that we avoid the dqdelay lock read burst

    wait until rising_edge(CLK) and START = '1' and RW = '1';

    for i in 0 to 10 loop
      wrdcnt <= 0;
      wait until rising_edge(CLK) and START = '1' and RW = '0';

      while DONE /= '1' loop
        if RDWE = '1' then
          if rddata = ((burstcnt & rdaddr) & (not (burstcnt & rdaddr))) then
            wrdcnt <= wrdcnt + 1;
          else
            report "error reading back data" severity error;
          end if;
        end if;
        wait until rising_edge(CLK);

      end loop;
      if wrdcnt /= 256 then
        report "Read less than 256 words" severity error;
      end if;
      
    end loop;  -- i

    report "End of Simulation" severity failure;


  end process read_verify;
end Behavioral;
