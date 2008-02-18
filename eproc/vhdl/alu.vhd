
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
  signal yint   : std_logic_vector(16 downto 0) := (others => '0');
  signal ymux   : std_logic_vector(15 downto 0) := (others => '0');
  signal ybool  : std_logic_vector(15 downto 0) := (others => '0');
  signal yarith : std_logic_vector(16 downto 0) := (others => '0');

  signal aext, bext : std_logic_vector(16 downto 0) := (others => '0');

  signal selcin : std_logic := '0';
  signal bsel   : std_logic_vector(15 downto 0);

  signal suben : std_logic := '0';
  signal cen   : std_logic := '0';

begin  -- Behavioral
  -- ghetto implementation
  Y    <= yint(15 downto 0);
  COUT <= yint(16);

  aext <= "0" & A;
  bext <= "0" & bsel;

  bsel <= B when suben = '0' else not B;

  suben <= AOP(1);
  cen   <= AOP(0);


  selcin <= CIN       when suben = '0' and cen = '1' else
            '1'       when suben = '1' and cen = '0' else
            (CIN) when suben = '1' and cen = '1' else
            '0'; 


  ymux <= a                               when AOP(1 downto 0) = "00" else
          b                               when AOP(1 downto 0) = "01" else
          B(7 downto 0 ) & B(15 downto 8) when AOP(1 downto 0) = "10" else
          B(7 downto 0) & A(7 downto 0); 

  ybool <= A xor B when AOP(1 downto 0) = "01" else
           A and B when AOP(1 downto 0) = "10" else
           A or B;
  


  yarith <= (Aext + Bext + (X"0000" & selcin));


  yint <= "0" & ymux  when AOP(3 downto 2) = "00" else
          "0" & ybool when AOP(3 downto 2) = "01" else
          yarith;


  -- status signals

  ZERO <= '1' when yint(15 downto 0) = X"0000" else '0';
  GTZ  <= not yint(15);
  LTZ  <= yint(15);

end Behavioral;
