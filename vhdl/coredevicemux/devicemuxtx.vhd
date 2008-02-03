library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity devicemuxtx is
  port (
    CLK  : in std_logic;
    EDTX : in std_logic_vector(7 downto 0);
    ECYCLE : in std_logic; 
    -- port A
    DGRANTA : in std_logic;
    EATXA   : in std_logic_vector(somabackplane.N-1 downto 0);
    -- port B
    DGRANTB : in std_logic;
    EATXB   : in std_logic_vector(somabackplane.N-1 downto 0);
    -- port C
    DGRANTC : in std_logic;
    EATXC   : in std_logic_vector(somabackplane.N-1 downto 0);
    -- port D
    DGRANTD : in std_logic;
    EATXD   : in std_logic_vector(somabackplane.N-1 downto 0);
    -- outputs
    TXDOUT : out std_logic_vector(7 downto 0);
    TXKOUT : out std_logic);
end devicemuxtx;

architecture Behavioral of devicemuxtx is

  type states is (none, hdr1, hdr2, hdr3, hdr4, dataout);
  signal cs, ns : states := none;

  signal epos   : integer range 0 to 999 := 0;
  signal hdrpos : integer range 0 to 15  := 0;

  signal hdra, hdrb, hdrc, hdrd
 : std_logic_vector(7 downto 0) := (others => '0');

  signal osel : integer range 0 to 5 := 0;


begin  -- Behavioral

  TXDOUT <= X"BC" when osel = 0 else
            hdra  when osel = 1 else
            hdrb  when osel = 2 else
            hdrc  when osel = 3 else
            hdrd  when osel = 4 else
            edtx;

  hdra <= "0000000" & DGRANTA when hdrpos = 0  else
          eatxa(7 downto 0)   when hdrpos = 1  else
          eatxa(15 downto 8)  when hdrpos = 2  else
          eatxa(23 downto 16) when hdrpos = 3  else
          eatxa(31 downto 24) when hdrpos = 4  else
          eatxa(39 downto 32) when hdrpos = 5  else
          eatxa(47 downto 40) when hdrpos = 6  else
          eatxa(55 downto 48) when hdrpos = 7  else
          eatxa(63 downto 56) when hdrpos = 8  else
          eatxa(71 downto 64) when hdrpos = 9  else
          "00" & eatxa(somabackplane.N-1 downto 72); 

  
  hdrb <= "0000000" & DGRANTB when hdrpos = 0  else
          eatxb(7 downto 0)   when hdrpos = 1  else
          eatxb(15 downto 8)  when hdrpos = 2  else
          eatxb(23 downto 16) when hdrpos = 3  else
          eatxb(31 downto 24) when hdrpos = 4  else
          eatxb(39 downto 32) when hdrpos = 5  else
          eatxb(47 downto 40) when hdrpos = 6  else
          eatxb(55 downto 48) when hdrpos = 7  else
          eatxb(63 downto 56) when hdrpos = 8  else
          eatxb(71 downto 64) when hdrpos = 9  else
          "00" & eatxb(somabackplane.N-1 downto 72); 

  hdrc <= "0000000" & DGRANTC when hdrpos = 0  else
          eatxc(7 downto 0)   when hdrpos = 1  else
          eatxc(15 downto 8)  when hdrpos = 2  else
          eatxc(23 downto 16) when hdrpos = 3  else
          eatxc(31 downto 24) when hdrpos = 4  else
          eatxc(39 downto 32) when hdrpos = 5  else
          eatxc(47 downto 40) when hdrpos = 6  else
          eatxc(55 downto 48) when hdrpos = 7  else
          eatxc(63 downto 56) when hdrpos = 8  else
          eatxc(71 downto 64) when hdrpos = 9  else
          "00" & eatxc(somabackplane.N-1 downto 72); 

  hdrd <= "0000000" & DGRANTD when hdrpos = 0  else
          eatxd(7 downto 0)   when hdrpos = 1  else
          eatxd(15 downto 8)  when hdrpos = 2  else
          eatxd(23 downto 16) when hdrpos = 3  else
          eatxd(31 downto 24) when hdrpos = 4  else
          eatxd(39 downto 32) when hdrpos = 5  else
          eatxd(47 downto 40) when hdrpos = 6  else
          eatxd(55 downto 48) when hdrpos = 7  else
          eatxd(63 downto 56) when hdrpos = 8  else
          eatxd(71 downto 64) when hdrpos = 9  else
          "00" & eatxd(somabackplane.N-1 downto 72); 


  TXKOUT <= ECYCLE;
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs     <= ns;
      if ECYCLE = '1' then
        epos <= 0;
      else
        if epos = 999 then
          epos <= 0;
        else
          epos <= epos + 1;
        end if;
      end if;

      if ECYCLE = '1' then
        hdrpos   <= 0;
      else
        if hdrpos = 10 then
          hdrpos <= 0;
        else
          hdrpos <= hdrpos + 1; 
        end if;
      end if;

    end if;
  end process main;


  fsm : process(cs, ecycle, hdrpos, epos)
  begin
    case cs is
      when none =>
        osel <= 0;
        if ECYCLE = '1' then
          ns <= hdr1;
        else
          ns <= none;
        end if;

      when hdr1 =>
        osel <= 1;
        if hdrpos = 10 then
          ns <= hdr2;
        else
          ns <= hdr1;
        end if;

      when hdr2 =>
        osel <= 2;
        if hdrpos = 10 then
          ns <= hdr3;
        else
          ns <= hdr2;
        end if;

      when hdr3 =>
        osel <= 3;
        if hdrpos = 10 then
          ns <= hdr4;
        else
          ns <= hdr3;
        end if;

      when hdr4 =>
        osel <= 4;
        if hdrpos = 10 then
          ns <= dataout;
        else
          ns <= hdr4;
        end if;

      when dataout =>
        osel <= 5;
        if epos = 995 then
          ns <= none;
        else
          ns <= dataout;
        end if;
      when others  =>
        osel <= 0;
        ns   <= none;
    end case;
  end process fsm;

end Behavioral;
