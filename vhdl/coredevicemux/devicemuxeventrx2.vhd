library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity devicemuxeventrx2 is
  port (
    CLK     : in  std_logic;
    DIN     : in  std_logic_vector(7 downto 0);
    DINEN : in std_logic; 
    START   : in  std_logic;
    DONE    : out std_logic;
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0));
end devicemuxeventrx2;

architecture Behavioral of devicemuxeventrx2 is

  signal dinenl : std_logic := '0';
  signal edrxbuf : std_logic_vector(95 downto 0) := (others => '0');
  signal startl : std_logic := '0';
  
  signal earxbuf : std_logic_vector(79 downto 0) := (others => '0');
  signal earxout : std_logic_vector(79 downto 0) := (others => '0');

  signal epos : integer range 0 to 23 := 0;

  signal dinl : std_logic_vector(7 downto 0) := (others => '0');

  signal regsel : std_logic := '0';

  signal rwea, rweb, rwe : std_logic := '0';

  signal addra, addrb : std_logic_vector(3 downto 0) := (others => '0');

  signal doba, dobb : std_logic_vector(7 downto 0) := (others => '0');
 
begin

  DONE <= '1' when epos = 22 else '0';

  EARX <= earxout(somabackplane.N - 1 downto 0);



  addrb <= EDSELRX;
  

  addra <= "0000" when epos = 10 else
           "0001" when epos = 11 else
           "0010" when epos = 12 else
           "0011" when epos = 13 else
           "0100" when epos = 14 else
           "0101" when epos = 15 else
           "0110" when epos = 16 else
           "0111" when epos = 17 else
           "1000" when epos = 18 else
           "1001" when epos = 19 else
           "1010" when epos = 20 else
           "1011" when epos = 21 else
           "1100";


  databuffer_a : entity work.regfile
    generic map (
      BITS  => 8)
    port map (
      CLK   => CLK,
      DIA   => dinl,
      DOA   => open,
      ADDRA => addra,
      WEA   => rwea,
      ADDRB => addrb,
      DOB   => doba);

  databuffer_b : entity work.regfile
    generic map (
      BITS  => 8)
    port map (
      CLK   => CLK,
      DIA   => dinl,
      DOA   => open,
      ADDRA => addra,
      WEA   => rweb,
      ADDRB => addrb,
      DOB   => dobb);

  EDRX <= doba when regsel = '0' else dobb;

  rwea <= rwe when regsel = '1' else '0';
  rweb <= rwe when regsel = '0' else '0';

  rwe <= dinenl when epos > 9 and epos < 22 else '0';
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      startl <= START; 
      dinl <= DIN;
      dinenl <= DINEN;
      
      if STARTl = '1' then
        epos <= 0;
      elsif epos < 23 and dinenl = '1' then
        epos <= epos + 1;
      end if;

      if ECYCLE = '1' then
        regsel  <= not regsel;
        earxout <= earxbuf;
        earxbuf <= (others => '0');
      else

        if epos = 0 and dinenl = '1' then
          earxbuf(7 downto 0) <= dinl;
        end if;

        if epos = 1 and dinenl = '1' then
          earxbuf(15 downto 8) <= dinl;
        end if;

        if epos = 2 and dinenl = '1' then
          earxbuf(23 downto 16) <= dinl;
        end if;

        if epos = 3 and dinenl = '1' then
          earxbuf(31 downto 24) <= dinl;
        end if;

        if epos = 4 and dinenl = '1' then
          earxbuf(39 downto 32) <= dinl;
        end if;

        if epos = 5 and dinenl = '1' then
          earxbuf(47 downto 40) <= dinl;
        end if;

        if epos = 6 and dinenl = '1' then
          earxbuf(55 downto 48) <= dinl;
        end if;

        if epos = 7 and dinenl = '1' then
          earxbuf(63 downto 56) <= dinl;
        end if;

        if epos = 8 and dinenl = '1' then
          earxbuf(71 downto 64) <= dinl;
        end if;

        if epos = 9 and dinenl = '1' then
          earxbuf(79 downto 72) <= dinl;
        end if;

      end if;



    end if;
  end process main;

end Behavioral;
