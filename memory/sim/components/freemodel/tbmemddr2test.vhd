--------------------------------------------------------------------------------
--  File Name: tbmemddr2test.vhd
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
-- memddr2test Test Bench
--------------------------------------------------------------------------------

LIBRARY IEEE;     USE IEEE.std_logic_1164.ALL;
                  USE IEEE.VITAL_timing.ALL;
                  USE IEEE.VITAL_primitives.ALL;
LIBRARY FMF;      USE FMF.gen_utils.ALL;
                  USE FMF.conversions.ALL;

ENTITY tbmemddr2test IS END;

ARCHITECTURE test_1 of tbmemddr2test IS

    COMPONENT memddr2test
        GENERIC (

        PORT (
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
      DQSH       : inout std_logic;
      DQSL       : inout std_logic;
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
    END COMPONENT;

    for all : memddr2test use entity WORK.memddr2test(VHDL_BEHAVIORAL);

--------------------------------------------------------------------------------
-- Tester Driven Signals
--------------------------------------------------------------------------------
    SIGNAL T_port           : std_logic := 'X';
    SIGNAL T_CLK            : std_logic := 'X';
    SIGNAL T_CLK90          : std_logic := 'X';
    SIGNAL T_CLK180         : std_logic := 'X';
    SIGNAL T_CLK270         : std_logic := 'X';
    SIGNAL T_RESET          : std_logic := 'X';
    SIGNAL T_CKE            : std_logic := 'X';
    SIGNAL T_CAS            : std_logic := 'X';
    SIGNAL T_RAS            : std_logic := 'X';
    SIGNAL T_CS             : std_logic := 'X';
    SIGNAL T_WE             : std_logic := 'X';
    SIGNAL T_ADDR           : std_logic := 'X';
    SIGNAL T_BA             : std_logic := 'X';
    SIGNAL T_DQSH           : std_logic := 'X';
    SIGNAL T_DQSL           : std_logic := 'X';
    SIGNAL T_DQ             : std_logic := 'X';
    SIGNAL T_START          : std_logic := 'X';
    SIGNAL T_RW             : std_logic := 'X';
    SIGNAL T_DONE           : std_logic := 'X';
    SIGNAL T_ROWTGT         : std_logic := 'X';
    SIGNAL T_WRADDR         : std_logic := 'X';
    SIGNAL T_WRDATA         : std_logic := 'X';
    SIGNAL T_RDADDR         : std_logic := 'X';
    SIGNAL T_RDDATA         : std_logic := 'X';
    SIGNAL T_RDWE           : std_logic := 'X';

BEGIN
    -- Functional Component
    memddr2test_1 : memddr2test
        GENERIC MAP(

        PORT MAP(
        CLK            => T_CLK,
        CLK90          => T_CLK90,
        CLK180         => T_CLK180,
        CLK270         => T_CLK270,
        RESET          => T_RESET,
              -- RAM!
        CKE            => T_CKE,
        CAS            => T_CAS,
        RAS            => T_RAS,
        CS             => T_CS,
        WE             => T_WE,
        ADDR           => T_ADDR,
        BA             => T_BA,
        DQSH           => T_DQSH,
        DQSL           => T_DQSL,
        DQ             => T_DQ,
              -- interface
        START          => T_START,
        RW             => T_RW,
        DONE           => T_DONE,
              -- write interface
        ROWTGT         => T_ROWTGT,
        WRADDR         => T_WRADDR,
        WRDATA         => T_WRDATA,
              -- read interface
        RDADDR         => T_RDADDR,
        RDDATA         => T_RDDATA,
        RDWE           => T_RDWE
          );

Stim: PROCESS
    BEGIN
        --
        WAIT;
    END PROCESS stim;
END test_1;
