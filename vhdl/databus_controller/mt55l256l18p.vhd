-----------------------------------------------------------------------------------------
--
--     File Name:  MT55L256L18P.VHD
--       Version:  2.0
--          Date:  November 16th, 2001
--         Model:  BUS Functional
--     Simulator:  NCDesktop    - http://www.cadence.com
--                 ModelSim PE  - http://www.model.com
--
--        Author:  Son Huynh
--         Email:  sphuynh@micron.com
--         Phone:  (208) 368-3825
--       Company:  Micron Technology, Inc.
--         Model:  MT55L256L18P (256K x 18)
--          Mode:  Pipelined
--
--   Description:  ZBT SRAM VHDL model
--
--    Limitation:  None
--
--          Note:  - BSDL model available separately
--                 - Set simulator resolution to "ps" timescale
--
--    Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY
--                 WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY
--                 IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
--                 A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
--
--                 Copyright (c) 1997 Micron Semiconductor Products, Inc.
--                 All rights researved
--
--     Trademarks: ZBT and Zero Bus Turnaround are trademarks of Integrated
--                 Device Technology, Inc., and the architecture is supported
--                 by Micron Technology, Inc., and Motorola Inc.
--
--  Rev  Author          Phone           Date        Changes
--  ---  --------------  --------------  ----------  ------------------------------------
--  2.0  Son Huynh       (208) 368-3825  09/19/2001  - Second Release
--       Micron Technology, Inc.                     - Update timing parameters
--
-----------------------------------------------------------------------------------------

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.std_logic_unsigned.all;

ENTITY mt55l256l18p IS
    GENERIC (
        -- Constant parameters
        addr_bits : INTEGER := 18;
        data_bits : INTEGER := 18;

        -- Timing parameters for -10 (100 Mhz)
        tKHKH    : TIME    := 10.0 ns;
        tKHKL    : TIME    :=  3.2 ns;
        tKLKH    : TIME    :=  3.2 ns;
        tKHQV    : TIME    :=  5.0 ns;
        tAVKH    : TIME    :=  2.0 ns;
        tEVKH    : TIME    :=  2.0 ns;
        tCVKH    : TIME    :=  2.0 ns;
        tDVKH    : TIME    :=  2.0 ns;
        tKHAX    : TIME    :=  0.5 ns;
        tKHEX    : TIME    :=  0.5 ns;
        tKHCX    : TIME    :=  0.5 ns;
        tKHDX    : TIME    :=  0.5 ns
    );

    -- Port Declarations
    PORT (
        Dq        : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);   -- Data I/O
        Addr      : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);   -- Address
        Lbo_n     : IN    STD_LOGIC;                                   -- Burst Mode
        Clk       : IN    STD_LOGIC;                                   -- Clk
        Cke_n     : IN    STD_LOGIC;                                   -- Cke#
        Ld_n      : IN    STD_LOGIC;                                   -- Adv/Ld#
        Bwa_n     : IN    STD_LOGIC;                                   -- Bwa#
        Bwb_n     : IN    STD_LOGIC;                                   -- BWb#
        Rw_n      : IN    STD_LOGIC;                                   -- RW#
        Oe_n      : IN    STD_LOGIC;                                   -- OE#
        Ce_n      : IN    STD_LOGIC;                                   -- CE#
        Ce2_n     : IN    STD_LOGIC;                                   -- CE2#
        Ce2       : IN    STD_LOGIC;                                   -- CE2
        Zz        : IN    STD_LOGIC                                    -- Snooze Mode
    );
END mt55l256l18p;

ARCHITECTURE behave OF mt55l256l18p IS
    SIGNAL ce : STD_LOGIC := '0';
    SIGNAL doe : STD_LOGIC := '0';
    SIGNAL dout : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
BEGIN
    ce <= NOT(Ce_n) AND NOT(Ce2_n) AND Ce2;

    doe <= NOT(Oe_n) AND NOT(ZZ);

    -- Output Buffers
    WITH doe SELECT
        dq <= TRANSPORT dout            AFTER (tKHQV) WHEN '1',
                        (OTHERS => 'Z') AFTER (tKHQV) WHEN OTHERS;

    -- Main Program
    main : PROCESS
        TYPE mem_array IS ARRAY ((2**addr_bits) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR ((data_bits / 2) - 1 DOWNTO 0);
        VARIABLE bank0 : mem_array;
        VARIABLE bank1 : mem_array;

        VARIABLE addr_in : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE addr_read : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE addr_write : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE baddr0, baddr1 : STD_LOGIC := '0';

        VARIABLE ce_in : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        VARIABLE rw_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
        VARIABLE bwa_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bwb_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bcnt : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    BEGIN
        WAIT ON Clk;
        IF Clk'EVENT AND Clk = '1' THEN
            IF Cke_n = '0' AND Zz = '0' THEN
                -- Write Address Register
                addr_write := addr_read;

                -- Read Address Register
                addr_read := addr_in (addr_bits - 1 DOWNTO 2) & baddr1 & baddr0;

                -- Address Register
                IF Ld_n = '0' and ce = '1' THEN
                    addr_in := Addr;
                END IF;

                -- Burst Logic
                IF    Lbo_n = '1' AND Ld_n = '0' THEN
                    bcnt := "00";
                ELSIF Lbo_n = '0' AND Ld_n = '0' THEN
                    bcnt := Addr (1 DOWNTO 0);
                ELSIF                 Ld_n = '1' THEN
                    bcnt := bcnt + 1;
                END IF;

                -- Binary Counter Decode
                IF Lbo_n = '1' THEN
                    baddr1 := bcnt (1) XOR addr_in (1);
                    baddr0 := bcnt (0) XOR addr_in (0);
                ELSE
                    baddr1 := bcnt (1);
                    baddr0 := bcnt (0);
                END IF;

                -- Read Logic
                ce_in (0) := ce_in (1);

                IF Ld_n = '0' THEN
                    ce_in (1) := ce;
                END IF;

                rw_in (0) := rw_in (1);
                rw_in (1) := rw_in (2);

                IF Ld_n = '0' THEN
                    rw_in (2) := NOT(ce AND NOT(Rw_n));
                END IF;

                -- Write Registry and Data Coherency Control Logic
                bwa_in (0) := bwa_in (1);
                bwb_in (0) := bwb_in (1);
                bwa_in (1) := bwa_in (2);
                bwb_in (1) := bwb_in (2);
                bwa_in (2) := Bwa_n;
                bwb_in (2) := Bwb_n;

                -- Write Data to Memory
                IF rw_in (0) = '0' AND bwa_in (0) = '0' THEN
                    bank0 (CONV_INTEGER (addr_write)) := Dq ( 8 DOWNTO  0);
                END IF;
                IF rw_in (0) = '0' AND bwb_in (0) = '0' THEN
                    bank1 (CONV_INTEGER (addr_write)) := Dq (17 DOWNTO  9);
                END IF;
            END IF;

            -- Read Data from Memory Array
            IF ce_in (0) = '1' AND rw_in (1) = '1' THEN
                dout ( 8 DOWNTO  0) <= bank0 (CONV_INTEGER (addr_read));
                dout (17 DOWNTO  9) <= bank1 (CONV_INTEGER (addr_read));
            ELSE
                dout <= (OTHERS => 'Z');
            END IF;
        END IF;
    END PROCESS;

    -- Check for Clock Timing Violation
    clk_check : PROCESS
        VARIABLE clk_high, clk_low : TIME := 0 ns;
    BEGIN
        WAIT ON Clk;
            IF Clk = '1' AND NOW >= tKHKH THEN
                ASSERT (NOW - clk_low >= tKHKL)
                    REPORT "Clk width low - tKHKL violation"
                    SEVERITY ERROR;
                ASSERT (NOW - clk_high >= tKHKH)
                    REPORT "Clk period high - tKHKH violation"
                    SEVERITY ERROR;
                clk_high := NOW;
            ELSIF Clk = '0' AND NOW /= 0 ns THEN
                ASSERT (NOW - clk_high >= tKLKH)
                    REPORT "Clk width high - tKLKH violation"
                    SEVERITY ERROR;
                ASSERT (NOW - clk_low >= tKHKH)
                    REPORT "Clk period low - tKHKH violation"
                    SEVERITY ERROR;
                clk_low := NOW;
            END IF;
    END PROCESS;

    -- Check for Setup Timing Violation
    setup_check : PROCESS
    BEGIN
        WAIT ON Clk;
        IF Clk = '1' THEN
            ASSERT (Addr'LAST_EVENT >= tAVKH)
                REPORT "Addr - tAVKH violation"
                SEVERITY ERROR;
            ASSERT (Cke_n'LAST_EVENT >= tEVKH)
                REPORT "CKE# - tEVKH violation"
                SEVERITY ERROR;
            ASSERT (Ce_n'LAST_EVENT >= tCVKH)
                REPORT "CE# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Ce2_n'LAST_EVENT >= tCVKH)
                REPORT "CE2# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Ce2'LAST_EVENT >= tCVKH)
                REPORT "CE2 - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Ld_n'LAST_EVENT >= tCVKH)
                REPORT "ADV/LD# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Rw_n'LAST_EVENT >= tCVKH)
                REPORT "RW# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Bwa_n'LAST_EVENT >= tCVKH)
                REPORT "BWa# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Bwb_n'LAST_EVENT >= tCVKH)
                REPORT "BWb# - tCVKH violation"
                SEVERITY ERROR;
            ASSERT (Dq'LAST_EVENT >= tDVKH)
                REPORT "Dq - tDVKH violation"
                SEVERITY ERROR;
        END IF;
    END PROCESS;

    -- Check for Hold Timing Violation
    hold_check : PROCESS
    BEGIN
        WAIT ON Clk'DELAYED(tKHAX), Clk'DELAYED(tKHEX), Clk'DELAYED(tKHCX), Clk'DELAYED(tKHDX);
        IF Clk'DELAYED(tKHAX) = '1' THEN
            ASSERT (Addr'LAST_EVENT > tKHAX)
                REPORT "Addr - tKHAX violation"
                SEVERITY ERROR;
        END IF;
        IF Clk'DELAYED(tKHEX) = '1' THEN
            ASSERT (Cke_n'LAST_EVENT > tKHEX)
                REPORT "CKE# - tKHEX violation"
                SEVERITY ERROR;
        END IF;
        IF Clk'DELAYED(tKHCX) = '1' THEN
            ASSERT (Ce_n'LAST_EVENT > tKHCX)
                REPORT "CE# - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Ce2_n'LAST_EVENT > tKHCX)
                REPORT "CE2# - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Ce2'LAST_EVENT > tKHCX)
                REPORT "CE2 - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Ld_n'LAST_EVENT > tKHCX)
                REPORT "ADV/LD# - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Rw_n'LAST_EVENT > tKHCX)
                REPORT "RW# - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Bwa_n'LAST_EVENT > tKHCX)
                REPORT "BWa# - tKHCX violation"
                SEVERITY ERROR;
            ASSERT (Bwb_n'LAST_EVENT > tKHCX)
                REPORT "BWb# - tKHCX violation"
                SEVERITY ERROR;
        END IF;
        IF Clk'DELAYED(tKHDX) = '1' THEN
            ASSERT (Dq'LAST_EVENT > tKHDX)
                REPORT "Dq - tKHDX violation"
                SEVERITY ERROR;
        END IF;
    END PROCESS;

END behave;
