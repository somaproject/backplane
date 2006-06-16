
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;



entity bootdeserialize is
  
  port (
    CLK   : in  std_logic;
    SERIN : in  std_logic;
    FPROG : out std_logic := '1';
    FCLK  : out std_logic;
    FDIN  : out std_logic);

end bootdeserialize;

architecture Behavioral of bootdeserialize is

  signal serinl : std_logic := '1';

  signal lfprog : std_logic := '1';
                               
  signal lfclk, lfdin : std_logic := '0';
  
  signal cnt : integer range 0 to 31 := 0;
signal cmdrst : std_logic := '1';
  type states is (none, cmdwait, cmdpend);

  signal cs, ns : states := none;

begin  -- Behavioral

  main: process(CLK)
    begin
      if rising_edge(CLK) then
        cs <= ns;

        serinl <= SERIN;

        if cnt = 6 then
          lfprog <= serinl;
        end if;


        if cnt = 11 then
          lfclk <= serinl; 
        end if;

        if cnt = 16 then
          lfdin <= serinl; 
        end if;

        if cnt = 20 then
          FPROG <= lfprog;
          FCLK <= lfclk;
          FDIN <= lfdin;
          
        end if;

        if cmdrst = '1' then
          cnt <= 0;
        else
          cnt <= cnt + 1; 
        end if;
        
      end if;

    end process main; 
                     
  
    fsm: process(CS, serinl, cnt)
      begin
        case cs is
          when none =>
            cmdrst <= '1';
            if serinl = '1' then
              ns <= cmdwait;
            else

              ns <= none; 
            end if;

          when cmdwait =>
            cmdrst <= '1';
            if serinl = '0' then
              ns <= cmdpend;
            else
              ns <= cmdwait; 
            end if;

          when cmdpend =>
            cmdrst <= '0';

            if cnt = 20 then
              ns <= none;
            else
              ns <= cmdpend; 
            end if;
          when others =>
            cmdrst <= '1';
            ns <= none; 
        end case;

      end process fsm; 
end Behavioral;
