-------------------------------------------------------------------------------
-- Title      : eventtx
-- Project    : Soma
-------------------------------------------------------------------------------
-- File       : eventtx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/29
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Transmission of events and support packets. 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/27  1.0      jonas   Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity eventtx is
  generic (
    KCHAR : std_logic_vector(7 downto 0));
  
  port ( CLK       : in  std_logic;
         RESET     : in  std_logic;
         EIN       : in  std_logic_vector(7 downto 0);
         WE        : in  std_logic;
         TXBYTECLK : in  std_logic;
         EDOUT     : out std_logic_vector(7 downto 0);
         LASTBYTE  : out std_logic;
         EKOUT     : out std_logic;
         START     : in  std_logic
         );

end eventtx;

architecture Behavioral of eventtx is

  signal ed  : std_logic_vector(135 downto 0) := (others => '0');
  signal wel : std_logic                      := '0';

  signal edl         : std_logic_vector(135 downto 0);
  signal well, welll : std_logic := '0';
  signal armtx       : std_logic := '0';

  signal bcnt : integer range 0 to 17 := 0;



begin  -- Behavioral

-- input domain
  inputmain : process(CLK)
  begin
    if rising_edge(CLK) then

      wel <= WE;

      ed(135 downto 128) <= EIN;
      if wel = '1' then

        ed(7 downto 0)     <= ed(15 downto 8);
        ed(15 downto 8)    <= ed(23 downto 16);
        ed(23 downto 16)   <= ed(31 downto 24);
        ed(31 downto 24)   <= ed(39 downto 32);
        ed(39 downto 32)   <= ed(47 downto 40);
        ed(47 downto 40)   <= ed(55 downto 48);
        ed(55 downto 48)   <= ed(63 downto 56);
        ed(63 downto 56)   <= ed(71 downto 64);
        ed(71 downto 64)   <= ed(79 downto 72);
        ed(79 downto 72)   <= ed(87 downto 80);
        ed(87 downto 80)   <= ed(95 downto 88);
        ed(95 downto 88)   <= ed(103 downto 96);
        ed(103 downto 96)  <= ed(111 downto 104);
        ed(111 downto 104) <= ed(119 downto 112);
        ed(119 downto 112) <= ed(127 downto 120);
        ed(127 downto 120) <= ed(135 downto 128);
        ed(135 downto 128) <= ed(143 downto 136);

      end if;
    end if;

  end process inputmain;


  -- output combinatioal
  EDOUT <= KCHAR               when bcnt = 0  else
           edl(7 downto 0)     when bcnt = 1  else
           edl(15 downto 8)    when bcnt = 2  else
           edl(23 downto 16)   when bcnt = 3  else
           edl(31 downto 24)   when bcnt = 4  else
           edl(39 downto 32)   when bcnt = 5  else
           edl(47 downto 40)   when bcnt = 6  else
           edl(55 downto 48)   when bcnt = 7  else
           edl(63 downto 56)   when bcnt = 8  else
           edl(71 downto 64)   when bcnt = 9  else
           edl(79 downto 72)   when bcnt = 10 else
           edl(87 downto 80)   when bcnt = 11 else
           edl(95 downto 88)   when bcnt = 12 else
           edl(103 downto 96)  when bcnt = 13 else
           edl(111 downto 104) when bcnt = 14 else
           edl(119 downto 112) when bcnt = 15 else
           edl(127 downto 120) when bcnt = 16 else
           edl(135 downto 128);

  LASTBYTE <= '1' when bcnt = 17 else '0';
  EKOUT    <= '1' when bcnt = 0  else '0';


  outputmain : process(TXBYTECLK)
  begin
    if rising_edge(TXBYTECLK) then

      if well = '0' and welll = '1' then
      edl <= ed; 
       
      end if;

      well  <= wel;
      welll <= well;

      if START = '1' and armtx = '1' then
        bcnt   <= 0;
      else
        if bcnt /= 17 then
          bcnt <= bcnt + 1;
        end if;
      end if;

      if bcnt = 1 then
        armtx <= 0;
      else
        if welll = '1' then
          armtx<= '1'; 
        end if;
      end if;

      
    end if;
  end process outputmain; 
  
end Behavioral;
