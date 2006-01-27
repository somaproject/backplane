library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity dlock is
  port ( RXCLK     : in  std_logic;
         RXBYTECLK : in  std_logic;
         RESET     : in std_logic; 
         DEN       : in  std_logic;
         DIN       : in  std_logic;
         DOUT      : out std_logic_vector(9 downto 0);
         DOEN : out std_logic         
         );

end dlock;

architecture Behavioral of dlock is

  signal pdata         : std_logic_vector(9 downto 0) := (others => '0');
  signal denl, denll   : std_logic                    := '0';
  signal keq, keql    : std_logic                    := '0';
  signal pd1, pd2, pd2l, pd3 : std_logic_vector(9 downto 0) := (others => '0');

  signal lock, lockl : std_logic := '0';

  signal ldout : std_logic_vector(9 downto 0) := (others => '0');
  signal lldoen, ldoen : std_logic                    := '0';

  type states is (b0, b1, b2, b3, b4, b5, b6, b7, b8, b9);
  signal cs, ns : states := b0;

  signal bitcnt : std_logic_vector(9 downto 0) := "0000000001";

begin

  keq <= '1' when pdata = "0101111100" or pdata = "1010000011" else '0';

  rxclkmain : process(RXCLK)
  begin
    if RESET = '1' then
      cs     <= b0;
    else
      if rising_edge(RXCLK) then
        if denll = '1' then
          cs <= ns;
        end if;

        if DEN = '1' then
          pdata <= DIN & pdata(9 downto 1);
        end if;

        denl  <= DEN;
        denll <= denl;

        pd1 <= pdata;
        pd2 <= pd1;
        pd2l <= pd2; 

        if lockl = '1' then
          pd3 <= pd2l;
        end if;

        if bitcnt(0) = '1' then
          ldout <= pd3;
          ldoen <= lldoen; 
        end if;

        lockl <= lock; 
        if lockl = '1' and lock = '0' then --- DEBUGGING
          lldoen <= '1';
        else
          if bitcnt(0) = '1' then
            lldoen <= '0';
          end if;

        end if;

        if denl = '1' then
          keql <= keq;
        end if;
        
        bitcnt <= bitcnt(0) & bitcnt(9 downto 1);
      end if;
    end if;

  end process rxclkmain;


  rxbyteclkmain : process(RXBYTECLK)

  begin
    if rising_edge(RXBYTECLK) then

      DOEN <= ldoen;
      DOUT <= ldout;

    end if;

  end process rxbyteclkmain;


  fsm : process(cs, keql, denll)
  begin
    case cs is
      when b0     =>
        lock <= '1';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b1;
        end if;
      when b1     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b2;
        end if;
      when b2     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b3;
        end if;
      when b3     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b4;
        end if;
      when b4     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b5;
        end if;
      when b5     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b6;
        end if;
      when b6     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b7;
        end if;
      when b7     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b8;
        end if;
      when b8     =>
        lock <= '0';
        if keql = '1' then
          ns <= b0;
        else
          ns <= b9;
        end if;
      when b9     =>
        lock <= '0';
        ns   <= b0;
      when others =>
        lock <= '0';
        ns   <= b0;
    end case;

  end process fsm;

end Behavioral;

