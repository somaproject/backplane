library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity bootserialize is
  generic (
    M : integer := 20);
  port (
    CLK    : in  std_logic;
    FPROG  : in  std_logic;
    FCLK   : in  std_logic;
    FDIN   : in  std_logic;
    FSET   : in  std_logic;
    FDONE  : out std_logic;
    SEROUT : out std_logic_vector(M-1 downto 0);
    ASEL  : in std_logic_vector(M-1 downto 0));
end bootserialize;

architecture Behavioral of bootserialize is

  signal fprogl, fclkl, fdinl : std_logic := '0';
  signal muxout               : std_logic := '0';


  signal bsel : integer range 0 to 4 := 0;

  signal bcnt : integer range 0 to 4 := 0;

  type states is (none, swait, s0, s1, s2, s3, s4, sdone);
  signal cs, ns : states := none;

  signal lserout : std_logic_vector(M-1 downto 0) := (others => '1');
  

begin  -- Behavioral


  muxout <= '1'    when bsel = 0 else
            '0'    when bsel = 1 else
            fprogl when bsel = 2 else
            fclkl  when bsel = 3 else
            fdinl  when bsel = 4;

  SEROUT <= lserout; 
  outreg       : for i in 0 to M-1 generate
    outregproc : process (CLK)
    begin
      if rising_edge(CLK) then
        if ASEL(i) = '1' then
          lserout(i) <= muxout;
        end if;
      end if;
    end process outregproc;
  end generate outreg;

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;


      fprogl <= FPROG;
      fclkl  <= FCLK;
      fdinl  <= FDIN;

      if bcnt = 4 then
        bcnt <= 0;
      else
        bcnt <= bcnt + 1;
      end if;
    end if;
  end process main;


  fsm : process (cs, FSET, bcnt)
  begin
    case cs is
      when none =>
        bsel  <= 0;
        FDONE <= '0';
        if FSET = '1' then
          ns  <= swait;
        else
          ns  <= none;
        end if;
        
      when swait =>
        bsel  <= 0;
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= s0; 
        else
          ns  <= swait; 
        end if;

      when s0 =>
        bsel  <= 0;
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= s1; 
        else
          ns  <= s0; 
        end if;

      when s1 =>
        bsel  <= 1;
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= s2; 
        else
          ns  <= s1; 
        end if;
        
      when s2 =>
        bsel  <= 2; 
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= s3; 
        else
          ns  <= s2; 
        end if;
      when s3 =>
        bsel  <= 3;
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= s4; 
        else
          ns  <= s3; 
        end if;
        
      when s4 =>
        bsel  <= 4;
        FDONE <= '0';
        if bcnt = 4 then
          ns  <= sdone; 
        else
          ns  <= s4; 
        end if;

      when sdone =>
        bsel  <= 0;
        FDONE <= '1';
        ns <= none; 
      when others =>
        bsel <= 0;
        FDONE <= '0';
        ns <= none;
        
    end case;

  end process fsm;
end Behavioral;
