library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.numeric_std.all;


library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity singleeventdesttx is
  port (
    CLK     : in  std_logic;
    EAIN    : in  std_logic_vector(2 downto 0);
    EDIN    : in  std_logic_vector(15 downto 0);
    EWE     : in  std_logic;
    EDEST   : in  std_logic_vector(6 downto 0);
    ESEND   : in  std_logic;
    PENDING : out std_logic;
    ECYCLE  : in  std_logic;
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    EARX    : out std_logic_vector(somabackplane.N-1 downto 0));
end singleeventdesttx;

architecture Behavioral of singleeventdesttx is
  signal eol, eoll   : std_logic_vector(16 * 6-1 downto 0) := (others => '0');
  signal edestl, eal : std_logic_vector(6 downto 0)        := (others => '0');

  signal esendl, esendll : std_logic := '0';


begin  -- Behavioral


  PENDING <= esendl;

  decoder : for i in 0 to somabackplane.N-1 generate
    EARX(i) <= '1' when eal = std_logic_vector(TO_UNSIGNED(i, 7)) and
               esendll = '1' else '0';
  end generate decoder;

  EDRX <= eoll(7 downto 0)   when EDSELRX = X"1" else
          eoll(15 downto 8)  when EDSELRX = X"0" else
          eoll(23 downto 16) when EDSELRX = X"3" else
          eoll(31 downto 24) when EDSELRX = X"2" else
          eoll(39 downto 32) when EDSELRX = X"5" else
          eoll(47 downto 40) when EDSELRX = X"4" else
          eoll(55 downto 48) when EDSELRX = X"7" else
          eoll(63 downto 56) when EDSELRX = X"6" else
          eoll(71 downto 64) when EDSELRX = X"9" else
          eoll(79 downto 72) when EDSELRX = X"8" else
          eoll(87 downto 80) when EDSELRX = X"B" else
          eoll(95 downto 88);

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if EWE = '1' then
        if eain = "000" then
          eol (15 downto 0) <= EDIN;
        end if;

        if eain = "001" then
          eol (31 downto 16) <= EDIN;
        end if;

        if eain = "010" then
          eol (47 downto 32) <= EDIN;
        end if;

        if eain = "011" then
          eol (63 downto 48) <= EDIN;
        end if;

        if eain = "100" then
          eol (79 downto 64) <= EDIN;
        end if;

        if eain = "101" then
          eol (95 downto 80) <= EDIN;
        end if;
      end if;

      if ECYCLE = '1' then
        eal     <= edestl;
        esendll <= esendl;
        eoll    <= eol;
      end if;

      if esend = '1' then
        edestl <= edest;
      end if;

      if esend = '1' then
        esendl   <= '1';
      else
        if ECYCLE = '1' then
          esendl <= '0';
        end if;
      end if;


    end if;
  end process main;

end Behavioral;

