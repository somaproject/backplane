library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library SOMA;
use SOMA.somabackplane.all;
use soma.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;

entity eventtx is
  port (
    CLK     : in std_logic;
    EIND    : in std_logic_vector(15 downto 0);
    EINADDR : in std_logic_vector(2 downto 0);
    EINWE   : in std_logic;
    SRC     : in std_logic_vector(7 downto 0);

    EDATA    : out std_logic_vector(95 downto 0)
 := (others => '0');
    EADDR    : out std_logic_vector(77 downto 0)
 := (others => '0');
    NEWEVENT : out std_logic );
end eventtx;

architecture Behavioral of eventtx is
  signal lnewevent   : std_logic := '0';
  signal llnewevent  : std_logic := '0';
  signal lllnewevent : std_logic := '0';

begin  -- Behavioral

  lnewevent <= '1' when EINWE = '1' and einaddr = "000" else '0';

  process(CLK)
  begin
    if rising_edge(CLK) then

      llnewevent  <= lnewevent;
      lllnewevent <= llnewevent;

      if (llnewevent = '0' and lnewevent = '1') or
        (lllnewevent = '0' and llnewevent = '1')
      then
        NEWEVENT <= '1';
      else
        NEWEVENT <= '0';
      end if;

      if einwe = '1' then
        if einaddr = "001" then
          EDATA(31 downto 16) <= EIND;
        end if;

        if einaddr = "010" then
          EDATA(47 downto 32) <= EIND;
        end if;

        if einaddr = "011" then
          EDATA(63 downto 48) <= EIND;
        end if;

        if einaddr = "100" then
          EDATA(79 downto 64) <= EIND;
        end if;

        if einaddr = "101" then
          EDATA(95 downto 80) <= EIND;
        end if;

        if einaddr = "000" then
          EDATA(15 downto 0) <= SRC & EIND(7 downto 0);
        end if;
      end if;


      if einwe = '1' then
        if einaddr = "110" then
          eaddr                             <= (others => '1');
        elsif einaddr = "111" then
          --eaddr(to_integer(unsigned(eind))) <= '1';
          eaddr(conv_integer(eind) ) <= '1';
        end if;
      else
        if lllnewevent = '1' then
          eaddr                             <= (others => '0');
        end if;
      end if;
    end if;
  end process;


end Behavioral;
