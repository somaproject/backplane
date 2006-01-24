-------------------------------------------------------------------------------
-- Title      : routecore
-- Project    : 
-------------------------------------------------------------------------------
-- File       : routecore.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/23
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: routing core

-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/23  1.0      jonas	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.somabackplane.all;


entity routecore is
  
  port (
    CLK : in std_logic;
    EPOS : out std_logic_vector(3 downto 0);
    EDATASEL : out std_logic_vector(3 downto 0);
    EDATAOUT : out std_logic_vector(7 downto 0);
    ECYCLE : out std_logic; 
    DSEL : out std_logic_vector(3 downto 0);
    DGRANT : out std_logic_vector(39 downto 0);
    EDATAIN : in dataarray);
end routecore;

architecture Behavioral of routecore is
  signal bytecnt : integer range 0 to 249 := 0;
  signal eposcnt : std_logic_vector(3 downto 0);
  signal edataselcnt : std_logic_vector(3 downto 0);
  signal dmuxsel : integer range 0 to 39 := 0;
  
begin  -- Behavioral

  EPOS <= eposcnt;
  ECYCLE <= '1' when eposcnt = "0000" else '0';

  EDATASEL <= edataselcnt;

  EDATAOUT <= EDATAIN(dmuxsel); 

  main: process (CLK)

    begin
      if rising_edge(CLK) then
        if bytecnt = 249 then
          bytecnt <= 0;
        else
          bytecnt <= bytecnt + 1; 
        end if;

        if bytecnt = 249 then
          eposcnt <= "0000";
        else
          if eposcnt /= "1111" then
            eposcnt <= eposcnt +1;
          end if;
        end if;


        if bytecnt = 249 or  edataselcnt = "1011" then
          edataselcnt <= "0000";
        else
          if eposcnt = "1111" then
            edataselcnt <= edataselcnt + 1;
          end if;
        end if;

        if bytecnt = 249 then
          dmuxsel <= 0;
        else
          if edataselcnt = "1011" then
            dmuxsel <= dmuxsel + 1;
          end if;
        end if;
      end if;
    end process main; 
                       
  

end Behavioral;
