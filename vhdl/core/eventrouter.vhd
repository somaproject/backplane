library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity eventrouter is
    port (
      CLK     : in  std_logic;
      ECYCLE  : in std_logic;
      EARX    : in  somabackplane.addrarray;
      EDRX : in somabackplane.dataarray; 
      EDSELRX : out std_logic_vector(3 downto 0);
      EATX    : out somabackplane.addrarray;
      EDTX    : out std_logic_vector(7 downto 0)
      );
end eventrouter;

architecture Behavioral of eventrouter is

  signal bytecnt : integer range 0 to 2047:= 0;
  signal edsel : std_logic_vector(3 downto 0) := (others => '0');

  signal dstart, edend : std_logic := '0';
  signal dmuxsel : integer range  0 to somabackplane.N-1 := 0;

begin  -- Behavioral

  EDTX <= EDRX(dmuxsel);
  EDSELRX <= edsel; 
  
  dstart <= '1' when bytecnt = 48 else '0';
  edend <= '1' when edsel = X"B" else '0';

  main: process(CLK)
    begin
      if rising_edge(CLK) then
        if ECYCLE = '1' then
          bytecnt <= 0;
        else
          if bytecnt = 2047 then
            bytecnt <= 0;
          else
            bytecnt <= bytecnt + 1; 
          end if;
        end if;

        -- dmuxsel counter
        if dstart = '1' then
          dmuxsel <= 0;
        else
          if edend ='1'then
            if dmuxsel = somabackplane.N - 1 then
              dmuxsel <= 0;
            else
              dmuxsel <= dmuxsel + 1; 
            end if;
          end if;
        end if;

        if edend = '1' or dstart = '1'  then
          edsel <= (others => '0');
        else
          edsel <= edsel + 1; 
        end if;
        
      end if;

    end process main; 
            
    outer: for dport in 0 to somabackplane.N-1 generate
      inner: for dbit in 0 to somabackplane.N-1 generate
        EATX(dport)(dbit) <= EARX(dbit)(dport); 
      end generate inner; 
    end generate outer;

end Behavioral;
