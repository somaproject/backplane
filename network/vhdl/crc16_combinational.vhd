library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity crc16_combinational is
  port (
    D  : in  std_logic_vector(15 downto 0);
    CI : in  std_logic_vector(31 downto 0);
    CO : out std_logic_vector(31 downto 0));
end crc16_combinational;

architecture Behavioral of crc16_combinational is

begin
  process(CI, D)
  begin

    CO(0)  <= ci(22) xor ci(25) xor d(5) xor d(3) xor d(6) xor ci(16) xor ci(28) xor d(15) xor d(9) xor ci(26);

    CO(1)  <= ci(22) xor ci(17) xor d(3) xor ci(27) xor d(15) xor d(4) xor ci(25) xor d(8) xor ci(23) xor d(2) xor ci(29) xor d(6) xor ci(16) xor ci(28) xor d(14) xor d(9);

    CO(2)  <= ci(22) xor ci(17) xor d(1) xor ci(30) xor d(15) xor ci(24) xor d(13) xor d(7) xor ci(18) xor ci(25) xor d(8) xor d(2) xor ci(23) xor d(6) xor ci(29) xor ci(16) xor d(14) xor d(9);

    CO(3)  <= ci(17) xor d(1) xor ci(31) xor ci(30) xor ci(24) xor ci(19) xor d(13) xor d(7) xor ci(18) xor ci(25) xor d(5) xor d(12) xor d(8) xor ci(23) xor d(6) xor d(14) xor ci(26) xor d(0);

    CO(4)  <= ci(22) xor ci(31) xor d(3) xor ci(27) xor d(15) xor ci(24) xor d(4) xor ci(19) xor d(13) xor d(7) xor ci(20) xor ci(18) xor d(12) xor d(11) xor ci(16) xor ci(28) xor d(9) xor d(0);

    CO(5)  <= ci(22) xor ci(17) xor d(15) xor ci(19) xor ci(20) xor ci(21) xor d(12) xor d(5) xor d(8) xor d(10) xor d(11) xor ci(23) xor d(2) xor ci(29) xor ci(16) xor d(14) xor d(9) xor ci(26);

    CO(6)  <= ci(22) xor ci(17) xor d(1) xor ci(27) xor ci(30) xor ci(24) xor d(4) xor d(13) xor d(7) xor ci(20) xor ci(21) xor ci(18) xor d(8) xor d(10) xor d(11) xor ci(23) xor d(14) xor d(9);

    CO(7)  <= ci(31) xor d(15) xor ci(24) xor ci(19) xor d(13) xor d(7) xor ci(21) xor ci(18) xor d(5) xor d(12) xor d(8) xor d(10) xor ci(23) xor ci(16) xor ci(26) xor d(0);

    CO(8)  <= ci(17) xor d(3) xor ci(27) xor d(15) xor d(4) xor ci(24) xor ci(19) xor ci(20) xor d(7) xor d(12) xor d(5) xor d(11) xor ci(16) xor ci(28) xor d(14) xor ci(26);

    CO(9)  <= ci(17) xor d(3) xor ci(27) xor d(4) xor d(13) xor ci(20) xor ci(21) xor ci(18) xor ci(25) xor d(10) xor d(11) xor d(2) xor ci(29) xor d(6) xor ci(28) xor d(14);

    CO(10) <= d(1) xor ci(30) xor d(15) xor ci(19) xor d(13) xor ci(21) xor ci(18) xor ci(25) xor d(12) xor d(10) xor d(2) xor ci(29) xor d(6) xor ci(16);

    CO(11) <= ci(17) xor d(1) xor d(3) xor ci(31) xor ci(30) xor d(15) xor ci(19) xor ci(20) xor ci(25) xor d(12) xor d(11) xor d(6) xor ci(16) xor ci(28) xor d(14) xor d(0);

    CO(12) <= ci(22) xor ci(17) xor ci(31) xor d(3) xor d(15) xor d(13) xor ci(20) xor ci(21) xor ci(18) xor ci(25) xor d(10) xor d(11) xor d(2) xor d(6) xor ci(29) xor ci(16) xor ci(28) xor d(14) xor d(9) xor d(0);

    CO(13) <= ci(22) xor ci(17) xor d(1) xor ci(30) xor ci(19) xor d(13) xor ci(21) xor ci(18) xor d(5) xor d(12) xor d(8) xor d(10) xor ci(23) xor d(2) xor ci(29) xor d(14) xor ci(26) xor d(9);

    CO(14) <= ci(22) xor d(1) xor ci(31) xor ci(27) xor ci(30) xor ci(24) xor d(4) xor ci(19) xor d(13) xor d(7) xor ci(20) xor ci(18) xor d(12) xor d(8) xor d(11) xor ci(23) xor d(9) xor d(0);

    CO(15) <= d(3) xor ci(31) xor ci(24) xor ci(19) xor ci(20) xor d(7) xor ci(21) xor ci(25) xor d(12) xor d(8) xor d(10) xor d(11) xor ci(23) xor d(6) xor ci(28) xor d(0);

    CO(16) <= ci(0) xor d(3) xor d(15) xor ci(24) xor ci(20) xor d(7) xor ci(21) xor d(10) xor d(11) xor d(2) xor ci(29) xor ci(16) xor ci(28);

    CO(17) <= ci(22) xor ci(17) xor d(1) xor ci(30) xor ci(21) xor ci(25) xor d(10) xor d(2) xor d(6) xor ci(29) xor ci(1) xor d(14) xor d(9);

    CO(18) <= ci(22) xor d(1) xor ci(31) xor ci(30) xor d(13) xor ci(18) xor d(5) xor d(8) xor ci(23) xor d(9) xor d(0) xor ci(26) xor ci(2);

    CO(19) <= ci(31) xor ci(27) xor ci(24) xor d(4) xor ci(19) xor d(7) xor d(12) xor d(8) xor ci(23) xor d(0) xor ci(3);


    CO(20) <= ci(4) xor d(3) xor ci(24) xor ci(20) xor d(7) xor ci(25) xor d(11) xor d(6) xor ci(28);

    CO(21) <= ci(5) xor ci(21) xor ci(25) xor d(5) xor d(10) xor d(2) xor d(6) xor ci(29) xor ci(26);

    CO(22) <= d(1) xor d(3) xor ci(27) xor ci(30) xor d(15) xor d(4) xor ci(25) xor d(6) xor ci(16) xor ci(28) xor ci(6);

    CO(23) <= ci(22) xor ci(17) xor ci(31) xor d(15) xor ci(7) xor ci(25) xor d(2) xor d(6) xor ci(29) xor ci(16) xor d(14) xor d(9) xor d(0);

    CO(24) <= ci(17) xor d(1) xor ci(8) xor ci(30) xor d(13) xor ci(18) xor d(5) xor d(8) xor ci(23) xor d(14) xor ci(26);

    CO(25) <= ci(9) xor ci(31) xor ci(27) xor ci(24) xor d(4) xor ci(19) xor d(13) xor d(7) xor ci(18) xor d(12) xor d(0);

    CO(26) <= ci(22) xor ci(10) xor d(15) xor ci(19) xor ci(20) xor d(12) xor d(5) xor d(11) xor ci(16) xor d(9) xor ci(26);

    CO(27) <= ci(17) xor ci(27) xor d(4) xor ci(20) xor ci(21) xor d(8) xor d(10) xor d(11) xor ci(11) xor ci(23) xor d(14);

    CO(28) <= ci(22) xor d(3) xor ci(24) xor d(13) xor d(7) xor ci(21) xor ci(18) xor d(10) xor ci(12) xor ci(28) xor d(9);

    CO(29) <= ci(22) xor ci(19) xor ci(25) xor d(12) xor d(8) xor ci(13) xor ci(23) xor d(2) xor d(6) xor ci(29) xor d(9);

    CO(30) <= d(1) xor ci(30) xor ci(24) xor ci(20) xor d(7) xor ci(14) xor d(5) xor d(8) xor d(11) xor ci(23) xor ci(26);

    CO(31) <= ci(31) xor ci(27) xor d(4) xor ci(24) xor d(7) xor ci(21) xor ci(25) xor ci(15) xor d(10) xor d(6) xor d(0);

    
  end process;
end Behavioral;
