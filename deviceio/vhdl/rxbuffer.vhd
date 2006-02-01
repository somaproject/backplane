-------------------------------------------------------------------------------
-- Title      : RX Buffer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rxbuffer.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/02/01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Receive event buffer
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/02/01  1.0      jonas   Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity rxbuffer is

  port (
    RXBYTECLK : in  std_logic;
    RESET     : in  std_logic;
    DEN       : in  std_logic;
    EA        : in  std_logic_vector(39 downto 0);
    DIN       : in  std_logic_vector(7 downto 0);
    CLK       : in  std_logic;
    DOEN      : out std_logic;
    DOUT      : out std_logic_vector(15 downto 0));

end rxbuffer;

architecture Behavioral of rxbuffer is
  signal dinl : std_logic_vector(95 downto 0) := (others => '0');
  signal do   : std_logic_vector(95 downto 0) := (others => '0');

  signal eacnt : integer range 0 to 40 := 0;
  signal ecnt  : integer range 0 to 11 := 0;

  signal ende, easel : std_logic := '0';
  signal een         : std_logic := '0';

  signal eenl, eenll : std_logic := '0';

  signal docnt : integer range 0 to 6 := 6;

begin  -- Behavioral

  -- combinatorial TXBYTEDOMAIN process
  ende <= '1' when ecnt = 11 and DEN = '1' else '0';

  easel <= EA(eacnt);



  txbytemain : process(RXBYTECLK, RESET)
  begin
    if RESET = '1' then
      ecnt  <= 0;
      eacnt <= 0;

    else
      if rising_edge(RXBYTECLK) then

        if RESET = '1' then
          ecnt     <= 0;
        else
          if DEN = '1' then
            if ecnt = 11 then
              ecnt <= 0;
            else
              ecnt <= ecnt + 1;
            end if;
          end if;

        end if;

        if RESET = '1' then
          eacnt   <= 0;
        else
          if ecnt = 11 and DEN = '1' and eacnt /= 40 then
            eacnt <= eacnt + 1;
          end if;
        end if;

        if den = '1' then
          if ecnt = 0 then
            dinl(7 downto 0)   <= DIN;
          end if;
          if ecnt = 1 then
            dinl(15 downto 8)  <= DIN;
          end if;
          if ecnt = 2 then
            dinl(23 downto 16) <= DIN;
          end if;
          if ecnt = 3 then
            dinl(31 downto 24) <= DIN;
          end if;
          if ecnt = 4 then
            dinl(39 downto 32) <= DIN;
          end if;
          if ecnt = 5 then
            dinl(47 downto 40) <= DIN;
          end if;
          if ecnt = 6 then
            dinl(55 downto 48) <= DIN;
          end if;
          if ecnt = 7 then
            dinl(63 downto 56) <= DIN;
          end if;
          if ecnt = 8 then
            dinl(71 downto 64) <= DIN;
          end if;
          if ecnt = 9 then
            dinl(79 downto 72) <= DIN;
          end if;
          if ecnt = 10 then
            dinl(87 downto 80) <= DIN;
          end if;
          if ecnt = 11 then
            dinl(95 downto 88) <= DIN;
          end if;

          if een = '1' then
            do <= dinl;

          end if;

          eenl <= een;


        end if;

      end if;
    end if;
  end process txbytemain;


  doen <= '1' when docnt /= 6 else '0';

  dout <= do(15 downto 0)  when docnt = 0 else
          do(31 downto 16) when docnt = 1 else
          do(47 downto 32) when docnt = 2 else
          do(63 downto 48) when docnt = 3 else
          do(79 downto 64) when docnt = 4 else
          do(95 downto 80) when docnt = 5 else
          X"0000";


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      eenll <= eenl;

      if eenll = '1' then
        docnt   <= 0;
      else
        if docnt /= 6 then
          docnt <= docnt + 1;
        end if;
      end if;
    end if;

  end process main;
end Behavioral;
