-------------------------------------------------------------------------------
-- Title      : serialize
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serialize.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/02/02
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: TXBYTECLK to TXCLK bit serialization
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/27  1.0      jonas	Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity serialize is
  port ( TXBYTECLK : in std_logic;
         TXCLK : in std_logic;
         DIN : in std_logic_vector(9 downto 0);
         DOUT : out std_logic
         );

end serialize;

architecture Behavioral of serialize is
  signal dl, dll : std_logic_vector(9 downto 0) := (others => '0');

  signal cyccnt : std_logic_vector(9 downto 0) := "0000000001";

  signal len : std_logic := '0';
  signal sout : std_logic_vector(9 downto 0) := (others => '0');
  signal bitcnt : integer range 0 to 9 := 0;
  
begin  -- Behavioral

  txbyteclkmain: process (TXBYTECLK)
    begin
      if rising_edge(TXBYTECLK) then
        dl <= DIN; 
      end if;
    end process txbyteclkmain;



    
  txclkmain: process (TXCLK)
    begin
      if rising_edge(TXCLK) then
        if bitcnt = 9 then
          bitcnt <= 0;

        else
          bitcnt <= bitcnt + 1; 
        end if;
        
        if bitcnt = 0 then
          LEN <= '1'; 
        else
          LEN <= '0'; 
        end if;


        if LEN = '1' then
          dll <= dl;
          sout <= dll; 
        else
          sout <= '0' & sout(9 downto 1); 
        end if;
        
        DOUT <= sout(0);
        
      end if;
    end process txclkmain;
                                       

end Behavioral;
