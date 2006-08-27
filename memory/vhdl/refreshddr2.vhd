library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity refreshddr2 is
  port (
    CLK    : in  std_logic;
    START  : in  std_logic;
    DONE   : out std_logic;
    -- ram interface
    CS     : out std_logic;
    RAS    : out std_logic;
    CAS    : out std_logic;
    WE     : out std_logic
    );
end refreshddr2;

architecture Behavioral of refreshddr2 is

  signal lcs : std_logic := '0';
  signal lras : std_logic := '1';
  signal lcas : std_logic := '1';
  signal lwe : std_logic := '1';

  type states is (none, refresh, waits, dones);
  signal ocs, ons : states := none;
  signal bcnt : integer range 0 to 15 := 0;
  
  
begin  -- Behavioral

  DONE <= '1' when ocs = dones else '0';
  
  main: process(CLK)
    begin
      if rising_edge(CLK) then

        ocs <= ons;
        
        CS <= lcs;
        RAS <= lras;
        CAS <= lcas;
        WE <= lwe;
        
        if ocs = none or ocs = dones then
          bcnt <= 0;
        else
          bcnt <= bcnt + 1;
          
        end if;
        
      end if;
    end process main; 
  
    fsm: process(ocs, START, bcnt)
      begin
        case ocs is
          when none =>
            lcs <= '0';
            lras <= '1';
            lcas <= '1';
            lwe <= '1';
            if START = '1' then
              ons <= refresh;
            else
              ons <= none; 
            end if;
            
          when refresh =>
            lcs <= '0';
            lras <= '0';
            lcas <= '0';
            lwe <= '1';
            ons <= waits; 
            
          when waits =>
            lcs <= '0';
            lras <= '1';
            lcas <= '1';
            lwe <= '1';
            if bcnt = 14 then
              ons <= dones;
            else
              ons <= waits; 
            end if;
            
          when dones =>
            lcs <= '0';
            lras <= '1';
            lcas <= '1';
            lwe <= '1';
            ons <= none; 

          when others =>
            lcs <= '0';
            lras <= '1';
            lcas <= '1';
            lwe <= '1';
            ons <= none; 
        end case;
        
    end process fsm; 
end Behavioral;