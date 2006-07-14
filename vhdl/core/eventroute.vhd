-------------------------------------------------------------------------------
-- Title      : routecore
-- Project    : 
-------------------------------------------------------------------------------
-- File       : routecore.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/03/07
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: routing core

-------------------------------------------------------------------------------
-- Revisions :
-- Date Version Author Description
-- 2006/01/23 1.0 jonas Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use work.somabackplane;


entity eventroute is
  port (
    CLK   : in  std_logic;
    RESET : in  std_logic;
    EATX  : out somabackplane.addrarray;
    EDTX  : out std_logic_vector(7 downto 0);

    EARX    : in  somabackplane.addrarray;
    EDRX    : in  somabackplane.dataarray;
    EDSELRX : out std_logic_vector(3 downto 0);
    ECYCLE  : in  std_logic);

end eventroute;

architecture Behavioral of eventroute is
  signal bytecnt : integer range 0 to 599                        := 0;
  signal dmuxsel : integer range 0 to (somabackplane.EVENTN - 1) := 0;
  signal edsel   : std_logic_vector(3 downto 0)                  := (others => '0');

  type states is (none, waitcnt, send);
  signal cs, ns : states := none;


begin  -- Behavioral


  -- primary routing of addresses
  addrroute  : for i in 0 to somabackplane.EVENTN - 1 generate
    bitroute : for j in 0 to somabackplane.EVENTN -1 generate
      EATX(i)(j) <= EARX(j)(i);
    end generate bitroute;
  end generate addrroute;

  EDTX    <= EDRX(dmuxsel);
  EDSELRX <= edsel;

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs      <= none;
      bytecnt <= 0;
      edsel   <= "0000";
      dmuxsel <= 0;
    else
      if rising_edge(CLK) then
        cs <= ns; 

        --
        if ECYCLE = '1' then
          bytecnt <= 0;
        else
          bytecnt <= bytecnt + 1;
        end if;


        if cs = waitcnt or edsel = 11 then
          edsel <= (others => '0');
        else
          edsel <= edsel + 1;
        end if;

        if cs /= send then
          dmuxsel   <= 0;
        else
          if edsel = 11 then
            dmuxsel <= dmuxsel + 1;
          end if;
        end if;


      end if;
    end if;

  end process main;

  fsm : process (cs, bytecnt, ECYCLE)
  begin
    case cs is
      when none    =>
        if ECYCLE = '1' then
          ns   <= waitcnt;
        else
          ns   <= none;
        end if;
      when waitcnt =>
        if ECYCLE = '1' then
          ns   <= waitcnt;
        else
          if bytecnt = 13 then
            ns <= send;
          else
            ns <= waitcnt;
          end if;

        end if;
      when send =>
        if ECYCLE = '1' then
          ns <= waitcnt;
        else

          if bytecnt = 588 then
            ns <= none;
          else
            ns <= send;
          end if;
        end if;
      when others => null;
    end case;

  end process fsm;

end Behavioral;
