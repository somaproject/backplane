library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity esequence is
  
  port (
    CLK   : in  std_logic;
    RESET : in  STD_LOGIC;
    TINC  : in  STD_LOGIC;
    ECE   : out std_logic_vector(31 downto 0);
    EVENT : out STD_LOGIC);

end esequence;

architecture Behavioral of esequence is
-- ESEQUENCE.VHD : event sequencer, tells devices on the event bus to TX

  signal lutaddr : std_logic_vector(5 downto 0) := (others => '0');
  signal lutdata : std_logic_vector(4 downto 0) := (others => '0');

  signal ce : std_logic_vector(31 downto 0) := (others => '0');
  
  signal ticcnt : natural := 0;

  
begin  -- Behavioral

  main: process (CLK, RESET)
  begin  -- process main
    if RESET = '1' then
      lutaddr <= (others => '0');
      ticcnt <= 0;

    elsif rising_edge(CLK) then


      -- lutaddr counter
      
      if TINC = '1' then
        lutaddr <= (others => '0');
      else
        if ticcnt = 5 then
          if lutaddr /= "111111" then
            lutaddr <= lutaddr + 1;
          end if;
        end if;
      end if;

      -- ticcnt counter
      if TINC = '1'  then
        ticcnt <= 0;
      else
        if ticcnt = 5 then
          ticcnt <= 0;
        else
          ticcnt <= ticcnt + 1;                     
        end if;
      end if;
      
    end if;
  end process main;

  ECE(0) <= '1' when CE(0) = '1'  nand ticcnt = 1 else '0';
  ECE(1) <= '1' when CE(1) = '1' nand ticcnt = 1 else '0';
  ECE(2) <= '1' when CE(2) = '1' nand ticcnt = 1 else '0';
  ECE(3) <= '1' when CE(3) = '1' nand ticcnt = 1 else '0';
  ECE(4) <= '1' when CE(4) = '1' nand ticcnt = 1 else '0';
  ECE(5) <= '1' when CE(5) = '1' nand ticcnt = 1 else '0';
  ECE(6) <= '1' when CE(6) = '1' nand ticcnt = 1 else '0';
  ECE(7) <= '1' when CE(7) = '1' nand ticcnt = 1 else '0';
  ECE(8) <= '1' when CE(8) = '1' nand ticcnt = 1 else '0';
  ECE(9) <= '1' when CE(9) = '1' nand ticcnt = 1 else '0';
  ECE(10) <= '1' when CE(10) = '1' nand ticcnt = 1 else '0';
  ECE(11) <= '1' when CE(11) = '1' nand ticcnt = 1 else '0';
  ECE(12) <= '1' when CE(12) = '1' nand ticcnt = 1 else '0';
  ECE(13) <= '1' when CE(13) = '1' nand ticcnt = 1 else '0';
  ECE(14) <= '1' when CE(14) = '1' nand ticcnt = 1 else '0';
  ECE(15) <= '1' when CE(15) = '1' nand ticcnt = 1 else '0';
  ECE(16) <= '1' when CE(16) = '1' nand ticcnt = 1 else '0';
  ECE(17) <= '1' when CE(17) = '1' nand ticcnt = 1 else '0';
  ECE(18) <= '1' when CE(18) = '1' nand ticcnt = 1 else '0';
  ECE(19) <= '1' when CE(19) = '1' nand ticcnt = 1 else '0';
  ECE(20) <= '1' when CE(20) = '1' nand ticcnt = 1 else '0';
  ECE(21) <= '1' when CE(21) = '1' nand ticcnt = 1 else '0';
  ECE(22) <= '1' when CE(22) = '1' nand ticcnt = 1 else '0';
  ECE(23) <= '1' when CE(23) = '1' nand ticcnt = 1 else '0';
  ECE(24) <= '1' when CE(24) = '1' nand ticcnt = 1 else '0';
  ECE(25) <= '1' when CE(25) = '1' nand ticcnt = 1 else '0';
  ECE(26) <= '1' when CE(26) = '1' nand ticcnt = 1 else '0';
  ECE(27) <= '1' when CE(27) = '1' nand ticcnt = 1 else '0';
  ECE(28) <= '1' when CE(28) = '1' nand ticcnt = 1 else '0';
  ECE(29) <= '1' when CE(29) = '1' nand ticcnt = 1 else '0';
  ECE(30) <= '1' when CE(30) = '1' nand ticcnt = 1 else '0';
  ECE(31) <= '1' when CE(31) = '1' nand ticcnt = 1 else '0';

  EVENT <= '0' when  TICCNT = 1 else '1';
  
  CE <= "00000000000000000000000000000001" when lutdata = "00000" else
        "00000000000000000000000000000010" when lutdata = "00001" else
        "00000000000000000000000000000100" when lutdata = "00010" else
        "00000000000000000000000000001000" when lutdata = "00011" else
        "00000000000000000000000000010000" when lutdata = "00100" else
        "00000000000000000000000000100000" when lutdata = "00101" else
        "00000000000000000000000001000000" when lutdata = "00110" else
        "00000000000000000000000010000000" when lutdata = "00111" else
        "00000000000000000000000100000000" when lutdata = "01000" else
        "00000000000000000000001000000000" when lutdata = "01001" else
        "00000000000000000000010000000000" when lutdata = "01010" else
        "00000000000000000000100000000000" when lutdata = "01011" else
        "00000000000000000001000000000000" when lutdata = "01100" else
        "00000000000000000010000000000000" when lutdata = "01101" else
        "00000000000000000100000000000000" when lutdata = "01110" else
        "00000000000000001000000000000000" when lutdata = "01111" else
        "00000000000000010000000000000000" when lutdata = "10000" else
        "00000000000000100000000000000000" when lutdata = "10001" else
        "00000000000001000000000000000000" when lutdata = "10010" else
        "00000000000010000000000000000000" when lutdata = "10011" else
        "00000000000100000000000000000000" when lutdata = "10100" else
        "00000000001000000000000000000000" when lutdata = "10101" else
        "00000000010000000000000000000000" when lutdata = "10110" else
        "00000000100000000000000000000000" when lutdata = "10111" else
        "00000001000000000000000000000000" when lutdata = "11000" else
        "00000010000000000000000000000000" when lutdata = "11001" else
        "00000100000000000000000000000000" when lutdata = "11010" else
        "00001000000000000000000000000000" when lutdata = "11011" else
        "00010000000000000000000000000000" when lutdata = "11100" else
        "00100000000000000000000000000000" when lutdata = "11101" else
        "01000000000000000000000000000000" when lutdata = "11110" else
        "10000000000000000000000000000000" when lutdata = "11011" else
        "00000000000000000000000000000000"; 
                
           
  -- addr lookup table
  lutdata <= "00000" when lutaddr = "000000" else
             "00001" when lutaddr = "000001" else
             "00010" when lutaddr = "000010" else
             "00011" when lutaddr = "000011" else
             "00100" when lutaddr = "000100" else
             "00101" when lutaddr = "000101" else
             "00110" when lutaddr = "000110" else
             "00111" when lutaddr = "000111" else
             "01000" when lutaddr = "001000" else
             "01001" when lutaddr = "001001" else
             "01010" when lutaddr = "001010" else
             "01011" when lutaddr = "001011" else
             "01100" when lutaddr = "001100" else
             "01101" when lutaddr = "001101" else
             "01110" when lutaddr = "001110" else
             "01111" when lutaddr = "001111" else
             "10000" when lutaddr = "010000" else
             "10001" when lutaddr = "010001" else
             "10010" when lutaddr = "010010" else
             "10011" when lutaddr = "010011" else
             "10100" when lutaddr = "010100" else
             "10101" when lutaddr = "010101" else
             "10110" when lutaddr = "010110" else
             "10111" when lutaddr = "010111" else
             "11000" when lutaddr = "011000" else
             "11001" when lutaddr = "011001" else
             "11010" when lutaddr = "011010" else
             "11011" when lutaddr = "011011" else
             "11100" when lutaddr = "011100" else
             "11101" when lutaddr = "011101" else
             "11110" when lutaddr = "011110" else
             "11111" when lutaddr = "011111" else
             "00000" when lutaddr = "100000" else
             "00001" when lutaddr = "100001" else
             "00010" when lutaddr = "100010" else
             "00011" when lutaddr = "100011" else
             "00100" when lutaddr = "100100" else
             "00101" when lutaddr = "100101" else
             "00110" when lutaddr = "100110" else
             "00111" when lutaddr = "100111" else
             "01000" when lutaddr = "101000" else
             "01001" when lutaddr = "101001" else
             "01010" when lutaddr = "101010" else
             "01011" when lutaddr = "101011" else
             "01100" when lutaddr = "101100" else
             "01101" when lutaddr = "101101" else
             "01110" when lutaddr = "101110" else
             "01111" when lutaddr = "101111" else
             "10000" when lutaddr = "110000" else
             "10001" when lutaddr = "110001" else
             "10010" when lutaddr = "110010" else
             "10011" when lutaddr = "110011" else
             "10100" when lutaddr = "110100" else
             "10101" when lutaddr = "110101" else
             "10110" when lutaddr = "110110" else
             "10111" when lutaddr = "110111" else
             "11000" when lutaddr = "111000" else
             "11001" when lutaddr = "111001" else
             "11010" when lutaddr = "111010" else
             "11011" when lutaddr = "111011" else
             "11100" when lutaddr = "111100" else
             "11101" when lutaddr = "111101" else
             "11110" when lutaddr = "111110" else
             "11111" when lutaddr = "111111" else
             "00000"; 
        
end Behavioral;
