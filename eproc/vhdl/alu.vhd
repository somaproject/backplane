
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
  signal yint       : std_logic_vector(16 downto 0) := (others => '0');
  signal aext, bext : std_logic_vector(16 downto 0) := (others => '0');

  signal selcin : std_logic := '0';
  
begin  -- Behavioral
  -- ghetto implementation
  Y    <= yint(15 downto 0);
  COUT <= yint(16);

  aext <= "0" & A;
  bext <= "0" & B;

  selcin <= CIN when AOP(0) = '1' else '0';
  
  yint <= "0" & A                               when AOP = "0000" else
          "0" & B                               when AOP = "0001" else
          "0" & B(7 downto 0 ) & B(15 downto 8) when AOP = "0010" else
          "0" & B(7 downto 0) & A(7 downto 0)   when AOP = "0011" else
          "0" & (A xor B)                       when AOP = "0101" else
          "0" & (A and B)                       when AOP = "0110" else
          "0" & (A or B)                        when AOP = "0111" else
          Aext + Bext + (X"0000" & selCIN)     when AOP(3 downto 1) = "100" else
          Aext - Bext + (X"0000" & selCIN)     when AOP(3 downto 1) = "101"; 

  -- status signals

  ZERO <= '1' when yint(15 downto 0) = X"0000" else '0';
  GTZ  <= not yint(15);
  LTZ  <= yint(15);

end Behavioral;
