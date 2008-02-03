library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity devicemuxeventrx is
  port (
    CLK     : in  std_logic;
    DIN     : in  std_logic_vector(7 downto 0);
    START   : in  std_logic;
    DONE    : out std_logic;
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0));
end devicemuxeventrx;

architecture Behavioral of devicemuxeventrx is

  signal edrxbuf : std_logic_vector(95 downto 0) := (others => '0');
  signal edrxout : std_logic_vector(95 downto 0) := (others => '0');

  signal earxbuf : std_logic_vector(79 downto 0) := (others => '0');
  signal earxout : std_logic_vector(79 downto 0) := (others => '0');

  signal epos : integer range 0 to 23 := 0;

  signal dinl : std_logic_vector(7 downto 0) := (others => '0');
  
begin

  DONE <= '1' when epos = 22 else '0';

  EARX <= earxout(somabackplane.N - 1 downto 0);

  EDRX <= edrxout(7 downto 0) when EDSELRX = "0000" else
          edrxout(15 downto 8) when EDSELRX = "0001" else
          edrxout(23 downto 16) when EDSELRX = "0010" else
          edrxout(31 downto 24) when EDSELRX = "0011" else
          edrxout(39 downto 32) when EDSELRX = "0100" else
          edrxout(47 downto 40) when EDSELRX = "0101" else
          edrxout(55 downto 48) when EDSELRX = "0110" else
          edrxout(63 downto 56) when EDSELRX = "0111" else
          edrxout(71 downto 64) when EDSELRX = "1000" else
          edrxout(79 downto 72) when EDSELRX = "1001" else
          edrxout(87 downto 80) when EDSELRX = "1010" else
          edrxout(95 downto 88);
          
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      dinl <= DIN;
      
      if START = '1' then
        epos <= 0;
      elsif epos < 23 then
        epos <= epos + 1;
      end if;

      if ECYCLE = '1' then
        earxout <= earxbuf; 
        earxbuf <= (others => '0');
      else

        if epos = 0 then
          earxbuf(7 downto 0) <= dinl;
        end if;

        if epos = 1 then
          earxbuf(15 downto 8) <= dinl;
        end if;

        if epos = 2 then
          earxbuf(23 downto 16) <= dinl;
        end if;

        if epos = 3 then
          earxbuf(31 downto 24) <= dinl;
        end if;

        if epos = 4 then
          earxbuf(39 downto 32) <= dinl;
        end if;

        if epos = 5 then
          earxbuf(47 downto 40) <= dinl;
        end if;

        if epos = 6 then
          earxbuf(55 downto 48) <= dinl;
        end if;

        if epos = 7 then
          earxbuf(63 downto 56) <= dinl;
        end if;

        if epos = 8 then
          earxbuf(71 downto 64) <= dinl;
        end if;

        if epos = 9 then
          earxbuf(79 downto 72) <= dinl;
        end if;

      end if;

      if epos = 11 then
        edrxbuf(15 downto 8) <= dinl;
      end if;
      if epos = 10 then
        edrxbuf(7 downto 0)  <= dinl;
      end if;


      if epos = 13 then
        edrxbuf(31 downto 24) <= dinl;
      end if;
      if epos = 12 then
        edrxbuf(23 downto 16) <= dinl;
      end if;


      if epos = 15 then
        edrxbuf(47 downto 40) <= dinl;
      end if;
      if epos = 14 then
        edrxbuf(39 downto 32) <= dinl;
      end if;


      if epos = 17 then
        edrxbuf(63 downto 56) <= dinl;
      end if;
      if epos = 16 then
        edrxbuf(55 downto 48) <= dinl;
      end if;


      if epos = 19 then
        edrxbuf(79 downto 72) <= dinl;
      end if;
      if epos = 18 then
        edrxbuf(71 downto 64) <= dinl;
      end if;


      if epos = 21 then
        edrxbuf(95 downto 88) <= dinl;
      end if;
      if epos = 20 then
        edrxbuf(87 downto 80) <= dinl;
      end if;

      if ECYCLE = '1' then
        earxout <= earxbuf;
        edrxout <= edrxbuf;
      end if;


    end if;
  end process main;

end Behavioral;
