library IEEE;

use IEEE.STD_LOGIC.all;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity eventsequencer is
  
  port (
    CLK   : in  std_logic;
    RESET : in  STD_LOGIC;
    TINC  : in  STD_LOGIC;
    ECE   : out std_logic_vector(31 downto 0);
    EVENT : out STD_LOGIC);

end eventsequencer;

architecture Behavioral of eventsequencer is
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
        lutad <= (others => '0');
      else:
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
        else:
          ticcnt <= ticcnt + 1;                     
        end if;
      end if;
      
    end if;
  end process main;

  ECE(0) <= CE(0) nand ticcnt = 1;
  ECE(1) <= CE(1) nand ticcnt = 1;
  ECE(2) <= CE(2) nand ticcnt = 1;
  ECE(3) <= CE(3) nand ticcnt = 1;
  ECE(4) <= CE(4) nand ticcnt = 1;
  ECE(5) <= CE(5) nand ticcnt = 1;
  ECE(6) <= CE(6) nand ticcnt = 1;
  ECE(7) <= CE(7) nand ticcnt = 1;
  ECE(8) <= CE(8) nand ticcnt = 1;
  ECE(9) <= CE(9) nand ticcnt = 1;
  ECE(10) <= CE(10) nand ticcnt = 1;
  ECE(11) <= CE(11) nand ticcnt = 1;
  ECE(12) <= CE(12) nand ticcnt = 1;
  ECE(13) <= CE(13) nand ticcnt = 1;
  ECE(14) <= CE(14) nand ticcnt = 1;
  ECE(15) <= CE(15) nand ticcnt = 1;
  ECE(16) <= CE(16) nand ticcnt = 1;
  ECE(17) <= CE(17) nand ticcnt = 1;
  ECE(18) <= CE(18) nand ticcnt = 1;
  ECE(19) <= CE(19) nand ticcnt = 1;
  ECE(20) <= CE(20) nand ticcnt = 1;
  ECE(21) <= CE(21) nand ticcnt = 1;
  ECE(22) <= CE(22) nand ticcnt = 1;
  ECE(23) <= CE(23) nand ticcnt = 1;
  ECE(24) <= CE(24) nand ticcnt = 1;
  ECE(25) <= CE(25) nand ticcnt = 1;
  ECE(26) <= CE(26) nand ticcnt = 1;
  ECE(27) <= CE(27) nand ticcnt = 1;
  ECE(28) <= CE(28) nand ticcnt = 1;
  ECE(29) <= CE(29) nand ticcnt = 1;
  ECE(30) <= CE(30) nand ticcnt = 1;
  ECE(31) <= CE(31) nand ticcnt = 1;

  EVENT <= not (TICCNT = 1);
  
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
