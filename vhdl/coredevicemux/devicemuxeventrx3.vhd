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
    START   : in  std_logic;
    DONE    : out std_logic;
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0));
end devicemuxeventrx2;

architecture Behavioral of devicemuxeventrx2 is

  signal edrxout : std_logic_vector(7 downto 0) := (others => '0');

  signal earxbuf : std_logic_vector(79 downto 0) := (others => '0');
  signal earxout : std_logic_vector(79 downto 0) := (others => '0');

  signal epos : integer range 0 to 23 := 0;

  signal dinl : std_logic_vector(7 downto 0) := (others => '0');

  signal regsel : std_logic := '0';

  signal rwea, rweb, rwe : std_logic := '0';

  signal addra, addrb : std_logic_vector(3 downto 0) := (others => '0');

  signal doba, dobb : std_logic_vector(7 downto 0) := (others => '0');

  type states is (e0, e1, e2, e3, e4, e5,
                  e6, e7, e8, e9, e10, e11,
                  e12, e13, e14, e15, e16, e17,
                  e18, e19, e20, e21, e22, e23, e24);
  signal cs, ns : states := e24;
  
begin

  DONE <= '1' when cs = e22 else '0';

  EARX <= earxout(somabackplane.N - 1 downto 0);

  EDRX <= edrxout;

  addrb <= EDSELRX;
  

  addra <= "0000" when cs = e10 else
           "0001" when cs = e11 else
           "0010" when cs = e12 else
           "0011" when cs = e13 else
           "0100" when cs = e14 else
           "0101" when cs = e15 else
           "0110" when cs = e16 else
           "0111" when cs = e17 else
           "1000" when cs = e18 else
           "1001" when cs = e19 else
           "1010" when cs = e20 else
           "1011" when cs = e21 else
           "1100";


  databuffer_a : entity regfile
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

  databuffer_b : entity regfile
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

  edrxout <= doba when regsel = '0' else dobb;

  rwea <= rwe when regsel = '1' else '0';
  rweb <= rwe when regsel = '0' else '0';

  rwe <= '1' when cs = e10 or cs = e11 or cs = e12 or
         cs = e13 or cs = e14 or cs = e15 or cs = e16
         or cs = e17 or cs = e18 or cs = e19 or
         cs = e20 or cs = e21 else '0';
  
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      dinl <= DIN;

      
      if START = '1' then
        cs <= e0; 
      else
        cs <= ns;
      end if;

      if ECYCLE = '1' then
        regsel  <= not regsel;
        earxout <= earxbuf;
        earxbuf <= (others => '0');
      else

        if cs = e0 then
          earxbuf(7 downto 0) <= dinl;
        end if;

        if cs = e1 then
          earxbuf(15 downto 8) <= dinl;
        end if;

        if cs = e2 then
          earxbuf(23 downto 16) <= dinl;
        end if;

        if cs = e3 then
          earxbuf(31 downto 24) <= dinl;
        end if;

        if cs = e4 then
          earxbuf(39 downto 32) <= dinl;
        end if;

        if cs = e5 then
          earxbuf(47 downto 40) <= dinl;
        end if;

        if cs = e6 then
          earxbuf(55 downto 48) <= dinl;
        end if;

        if cs = e7 then
          earxbuf(63 downto 56) <= dinl;
        end if;

        if cs = e8 then
          earxbuf(71 downto 64) <= dinl;
        end if;

        if cs = e9 then
          earxbuf(79 downto 72) <= dinl;
        end if;

      end if;



    end if;
  end process main;

  fsm: process(cs)
    begin
      case cs is
        when e0 =>
          ns <= e1;
        when e1 =>
          ns <= e2;
        when e2 =>
          ns <= e3;
        when e3 =>
          ns <= e4;
        when e4 =>
          ns <= e5;
        when e5 =>
          ns <= e6;
        when e6 =>
          ns <= e7;
        when e7 =>
          ns <= e8;
        when e8 =>
          ns <= e9;
        when e9 =>
          ns <= e10;
        when e10 =>
          ns <= e11;
        when e11 =>
          ns <= e12;
        when e12 =>
          ns <= e13;
        when e13 =>
          ns <= e14;
        when e14 =>
          ns <= e15;
        when e15 =>
          ns <= e16;
        when e16 =>
          ns <= e17;
        when e17 =>
          ns <= e18;
        when e18 =>
          ns <= e19;
        when e19 =>
          ns <= e20;
        when e20 =>
          ns <= e21;
        when e21 =>
          ns <= e22;
        when e22 =>
          ns <= e23;
        when e23 =>
          ns <= e24;
        when e24 =>
          ns <= e24;
        when others =>
          ns <= e24;
      end case;

    end process fsm; 

end Behavioral;
