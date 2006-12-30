library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity crc_combinational is
  port ( CI : in  std_logic_vector(31 downto 0);
         D  : in  std_logic_vector(7 downto 0);
         CO : out std_logic_vector(31 downto 0));
end crc_combinational;

architecture Behavioral of crc_combinational is
-- CRC_COMBINATIONAL.VHD
-- combinational section of our CRC-32
-- caculator, based on the paper by Nair, Ryan, and Farzaneh, 1997

begin
  process(CI, D)
  begin
    CO(0)  <= D(7) xor CI(24) xor D(1) xor CI(30);
    CO(1)  <= D(6) xor CI(25) xor D(0) xor CI(31) xor
              D(7) xor CI(24) xor D(1) xor CI(30);
    CO(2)  <= D(5) xor CI(26) xor D(6) xor CI(25) xor
              D(0) xor CI(31) xor D(7) xor CI(24) xor
              D(1) xor CI(30);
    CO(3)  <= D(4) xor CI(27) xor D(5) xor CI(26) xor
              D(6) xor CI(25) xor D(0) xor CI(31);
    CO(4)  <= D(3) xor CI(28) xor D(4) xor CI(27) xor
              D(5) xor CI(26) xor D(7) xor CI(24) xor
              D(1) xor CI(30);
    CO(5)  <= D(2) xor CI(29) xor D(3) xor CI(28) xor
              D(4) xor CI(27) xor D(6) xor CI(25) xor
              D(0) xor CI(31) xor D(7) xor CI(24) xor
              D(1) xor CI(30);
    CO(6)  <= D(1) xor CI(30) xor D(2) xor CI(29) xor
              D(3) xor CI(28) xor D(5) xor CI(26) xor
              D(6) xor Ci(25) xor D(0) xor CI(31);
    CO(7)  <= D(0) xor CI(31) xor D(2) xor CI(29) xor
              D(4) xor CI(27) xor D(5) xor CI(26) xor
              D(7) xor CI(24);
    CO(8)  <= CI(0) xor D(3) xor CI(28) xor D(4) xor
              CI(27) xor D(6) xor CI(25) xor D(7) xor
              CI(24);
    CO(9)  <= CI(1) xor D(2) xor CI(29) xor D(3) xor
              CI(28) xor D(5) xor CI(26) xor D(6) xor
              CI(25);
    CO(10) <= CI(2) xor D(2) xor CI(29) xor D(4) xor
              CI(27) xor D(5) xor CI(26) xor D(7) xor
              CI(24);
    CO(11) <= CI(3) xor D(3) xor CI(28) xor D(4) xor
              CI(27) xor D(6) xor CI(25) xor D(7) xor
              CI(24);
    CO(12) <= CI(4) xor D(2) xor CI(29) xor D(3) xor
              CI(28) xor D(5) xor CI(26) xor D(6) xor
              CI(25) xor D(7) xor CI(24) xor D(1) xor
              CI(30);
    CO(13) <= CI(5) xor D(1) xor CI(30) xor D(2) xor
              CI(29) xor D(4) xor CI(27) xor D(5) xor
              CI(26) xor D(6) xor CI(25) xor D(0) xor
              CI(31);
    CO(14) <= CI(6) xor D(0) xor CI(31) xor D(1) xor
              CI(30) xor D(3) xor CI(28) xor D(4) xor
              CI(27) xor D(5) xor CI(26);
    CO(15) <= CI(7) xor D(0) xor CI(31) xor D(2) xor
              CI(29) xor D(3) xor CI(28) xor D(4) xor
              CI(27);
    CO(16) <= CI(8) xor D(2) xor CI(29) xor D(3) xor
              CI(28) xor D(7) xor CI(24);
    CO(17) <= CI(9) xor D(1) xor CI(30) xor D(2) xor
              CI(29) xor D(6) xor CI(25);
    CO(18) <= CI(10) xor D(0) xor CI(31) xor D(1) xor
              CI(30) xor D(5) xor CI(26);
    CO(19) <= CI(11) xor D(0) xor CI(31) xor D(4) xor
              CI(27);
    CO(20) <= CI(12) xor D(3) xor CI(28);
    CO(21) <= CI(13) xor D(2) xor CI(29);
    CO(22) <= CI(14) xor D(7) xor CI(24);
    CO(23) <= CI(15) xor D(6) xor CI(25) xor D(7) xor
              CI(24) xor D(1) xor CI(30);
    CO(24) <= CI(16) xor D(5) xor CI(26) xor D(6) xor
              CI(25) xor D(0) xor CI(31);
    CO(25) <= CI(17) xor D(4) xor CI(27) xor D(5) xor
              CI(26);
    CO(26) <= CI(18) xor D(3) xor CI(28) xor D(4) xor
              CI(27) xor D(7) xor CI(24) xor D(1) xor
              CI(30);
    CO(27) <= CI(19) xor D(2) xor CI(29) xor D(3) xor
              CI(28) xor D(6) xor CI(25) xor D(0) xor
              CI(31);
    CO(28) <= CI(20) xor D(1) xor CI(30) xor D(2) xor
              CI(29) xor D(5) xor CI(26);
    CO(29) <= CI(21) xor D(0) xor CI(31) xor D(1) xor
              CI(30) xor D(4) xor CI(27);
    CO(30) <= CI(22) xor D(0) xor CI(31) xor D(3) xor
              CI(28);
    CO(31) <= CI(23) xor D(2) xor CI(29);


  end process;



end Behavioral;
