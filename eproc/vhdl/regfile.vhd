library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity regfile is
  generic (
    BITS : integer := 16); 
  port (
    CLK   : in std_logic;
    DIA   : in std_logic_vector(BITS-1 downto 0);
    DOA : out std_logic_vector(BITS -1 downto 0); 
    ADDRA : in std_logic_vector(3 downto 0);
    WEA: in std_logic; 
    DOB : out std_logic_vector(BITS -1 downto 0); 
    ADDRB : in std_logic_vector(3 downto 0)
    );

end regfile;

architecture Behavioral of regfile is

begin  -- Behavioral

  regs: for i in 0 to BITS-1 generate
    ramb : RAM16X1D port map (
      DPO   => DOB(i),
      SPO   => DOA(i),
      A0    => ADDRA(0),
      A1    => ADDRA(1),
      A2    => ADDRA(2),
      A3    => ADDRA(3),
      D     => DIA(i),
      DPRA0 => ADDRB(0),
      DPRA1 => ADDRB(1),
      DPRA2 => ADDRB(2),
      DPRA3 => ADDRB(3),
      WCLK => CLK,
      WE => WEA); 
  end generate regs;

end Behavioral;
