
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity alu is
  port (
    A    : in  std_logic_vector(15 downto 0);
    B    : in  std_logic_vector(15 downto 0);
    Y    : out std_logic_vector(15 downto 0);
    AOP  : in  std_logic_vector(3 downto 0);
    CIN  : in  std_logic;
    COUT : out std_logic;
    ZERO : out std_logic;
    GTZ  : out std_logic;
    LTZ  : out std_logic
    );
end alu;

architecture Behavioral of alu is
  signal yint : std_logic_vector(15 downto 0) := (others => '0');

begin  -- Behavioral
  -- ghetto implementation
  Y    <= yint;
  yint <= A                               when AOP = "0000" else
          B                               when AOP = "0001" else
          B(7 downto 0 ) & B(15 downto 8) when AOP = "0010" else
          B(7 downto 0) & A(7 downto 0)   when AOP = "0011" else
          A xor B                         when AOP = "0101" else
          A and B                         when AOP = "0110" else
          A or B                          when AOP = "0111" else
          A + B                           when AOP = "1000" else
          X"DEAD";                      -- not implemented

  -- status signals
  COUT <= '0';
  ZERO <= '1' when yint = X"0000" else '0';
  GTZ  <= not yint(15);
  LTZ  <= yint(15);

end Behavioral;
