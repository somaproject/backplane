--------------------------------------------------------------------------------
--  File Name: tbmt47h64m16.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 2003 Free Model Foundry; http://eda.org/fmf/
-- 
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
-- 
--  MODIFICATION HISTORY:
-- 
--  version: |  author:  | mod date: | changes made:
--    V1.0      mktb       07 Jan 03   initial release
--------------------------------------------------------------------------------
-- mt47h64m16 Test Bench
--------------------------------------------------------------------------------

LIBRARY IEEE;     USE IEEE.std_logic_1164.ALL;
                  USE IEEE.VITAL_timing.ALL;
                  USE IEEE.VITAL_primitives.ALL;
LIBRARY FMF;      USE FMF.gen_utils.ALL;
                  USE FMF.conversions.ALL;

ENTITY tbmt47h64m16 IS END;

ARCHITECTURE test_1 of tbmt47h64m16 IS

    COMPONENT mt47h64m16
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
        TimingModel       : string    := DefaultTimingModel
    );

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
    END COMPONENT;

    for all : mt47h64m16 use entity WORK.mt47h64m16(VHDL_BEHAVIORAL);

--------------------------------------------------------------------------------
-- Tester Driven Signals
--------------------------------------------------------------------------------
    SIGNAL T_ODT            : std_logic := 'X';
    SIGNAL T_CK             : std_logic := 'X';
    SIGNAL T_CKNeg          : std_logic := 'X';
    SIGNAL T_CKE            : std_logic := 'X';
    SIGNAL T_CSNeg          : std_logic := 'X';
    SIGNAL T_RASNeg         : std_logic := 'X';
    SIGNAL T_CASNeg         : std_logic := 'X';
    SIGNAL T_WENeg          : std_logic := 'X';
    SIGNAL T_LDM            : std_logic := 'X';
    SIGNAL T_UDM            : std_logic := 'X';
    SIGNAL T_BA0            : std_logic := 'X';
    SIGNAL T_BA1            : std_logic := 'X';
    SIGNAL T_BA2            : std_logic := 'X';
    SIGNAL T_A0             : std_logic := 'X';
    SIGNAL T_A1             : std_logic := 'X';
    SIGNAL T_A2             : std_logic := 'X';
    SIGNAL T_A3             : std_logic := 'X';
    SIGNAL T_A4             : std_logic := 'X';
    SIGNAL T_A5             : std_logic := 'X';
    SIGNAL T_A6             : std_logic := 'X';
    SIGNAL T_A7             : std_logic := 'X';
    SIGNAL T_A8             : std_logic := 'X';
    SIGNAL T_A9             : std_logic := 'X';
    SIGNAL T_A10            : std_logic := 'X';
    SIGNAL T_A11            : std_logic := 'X';
    SIGNAL T_A12            : std_logic := 'X';
    SIGNAL T_DQ0            : std_logic := 'X';
    SIGNAL T_DQ1            : std_logic := 'X';
    SIGNAL T_DQ2            : std_logic := 'X';
    SIGNAL T_DQ3            : std_logic := 'X';
    SIGNAL T_DQ4            : std_logic := 'X';
    SIGNAL T_DQ5            : std_logic := 'X';
    SIGNAL T_DQ6            : std_logic := 'X';
    SIGNAL T_DQ7            : std_logic := 'X';
    SIGNAL T_DQ8            : std_logic := 'X';
    SIGNAL T_DQ9            : std_logic := 'X';
    SIGNAL T_DQ10           : std_logic := 'X';
    SIGNAL T_DQ11           : std_logic := 'X';
    SIGNAL T_DQ12           : std_logic := 'X';
    SIGNAL T_DQ13           : std_logic := 'X';
    SIGNAL T_DQ14           : std_logic := 'X';
    SIGNAL T_DQ15           : std_logic := 'X';
    SIGNAL T_UDQS           : std_logic := 'X';
    SIGNAL T_UDQSNeg        : std_logic := 'X';
    SIGNAL T_LDQS           : std_logic := 'X';
    SIGNAL T_LDQSNeg        : std_logic := 'X';

BEGIN
    -- Functional Component
    mt47h64m16_1 : mt47h64m16
        GENERIC MAP(
            -- tipd delays: interconnect path delays
            tipd_ODT => VitalZeroDelay01,
            tipd_CK => VitalZeroDelay01,
            tipd_CKNeg => VitalZeroDelay01,
            tipd_CKE => VitalZeroDelay01,
            tipd_CSNeg => VitalZeroDelay01,
            tipd_RASNeg => VitalZeroDelay01,
            tipd_CASNeg => VitalZeroDelay01,
            tipd_WENeg => VitalZeroDelay01,
            tipd_LDM => VitalZeroDelay01,
            tipd_UDM => VitalZeroDelay01,
            tipd_BA0 => VitalZeroDelay01,
            tipd_BA1 => VitalZeroDelay01,
            tipd_BA2 => VitalZeroDelay01,
            tipd_A0 => VitalZeroDelay01,
            tipd_A1 => VitalZeroDelay01,
            tipd_A2 => VitalZeroDelay01,
            tipd_A3 => VitalZeroDelay01,
            tipd_A4 => VitalZeroDelay01,
            tipd_A5 => VitalZeroDelay01,
            tipd_A6 => VitalZeroDelay01,
            tipd_A7 => VitalZeroDelay01,
            tipd_A8 => VitalZeroDelay01,
            tipd_A9 => VitalZeroDelay01,
            tipd_A10 => VitalZeroDelay01,
            tipd_A11 => VitalZeroDelay01,
            tipd_A12 => VitalZeroDelay01,
            tipd_DQ0 => VitalZeroDelay01,
            tipd_DQ1 => VitalZeroDelay01,
            tipd_DQ2 => VitalZeroDelay01,
            tipd_DQ3 => VitalZeroDelay01,
            tipd_DQ4 => VitalZeroDelay01,
            tipd_DQ5 => VitalZeroDelay01,
            tipd_DQ6 => VitalZeroDelay01,
            tipd_DQ7 => VitalZeroDelay01,
            tipd_DQ8 => VitalZeroDelay01,
            tipd_DQ9 => VitalZeroDelay01,
            tipd_DQ10 => VitalZeroDelay01,
            tipd_DQ11 => VitalZeroDelay01,
            tipd_DQ12 => VitalZeroDelay01,
            tipd_DQ13 => VitalZeroDelay01,
            tipd_DQ14 => VitalZeroDelay01,
            tipd_DQ15 => VitalZeroDelay01,
            tipd_UDQS => VitalZeroDelay01,
            tipd_UDQSNeg => VitalZeroDelay01,
            tipd_LDQS => VitalZeroDelay01,
            tipd_LDQSNeg => VitalZeroDelay01,
            -- tpd delays
            tpd_CK_DQ0 => UnitDelay01Z,
            tpd_CK_DQ1 => UnitDelay,
            tpd_CK_LDQS => UnitDelay01Z,
            -- tsetup values
            tsetup_DQ0_LDQS => UnitDelay,
            tsetup_A0_CK => UnitDelay,
            tsetup_LDQS_CK_CL3_negedge_posedge => --
            tsetup_LDQS_CK_CL4_negedge_posedge => --
            tsetup_LDQS_CK_CL5_negedge_posedge => --
            tsetup_LDQS_CK_CL6_negedge_posedge => --
            -- thold values
            thold_DQ0_LDQS => UnitDelay,
            thold_A0_CK => UnitDelay,
            thold_LDQS_CK_CL3_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL4_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL5_posedge_posedge => UnitDelay,
            thold_LDQS_CK_CL6_posedge_posedge => UnitDelay,
            -- tpw values
            tpw_CK_CL3_posedge => --
            tpw_CK_CL3_negedge => --
            tpw_CK_CL4_posedge => --
            tpw_CK_CL4_negedge => --
            tpw_CK_CL5_posedge => --
            tpw_CK_CL5_negedge => --
            tpw_CK_CL6_posedge => --
            tpw_CK_CL6_negedge => --
            tpw_A0_CL3 => UnitDelay,
            tpw_A0_CL4 => UnitDelay,
            tpw_A0_CL5 => UnitDelay,
            tpw_A0_CL6 => UnitDelay,
            tpw_DQ0_CL3 => UnitDelay,
            tpw_DQ0_CL4 => UnitDelay,
            tpw_DQ0_CL5 => UnitDelay,
            tpw_DQ0_CL6 => UnitDelay,
            tpw_LDQS_normCL3_posedge => UnitDelay,
            tpw_LDQS_normCL3_negedge => UnitDelay,
            tpw_LDQS_normCL4_posedge => UnitDelay,
            tpw_LDQS_normCL4_negedge => UnitDelay,
            tpw_LDQS_normCL5_posedge => UnitDelay,
            tpw_LDQS_normCL5_negedge => UnitDelay,
            tpw_LDQS_normCL6_posedge => UnitDelay,
            tpw_LDQS_normCL6_negedge => UnitDelay,
            tpw_LDQS_preCL3_negedge => UnitDelay,
            tpw_LDQS_preCL4_negedge => UnitDelay,
            tpw_LDQS_preCL5_negedge => UnitDelay,
            tpw_LDQS_preCL6_negedge => UnitDelay,
            tpw_LDQS_postCL3_negedge => UnitDelay,
            tpw_LDQS_postCL4_negedge => UnitDelay,
            tpw_LDQS_postCL5_negedge => UnitDelay,
            tpw_LDQS_postCL6_negedge => UnitDelay,
            -- tperiod values
            tperiod_CK_CL3 => UnitDelay,
            tperiod_CK_CL4 => UnitDelay,
            tperiod_CK_CL5 => UnitDelay,
            tperiod_CK_CL6 => UnitDelay,
            -- tskew values
            tskew_CK_LDQS_CL3_posedge_posedge => --
            tskew_CK_LDQS_CL4_posedge_posedge => --
            tskew_CK_LDQS_CL5_posedge_posedge => --
            tskew_CK_LDQS_CL6_posedge_posedge => --
            -- tdevice values: values for internal delays
            tdevice_tRC => 54
            tdevice_tRRD => 10
            tdevice_tRCD => 12
            tdevice_tFAW => 50
            tdevice_tRASMIN => 40
            tdevice_tRASMAX => 70
            tdevice_tRTP => 7.5
            tdevice_tWR => 15
            tdevice_tWTR => 7.5
            tdevice_tRP => 12
            tdevice_tRFCMIN => 127.5
            tdevice_tRFCMAX => 70
            tdevice_REFPer => 64
            tdevice_tCKAVGMAX => 8
            -- generic control parameters
            InstancePath => DefaultInstancePath,
            TimingChecksOn => DefaultTimingChecks,
            MsgOn => DefaultMsgOn,
            XOn => DefaultXon,
            -- memory file to be loaded
            mem_file_name => "none",
            UserPreload => FALSE,
            -- For FMF SDF technology file usage
            TimingModel => DefaultTimingModel
    )

        PORT MAP(
        ODT            => T_ODT,
        CK             => T_CK,
        CKNeg          => T_CKNeg,
        CKE            => T_CKE,
        CSNeg          => T_CSNeg,
        RASNeg         => T_RASNeg,
        CASNeg         => T_CASNeg,
        WENeg          => T_WENeg,
        LDM            => T_LDM,
        UDM            => T_UDM,
        BA0            => T_BA0,
        BA1            => T_BA1,
        BA2            => T_BA2,
        A0             => T_A0,
        A1             => T_A1,
        A2             => T_A2,
        A3             => T_A3,
        A4             => T_A4,
        A5             => T_A5,
        A6             => T_A6,
        A7             => T_A7,
        A8             => T_A8,
        A9             => T_A9,
        A10            => T_A10,
        A11            => T_A11,
        A12            => T_A12,
        DQ0            => T_DQ0,
        DQ1            => T_DQ1,
        DQ2            => T_DQ2,
        DQ3            => T_DQ3,
        DQ4            => T_DQ4,
        DQ5            => T_DQ5,
        DQ6            => T_DQ6,
        DQ7            => T_DQ7,
        DQ8            => T_DQ8,
        DQ9            => T_DQ9,
        DQ10           => T_DQ10,
        DQ11           => T_DQ11,
        DQ12           => T_DQ12,
        DQ13           => T_DQ13,
        DQ14           => T_DQ14,
        DQ15           => T_DQ15,
        UDQS           => T_UDQS,
        UDQSNeg        => T_UDQSNeg,
        LDQS           => T_LDQS,
        LDQSNeg        => T_LDQSNeg
        );

Stim: PROCESS
    BEGIN
        --
        WAIT;
    END PROCESS stim;
END test_1;
