library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity decode is
  port ( RXBYTECLK   : in  std_logic;
         RESET : in std_logic;
         DINEN  : in std_logic; 
         DIN   : in  std_logic_vector(9 downto 0);
         DOUT  : out std_logic_vector(7 downto 0);
         KOUT : out std_logic;
         ERR : out std_logic; 
         );

end sample;

architecture Behavioral of sample is
-- This is just a light wrapper around the xilinx 8b/10b core
  signal code_err, disp_err : std_logic := '0';
  
  
component decode8b10b 
        port (
        clk: IN std_logic;
        din: IN std_logic_VECTOR(9 downto 0);
        dout: OUT std_logic_VECTOR(7 downto 0);
        kout: OUT std_logic;
        ce: IN std_logic;
        code_err: OUT std_logic;
        disp_err: OUT std_logic);
END component;

begin
  ERR <= disp_err or code_err;

  decoder: decode8b10b port map (
    clk => RXBYTECLK,
    din => DIN,
    dout => DOUT,
    kout => kout,
    ce => dinen,
    code_err => code_err, 
    disp_err => disp_err);
  
end Behavioral;
